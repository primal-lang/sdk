---
title: Dot to Underscore
tags:
  - roadmap
  - syntax
  - breaking-change
sources:
  - lib/extensions/string_extensions.dart
  - lib/compiler/lexical/lexical_analyzer.dart
  - lib/compiler/library/standard_library.dart
  - lib/main/main_cli.dart
  - test/compiler/lexical_analyzer_test.dart
---

# Dot to Underscore

**TLDR**: `.` is removed from the set of characters allowed in identifiers, and every dotted standard library name is renamed to use `_` instead (`num.abs` becomes `num_abs`). This frees `.` to become a member access operator for the record, enum, tuple, and module features planned from 0.6.0 onward. It breaks every program that uses a dotted name — in practice almost all of them — so a migration tool ships alongside it.

## Motivation

`.` is currently an ordinary identifier character, so `num.abs` lexes as a **single** identifier token. There is no namespace concept anywhere in the compiler — the dot is just a character in a flat string. Two consequences confirm this:

- `a.b.c(n) = n` is a legal function definition today.
- `foo.(n) = n` is also legal — a trailing dot is a valid name.

Because the lexer swallows dots into identifiers, `.` can never be a member access operator. That blocks a large part of the roadmap:

| Feature                       | Needs `.` as                    | Unblocked by this change?   |
| ----------------------------- | ------------------------------- | --------------------------- |
| [[dev/roadmap/0.7.0/record]]  | field access — `alice().name`   | Yes                         |
| [[dev/roadmap/0.7.0/enums]]   | variant access — `Color.Red`    | Yes                         |
| [[dev/roadmap/0.7.0/tuples]]  | positional access — `point().0` | Yes                         |
| [[dev/roadmap/0.6.0/modules]] | module qualification            | Yes                         |
| [[dev/roadmap/0.8.0/ranges]]  | `..` and `..<` range operators  | **No** — see _Ranges_ below |

Keeping `list.filter` as a name while also making `.` an operator leaves the grammar permanently ambiguous. The standard library therefore has to give up its dots.

This change **frees** the character; it does not turn `.` into a token. After it lands, `alice().name` still raises `InvalidCharacterError`. Member access is a separate piece of work in each feature that needs it.

### Ranges

Ranges are listed above because they need `.`, but this change does not unblock them. Number lexing keeps its dot transition (`IntegerState` at `lexical_analyzer.dart:407` moves to `DecimalInitState`, which requires a digit at `:433-438`), so `1..10` still fails:

```
$ primal range.prm
Error: Invalid character "." at [1, 12]. Expected: digit
```

That is unchanged before and after. [[dev/roadmap/0.8.0/ranges]] needs its own lookahead in `IntegerState` to distinguish `1.5` from `1..5`, and this document does not provide it.

## Rule

`.` is not valid in **any** identifier — function names, parameter names, `let` binding names, and lambda parameter names all use the same lexer path. Replace it with `_`.

```primal
// before
piEstimate.helper(i, terms, sum) = ...
main() = num.abs(-5)

// after
piEstimate_helper(i, terms, sum) = ...
main() = num_abs(-5)
```

The transformation is a literal character substitution. Member names keep their existing camelCase — `_` is not a word separator:

```
list.isEmpty       ->  list_isEmpty
duration.fromDays  ->  duration_fromDays
list.indexOf       ->  list_indexOf
```

This matches the camelCase convention already used for user-defined functions in `test/resources/samples/` (`sumOfDigits`, `piEstimate`).

Nothing else about identifier validity changes. These stay legal: `foo_`, `foo__bar`, `foo9`. These stay illegal: `_foo`, `_` (both already rejected today by `InitState`, which has no underscore branch).

## Scope of the rename

The standard library declares **316** functions, of which **296** are dotted across **27** prefixes:

```
assert  base64  bool  comp  console  directory  duration  env
error   file    function  hash  is  json  list  map  num  path
queue   set     stack  str   time  to   type  uuid  vector
```

The remaining 20 are unaffected: the 17 operator names (`+`, `-`, `*`, `/`, `%`, `==`, `!=`, `<`, `<=`, `>`, `>=`, `&`, `&&`, `|`, `||`, `!`, `@`) and `debug`, `if`, `try`.

Substituting `.` for `_` across all 296 produces **zero collisions within the standard library**, so no library name needs a judgment call. It does **not** guarantee collisions are absent in user code — see _User-side collisions_ below.

The Dart side already uses snake_case file and class names (`list_chunk.dart`, `class ListChunk`), so no Dart files or classes are renamed. Only the `name:` string literals change.

Note that the Primal name and the Dart file name stop lining up exactly where camelCase members exist: `num.asDegrees` becomes `num_asDegrees` but still lives in `num_as_degrees.dart`, and `num.roundTo` becomes `num_roundTo` in `num_round_to.dart`. This is intentional — Dart file names follow Dart conventions, Primal names follow Primal conventions — and should not be "fixed" later.

### User-side collisions

`_` is already a legal identifier character, so `num_abs(n) = n` compiles today. After the rename that same definition collides with the standard library and raises `Cannot redefine standard library function "num_abs"` (`runtime_facade.dart:263-268`; the equivalent file-level check is `semantic_analyzer.dart:46-48`).

The migration tool must detect this: before rewriting a file, collect the underscore names it will produce and the names the file already defines, and **refuse with a diagnostic** if any collide, rather than emit a program that fails with an error pointing at the wrong cause.

## Compiler changes

Two changes, in two files.

**1. Remove `.` from the identifier character set** — `lib/extensions/string_extensions.dart:104`:

```dart
- bool get isIdentifier => isLetter || isDigit || isDot || isUnderscore;
+ bool get isIdentifier => isLetter || isDigit || isUnderscore;
```

`isIdentifier` has exactly one consumer, `IdentifierState.process` in `lib/compiler/lexical/lexical_analyzer.dart:548`, so the compilation pipeline's blast radius is contained to the lexical stage. The syntactic, semantic, lowering, and runtime stages are untouched — they already treat function names as opaque strings.

`isDot` itself is retained: number lexing depends on it (`IntegerState` at `lexical_analyzer.dart:407` transitions to `DecimalInitState` on a dot). Decimal literals such as `1.5` are unaffected because they never enter `IdentifierState`.

**2. Change the test discovery prefix** — `lib/main/main_cli.dart:25`:

```dart
- const String testPrefix = 'test.';
+ const String testPrefix = 'test_';
```

This is **not** optional and is the one place outside the lexer where the change is load-bearing. `primal test` discovers tests by name prefix (`main_cli.dart:252`, error message at `:258`). Once `.` is illegal in identifiers, no function can be named `test.something`, so without this change the runner can never discover a test and every invocation fails with:

```
Error: no zero-argument functions with the "test." prefix found in <file>
```

`test/resources/sample.prm:38-81` declares 14 such functions and is the repository's own regression case for the runner.

Semantics are otherwise unchanged: `test_` is still a plain `startsWith` match, so a helper named `test_helper` is picked up as a test exactly as `test.helper` was.

## Error behaviour

No new error type. With `.` no longer an identifier character and not an operand delimiter, `IdentifierState.process` falls through to its existing `else` branch (`lexical_analyzer.dart:553-555`) and raises `InvalidCharacterError`:

```
$ primal old.prm
Error: Invalid character "." at [1, 4]
```

This is already the exact error produced today for a leading dot — `.foo(n) = n` yields `Error: Invalid character "." at [1, 1]` — so the behaviour is consistent rather than new.

**Accepted tradeoff**: this is the first thing every migrating user sees, and it does not mention the rename or suggest a fix. A dedicated error carrying a `num.abs` -> `num_abs` suggestion was considered and rejected to keep the change minimal. The CHANGELOG entry and migration tool carry that guidance instead.

### The rule is lexical only

The REPL's `:rename` command (`main_cli.dart:725-734`) splits raw input and passes the strings straight to `RuntimeFacade.renameFunction` (`runtime_facade.dart:151-187`), which never validates the new name. `:rename foo a.b` therefore still succeeds and produces a function that can never be referenced. The same hole exists in `defineFunction` for any caller that does not go through the lexer.

This is pre-existing and **out of scope** here, but it means "`.` is not valid in an identifier" is an invariant of the lexer, not of the runtime. Closing it needs a name validation helper shared by `renameFunction` and `defineFunction`, tracked separately.

## Migration

Two different tools are needed, because Primal source and prose require different techniques.

### `scripts/migrate_dots.dart` — for `.prm` files

**Lexer-aware, not table-driven.** It reuses the existing `SourceReader` scanning rules to walk the source and replaces `.` with `_` **only inside identifier tokens**, leaving decimal literals (`1.5`, `1.5e3`), string contents, and comments alone.

A table of the 296 standard library names is the wrong tool here, because user code defines dotted names too. The repository's own samples contain **28 distinct** user-defined dotted names over **57 occurrences** — `piEstimate.helper`, `matMul.cell`, `binarySearch.helper`, `frequency.count`, `test.factorial.base`, and so on, across 10 `.prm` files. A table-driven pass renames the library calls, reports success, and leaves every one of those definitions broken at the next compile. It also cannot tell `i.e` in a comment (which occurs in `test/resources/samples/`) from an identifier.

Requirements:

- Rewrite dots inside identifier tokens only.
- Refuse the file, with a diagnostic, when the rewrite would collide with a name the file already defines (see _User-side collisions_).
- Report a per-file count so the sweep can be reconciled against the table below.

It is needed for this repository's own sweep regardless, so it is published for users at effectively no extra cost. It sits alongside the existing `scripts/build_desktop.sh`, `scripts/build_web.sh`, `scripts/coverage.sh`, and `scripts/format.sh`.

### The doc/test sweep — table-driven, never blanket

Markdown and Dart test files have no lexer to lean on, so there a table of the 296 exact names is correct. But it **must not be run over Dart code**, because several standard library names are byte-identical to Dart member expressions used throughout this codebase:

| Name                  | Occurrences in `lib/` | Of which are the Primal declaration      |
| --------------------- | --------------------- | ---------------------------------------- |
| `function.name`       | 55                    | 1 (`introspection/function_name.dart:8`) |
| `function.parameters` | 15                    | 1                                        |

The other 54 and 14 are Dart: `SemanticFunction.name` in `runtime_facade.dart:48,105,108,112,115`, `semantic_analyzer.dart:33,38,46,53`, `main_cli.dart:252,275,289`, `mapper.dart:8`, `term.dart:466`. The same applies to `file.read`, `file.write`, `file.parent`, `directory.copy`, `directory.path`, `path.extension`, `set.add`, `set.contains`, and `map.containsKey`, all of which appear as Dart calls inside `lib/compiler/library/**` (for example `file_read.dart:36`) and in `test/`.

Rules:

- In `.dart` files, rewrite **only inside string literals**, and review the diff — some string literals are deliberately arbitrary names, not Primal source (`platform_web_test.dart:1537,1543,1553` use `'test.function'`, `'exact.function.name'`, and `'\u{1F600}.emoji.function'` to assert that error text is preserved verbatim).
- In `lib/`, do not run the sweep at all. The 296 `name:` declarations and the 30 web-stub strings are edited directly.

## Sweep breakdown

Occurrence counts are exact matches against the 296-name table unless noted.

| Area                     | Files                   | Occurrences                            | Method                              |
| ------------------------ | ----------------------- | -------------------------------------- | ----------------------------------- |
| `lib/compiler/library/`  | 296 (of 316)            | 296 `name:` declarations, one per file | by hand — sweep must not run here   |
| `lib/compiler/platform/` | 4                       | 30 web stub strings                    | by hand                             |
| `lib/main/main_cli.dart` | 1                       | 1 (`testPrefix`)                       | by hand                             |
| `test/**/*.dart`         | 51                      | 12,128                                 | table-driven, string literals only  |
| `test/**/*.prm`          | 19 (20 incl. user-only) | 92 library + 57 user-defined           | `migrate_dots.dart`                 |
| `docs/lang/`             | 39                      | 1,214                                  | table-driven + hand edits for prose |
| `docs/dev/architecture/` | 9 (of 22 pages)         | 167                                    | table-driven + hand edits for prose |
| `docs/dev/roadmap/`      | 9                       | 71 dotted identifiers                  | **by hand** — see below             |
| `README.md`              | 1                       | 0 library names, 2 grammar regexes     | **by hand** — see below             |
| `CHANGELOG.md`           | 1                       | 108                                    | left intact                         |

The 30 non-declaration strings in `lib/` are error messages in the web platform stubs: `platform_file_web.dart` (16), `platform_directory_web.dart` (11), `platform_environment_web.dart` (2), and `platform_console_web.dart` (1). `lib/utils/self_install.dart` contains none — its only apparent hit is the Dart import `package:primal/utils/console.dart`, which is why a prefix-anchored grep over the 27 namespaces is not a usable count.

### Roadmap docs must be edited by hand

Nine roadmap documents contain dotted identifiers. A blind substitution corrupts them, for two reasons.

First, they contain dots that are _already_ member access and must be preserved:

```primal
enum.name(Color.Red)
^^^^^^^^^ library call  -> enum_name
          ^^^^^^^^^ member access -> keep the dot

// becomes
enum_name(Color.Red)
```

Second, most of their dotted names are **proposed** functions that do not exist yet and are therefore absent from the 296-name table — `http.get`, `http.post`, `tuple.first`, `tuple.at`, `data.get`, `data.set`, `enum.values`. These must be renamed to the underscore form so future specs are written against the post-0.5.3 grammar, but no table-driven pass will find them.

Affected: `0.6.0/http.md`, `0.6.0/regex.md`, `0.7.0/enums.md`, `0.7.0/option.md`, `0.7.0/tuples.md`, `0.8.0/do.md`, `0.8.0/try.md`, `1.0.0/currification.md`, `1.0.0/typing.md`. Of the 71 dotted identifiers across them, 19 are current standard library names.

`0.9.0/transpilation.md` looks affected to a prefix grep but is not: its two hits are the filename `script.prm`.

### Prose that states the rule must be rewritten, not swept

Three documents state the identifier grammar normatively. None of them contains a dotted library call, so an occurrence-count sweep reports them as clean while they go on contradicting the shipped lexer:

- `README.md:94-95` — **Name** and **Parameters** "must match the regular expression `[a-zA-Z][\w\.]*`". Both become `[a-zA-Z]\w*`.
- `docs/lang/design/function-definitions.md:33-34` — "Contain only letters, digits, underscores, or dots" and the regex `[a-zA-Z][\w.]*` (`:36` extends both to parameters); plus `user.getName` listed at `:43` under **Valid names**, which must move or be replaced.
- `docs/dev/architecture/pipeline/lexical.md:180` — "Dots (`.`)" in the identifier character list, and `:183` "This allows dotted names like `math.pi` or `list.head` to be parsed as single identifier tokens". Neither `math.pi` nor `list.head` is a real library name, so no table-driven pass touches them.

### CHANGELOG

Historical entries are **not** rewritten. The 0.5.2 entry lists `assert.equal`, `assert.notEqual`, and so on, and that is genuinely what 0.5.2 shipped; anyone pinned to it needs those names. A new 0.5.3 entry records the rename as a breaking change and points at the migration tool.

## Post-implementation

### Documentation

- Sweep `docs/lang/reference/` (28 pages), `docs/lang/design/` (12 pages), and `docs/lang/index.md`.
- Sweep `docs/dev/architecture/` (22 pages, 9 of which contain library names).
- Hand-edit the 9 roadmap documents listed above, including their proposed names.
- Hand-edit the three normative grammar statements listed above (`README.md`, `docs/lang/design/function-definitions.md`, `docs/dev/architecture/pipeline/lexical.md`).
- Update `docs/dev/architecture/pipeline/lexical.md` and `docs/dev/architecture/testing/` for the new `test_` discovery prefix.
- Reference pages stay grouped by prefix (`collections/list.md`, `primitives/arithmetic.md`); the grouping is presentational and remains useful even though the prefix is only a convention.
- Add the 0.5.3 CHANGELOG entry.
- `docs/dev/index.md` already links this page — no index change needed.

### Tests

Lexical:

- **Flip** `test/extensions/string_extensions_test.dart:330`, which currently asserts `'.'.isIdentifier == true`. The `isDot` assertion at line 123 stays true.
- **Remove or invert** three tests in `test/compiler/lexical_analyzer_test.dart` that assert the behaviour being deleted: `'Identifier with dot'` at `:655` (`is.even`), `'Identifier complex'` at `:670` (`isToday_butNot.31st`), and `'Identifier with multiple dots'` at `:4722` (`a.b.c`).
- **Add** a test that a dotted name raises `InvalidCharacterError` at the dot's position — cover both a call site (`num.abs(1)`) and a definition (`foo.bar(n) = n`).
- **Add** a test that `num_abs`, `foo_`, and `foo__bar` still lex as identifiers, and that `_foo` still does not.
- **Add** a regression test that decimal literals (`1.5`, `1.5e3`) still lex correctly, guarding the `isDot` retention.

CLI:

- **Add** a test that `primal test` discovers `test_*` functions, and that a file using the old `test.*` names now fails at the lexer rather than silently reporting zero tests. `test/compiler/main_cli_test.dart` and `test/compiler/cli_test.dart` are the existing homes.

Migration tool:

- **Add** tests for `scripts/migrate_dots.dart`: a user-defined dotted name is rewritten; a decimal literal is not; a dot inside a string literal is not; a dot inside a comment is not; a file that would produce a name it already defines is refused.

Sweep:

- **Rewrite** the 12,128 occurrences across `test/**/*.dart` and the 149 across `test/**/*.prm`.
- **Verify** the 20 sample programs in `test/resources/samples/` and `test/resources/sample.prm` still run, and that `primal test test/resources/sample.prm` still reports 14 passing tests.
- **Verify** introspection output: `function_name` now returns `"list_filter"` rather than `"list.filter"`; assertions on those strings must be updated.
- Add a final check that no `.prm` file and no doc contains a dotted standard library name, **excluding** `CHANGELOG.md` (history is deliberately intact), this page, and the roadmap pages that legitimately retain member-access dots. Without those exclusions the gate can never pass.

## Decisions and rationale

| Decision                                         | Rationale                                                                                                             |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| Rename the standard library, not just user names | Banning dots only for users would not free `.`, since the lexer would still swallow them.                             |
| Flatten to `list_filter`, not namespace values   | Making `list` a real value would reserve 27 common words; `total(str) = str.length(str)` works today and would break. |
| Keep camelCase members                           | Matches existing user-code convention; pure substitution, no judgment calls, no collisions within the library.        |
| Generic `InvalidCharacterError`                  | Minimal diff; identical to the error `.foo` already produces.                                                         |
| Ban `.` in identifiers and nothing else          | One rule changes, so a broken program has exactly one cause.                                                          |
| `test_` as the new discovery prefix              | Preserves the existing `startsWith` semantics with the smallest possible change to the runner.                        |
| Lexer-aware `.prm` migration, table-driven docs  | A table cannot see user-defined dotted names; a lexer cannot read Markdown.                                           |
| Publish the migration tool                       | Needed internally anyway; marginal cost of publishing is near zero.                                                   |
| Leave CHANGELOG history intact                   | Rewriting it would misstate what past releases shipped.                                                               |
| Leave `:rename` validation out of scope          | Pre-existing hole, orthogonal to the lexer, and fixing it needs a shared validation helper.                           |

## Risks

- **Shipping a near-total breaking change as a patch bump.** 0.5.2 -> 0.5.3 signals "safe upgrade", but every program that names a library function stops compiling. Programs built only from operators, literals, and undotted user functions still compile, so it is not literally 100% — but it is close enough that the distinction offers no comfort. A minor bump to 0.6.0 was recommended and explicitly rejected in favour of keeping the current release branch. Anyone depending on `^0.5.0` is broken silently. Mitigation is limited to a prominent CHANGELOG entry.
- **Test runner breakage is silent-ish.** If `testPrefix` is missed, nothing fails to compile — `primal test` just reports "no functions with the `test.` prefix found" and exits 2, which reads like a user error rather than a regression. The CLI test above is the guard.
- **User-side name collisions.** `_` was always legal, so a user who already has `num_abs` gets `Cannot redefine standard library function` after migration, with no hint that the migration caused it. The tool must detect and refuse.
- **Migration tool over-matching.** Rewriting every `.` rather than only identifier tokens would corrupt decimal literals, string contents, and comments. Rewriting via a name table would silently skip user-defined dotted names. Neither shortcut is acceptable.
- **Sweep corrupting Dart code.** `function.name` and `function.parameters` are simultaneously Primal library names and the most common Dart expressions in this codebase. Running the table over `.dart` files outside string literals breaks the build.
- **`is` as a prefix vs. `is` as a keyword.** [[dev/roadmap/0.7.0/enums]] proposes `c is Color.Red`, which would make `is` a keyword. The 17 `is_*` functions are unaffected as names, but the interaction should be checked when enums are specced.
- **Test churn hides regressions.** A ~12,000-line mechanical diff across `test/` makes a genuine behavioural change easy to miss in review. Run the full suite before and after the sweep and compare results, rather than reading the diff.

## Implementation complexity

**Medium** — trivial to design, laborious to land.

The engineering content is small: a two-line change across two files, no new token, no new error type, and no change to the syntactic, semantic, lowering, or runtime stages. Substituting `.` for `_` across all 296 library names produces zero collisions within the library, so there are no naming judgment calls.

The cost is volume, coordination, and one tool that has to be written carefully:

| Component                        | Effort                                                            |
| -------------------------------- | ----------------------------------------------------------------- |
| Lexer change                     | Low — one line, one consumer                                      |
| `testPrefix` change              | Low — one line, but load-bearing and easy to miss                 |
| Standard library rename          | Low — 326 string literals, scripted                               |
| Migration tool                   | Medium — lexer-aware, plus collision detection and its own tests  |
| `test/` sweep                    | Medium — ~12,200 occurrences, scripted but must be verified       |
| `docs/lang/` + `docs/dev/` sweep | Medium — ~1,380 occurrences across 48 files                       |
| Roadmap docs                     | Medium — 9 files, hand-edited, 73 dotted identifiers              |
| Normative grammar prose          | Low — 3 files, hand-edited, but invisible to any occurrence count |
| New tests                        | Low–Medium — lexical, CLI runner, and migration tool              |

It is not **Low** because a missed rename in any of ~14,000 occurrences produces a broken build or a stale doc, because the sheer diff size makes review by reading impractical, and because two of the required edits (`testPrefix`, the grammar prose) are invisible to the greps used to size the work. It is not **High** because nothing here is hard — no new language semantics, no runtime work, and no unresolved design questions.

## Recommendation

**Accept.**

The change unblocks four roadmap features ([[dev/roadmap/0.7.0/record]], [[dev/roadmap/0.7.0/enums]], [[dev/roadmap/0.7.0/tuples]], [[dev/roadmap/0.6.0/modules]]) that cannot be built while the lexer swallows `.` into identifiers, and is a prerequisite for a fifth ([[dev/roadmap/0.8.0/ranges]], which additionally needs its own change to `IntegerState`). It is provably mechanical, and its cost grows monotonically with every function added to the standard library and every program written against it — so doing it now is strictly cheaper than doing it later.

One reservation, raised and explicitly accepted: shipping a change that breaks essentially every existing program as a patch release (0.5.2 -> 0.5.3) misrepresents its impact to anyone depending on `^0.5.0`. A 0.6.0 minor bump was recommended and declined in favour of keeping the current release branch. This does not block the change, but the CHANGELOG entry should be unambiguous about the break.
