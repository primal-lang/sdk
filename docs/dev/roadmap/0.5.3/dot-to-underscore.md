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
---

# Dot to Underscore

**TLDR**: `.` is removed from the set of characters allowed in identifiers, and every dotted standard library name is renamed to use `_` instead (`num.abs` becomes `num_abs`). This frees `.` to become a member access operator for the record, enum, tuple, and module features planned from 0.6.0 onward. It breaks every existing Primal program, so a migration script ships alongside it.

## Motivation

`.` is currently an ordinary identifier character, so `num.abs` lexes as a **single** identifier token. There is no namespace concept anywhere in the compiler — the dot is just a character in a flat string. Two consequences confirm this:

- `a.b.c(n) = n` is a legal function definition today.
- `foo.(n) = n` is also legal — a trailing dot is a valid name.

Because the lexer swallows dots into identifiers, `.` can never be a member access operator. That blocks a large part of the roadmap:

| Feature                       | Needs `.` as                    |
| ----------------------------- | ------------------------------- |
| [[dev/roadmap/0.7.0/record]]  | field access — `alice().name`   |
| [[dev/roadmap/0.7.0/enums]]   | variant access — `Color.Red`    |
| [[dev/roadmap/0.7.0/tuples]]  | positional access — `point().0` |
| [[dev/roadmap/0.6.0/modules]] | module qualification            |
| [[dev/roadmap/0.8.0/ranges]]  | `..` and `..<` range operators  |

Keeping `list.filter` as a name while also making `.` an operator leaves the grammar permanently ambiguous. The standard library therefore has to give up its dots.

## Rule

`.` is not valid in a function or parameter name. Replace it with `_`.

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

Nothing else about identifier validity changes. These stay legal: `foo_`, `foo__bar`, `foo9`. These stay illegal: `_foo`, `_` (both already rejected today).

## Scope of the rename

The standard library declares **316** functions, of which **296** are dotted across **27** prefixes:

```
assert  base64  bool  comp  console  directory  duration  env
error   file    function  hash  is  json  list  map  num  path
queue   set     stack  str   time  to   type  uuid  vector
```

The remaining 20 are unaffected: the 17 operator names (`+`, `-`, `*`, `/`, `%`, `==`, `!=`, `<`, `<=`, `>`, `>=`, `&`, `&&`, `|`, `||`, `!`, `@`) and `debug`, `if`, `try`.

Substituting `.` for `_` across all 296 produces **zero collisions**, so no name needs a judgment call. The full mapping is not reproduced here — `scripts/migrate_dots.sh` is the source of truth.

The Dart side already uses flat underscore names (`list_chunk.dart`, `class ListChunk`), so no Dart files or classes are renamed. Only the `name:` string literals change.

## Compiler change

One line, in `lib/extensions/string_extensions.dart:104`:

```dart
- bool get isIdentifier => isLetter || isDigit || isDot || isUnderscore;
+ bool get isIdentifier => isLetter || isDigit || isUnderscore;
```

`isIdentifier` has exactly one consumer, `IdentifierState.process` in `lib/compiler/lexical/lexical_analyzer.dart:548`, so the blast radius is contained to the lexical stage. The syntactic, semantic, lowering, and runtime stages are untouched — they already treat function names as opaque strings.

`isDot` itself is retained: number lexing depends on it (`IntegerState` at `lexical_analyzer.dart:407` transitions to `DecimalInitState` on a dot). Decimal literals such as `1.5` are unaffected because they never enter `IdentifierState`.

## Error behaviour

No new error type. With `.` no longer an identifier character and not an operand delimiter, `IdentifierState.process` falls through to its existing `else` branch and raises `InvalidCharacterError`:

```
$ primal old.prm
Error: Invalid character "." at [1, 4]
```

This is already the exact error produced today for a leading dot (`.foo(n) = n`), so the behaviour is consistent rather than new.

**Accepted tradeoff**: this is the first thing every migrating user sees, and it does not mention the rename or suggest a fix. A dedicated error carrying a `num.abs` -> `num_abs` suggestion was considered and rejected to keep the change minimal. The CHANGELOG entry and migration script carry that guidance instead.

## Migration

`scripts/migrate_dots.sh` is generated from the 296-name table and rewrites `.prm` files in place. It is needed for this repository's own sweep regardless, so it is published for users at effectively no extra cost. It sits alongside the existing `scripts/build_web.sh`, `scripts/coverage.sh`, and `scripts/format.sh`.

It must rewrite only known standard library names, not every dot, so that decimal literals (`1.5`), dots inside string literals, and dots in comments are left alone.

## Sweep breakdown

Occurrence counts from a prefix-anchored grep over the 27 namespaces:

| Area                     | Files | Occurrences | Method                                                   |
| ------------------------ | ----- | ----------- | -------------------------------------------------------- |
| `lib/`                   | —     | 325 strings | 296 `name:` declarations + 29 web platform stub messages |
| `test/`                  | 92    | ~15,000     | script                                                   |
| `test/resources/*.prm`   | 19    | 96          | script                                                   |
| `docs/lang/`             | 39    | ~1,231      | script                                                   |
| `docs/dev/architecture/` | 18    | ~234        | script                                                   |
| `docs/dev/roadmap/`      | 9     | ~71         | **by hand** — see below                                  |
| `README.md`              | 0     | 0           | contains no dotted calls                                 |
| `CHANGELOG.md`           | —     | —           | history left intact                                      |

The 29 non-declaration strings in `lib/` are error messages in the web platform stubs: `platform_file_web.dart` (16), `platform_directory_web.dart` (11), `platform_environment_web.dart` (2), plus one each in `platform_console_web.dart` and `utils/self_install.dart`.

### Roadmap docs must be edited by hand

Nine roadmap documents reference dotted standard library names. A blind substitution corrupts them, because they also contain dots that are _already_ member access and must be preserved:

```primal
enum.name(Color.Red)
^^^^^^^^^ library call  -> enum_name
          ^^^^^^^^^ member access -> keep the dot

// becomes
enum_name(Color.Red)
```

Affected: `0.6.0/http.md`, `0.6.0/regex.md`, `0.7.0/enums.md`, `0.7.0/option.md`, `0.7.0/tuples.md`, `0.8.0/do.md`, `0.8.0/try.md`, `1.0.0/currification.md`, `1.0.0/typing.md`.

### CHANGELOG

Historical entries are **not** rewritten. The 0.5.2 entry lists `assert.equal`, `assert.notEqual`, and so on, and that is genuinely what 0.5.2 shipped; anyone pinned to it needs those names. A new 0.5.3 entry records the rename as a breaking change and points at the migration script.

## Post-implementation

### Documentation

- Sweep `docs/lang/reference/` (28 pages), `docs/lang/design/` (12 pages), and `docs/lang/index.md`.
- Sweep `docs/dev/architecture/` (18 files).
- Hand-edit the 9 roadmap documents listed above.
- Reference pages stay grouped by prefix (`collections/list.md`, `primitives/arithmetic.md`); the grouping is presentational and remains useful even though the prefix is only a convention.
- Add the 0.5.3 CHANGELOG entry.
- `docs/dev/index.md` already links this page — no index change needed.

### Tests

- **Flip** `test/extensions/string_extensions_test.dart:330`, which currently asserts `'.'.isIdentifier == true`. The `isDot` assertion at line 123 stays true.
- **Add** a lexical test that a dotted name raises `InvalidCharacterError` at the dot's position — cover both a call site (`num.abs(1)`) and a definition (`foo.bar(n) = n`).
- **Add** a lexical test that `num_abs`, `foo_`, and `foo__bar` still lex as identifiers, and that `_foo` still does not.
- **Add** a regression test that decimal literals (`1.5`, `1.5e3`) still lex correctly, guarding the `isDot` retention.
- **Rewrite** the ~15,000 occurrences across `test/` with the migration script.
- **Verify** the 20 sample programs in `test/resources/samples/` and `test/resources/sample.prm` still run.
- **Verify** introspection output: `function_name` now returns `"list_filter"` rather than `"list.filter"`; assertions on those strings must be updated.
- Add a final check that no `.prm` file and no doc contains a dotted standard library name.

## Decisions and rationale

| Decision                                         | Rationale                                                                                                             |
| ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| Rename the standard library, not just user names | Banning dots only for users would not free `.`, since the lexer would still swallow them.                             |
| Flatten to `list_filter`, not namespace values   | Making `list` a real value would reserve 27 common words; `total(str) = str.length(str)` works today and would break. |
| Keep camelCase members                           | Matches existing user-code convention; pure substitution, no judgment calls, no collisions.                           |
| Generic `InvalidCharacterError`                  | Minimal diff; identical to the error `.foo` already produces.                                                         |
| Ban `.` and nothing else                         | One rule changes, so a broken program has exactly one cause.                                                          |
| Publish the migration script                     | Needed internally anyway; marginal cost of publishing is near zero.                                                   |
| Leave CHANGELOG history intact                   | Rewriting it would misstate what past releases shipped.                                                               |

## Risks

- **Shipping a 100% breaking change as a patch bump.** 0.5.2 -> 0.5.3 signals "safe upgrade", but every existing program stops compiling. A minor bump to 0.6.0 was recommended and explicitly rejected in favour of keeping the current release branch. Anyone depending on `^0.5.0` is broken silently. Mitigation is limited to a prominent CHANGELOG entry.
- **`is` as a prefix vs. `is` as a keyword.** [[dev/roadmap/0.7.0/enums]] proposes `c is Color.Red`, which would make `is` a keyword. The 17 `is_*` functions are unaffected as names, but the interaction should be checked when enums are specced.
- **Migration script over-matching.** Rewriting every `.` rather than only known library names would corrupt decimal literals and string contents. The script must be table-driven.
- **Test churn hides regressions.** A ~15,000-line mechanical diff across `test/` makes a genuine behavioural change easy to miss in review. Run the full suite before and after the sweep and compare results, rather than reading the diff.

## Implementation complexity

**Medium** — trivial to design, laborious to land.

The engineering content is close to zero: a one-line lexer change with a single consumer, no new token, no new error type, and no change to the syntactic, semantic, lowering, or runtime stages. There is no ambiguity to resolve, because substituting `.` for `_` across all 296 names produces zero collisions and therefore no judgment calls.

The cost is volume and coordination:

| Component                        | Effort                                                      |
| -------------------------------- | ----------------------------------------------------------- |
| Lexer change                     | Low — one line, one consumer                                |
| Standard library rename          | Low — 325 string literals, scripted                         |
| Migration script                 | Low–Medium — must be table-driven, not a blanket regex      |
| `test/` sweep                    | Medium — ~15,000 occurrences, scripted but must be verified |
| `docs/lang/` + `docs/dev/` sweep | Medium — ~1,465 occurrences across 57 files                 |
| Roadmap docs                     | Medium — 9 files, hand-edited, ~71 occurrences              |
| New tests                        | Low — five focused lexical tests                            |

It is not **Low** because a missed rename in any of ~17,000 occurrences produces a broken build or a stale doc, and the sheer diff size makes review by reading impractical. It is not **High** because nothing here is hard — no new language semantics, no runtime work, and no unresolved design questions.

## Recommendation

**Accept.**

The change unblocks five separate roadmap features ([[dev/roadmap/0.7.0/record]], [[dev/roadmap/0.7.0/enums]], [[dev/roadmap/0.7.0/tuples]], [[dev/roadmap/0.6.0/modules]], [[dev/roadmap/0.8.0/ranges]]) that cannot be built while the lexer swallows `.` into identifiers. It is provably mechanical, and its cost grows monotonically with every function added to the standard library and every program written against it — so doing it now is strictly cheaper than doing it later.

One reservation, raised and explicitly accepted: shipping a change that breaks 100% of existing programs as a patch release (0.5.2 -> 0.5.3) misrepresents its impact to anyone depending on `^0.5.0`. A 0.6.0 minor bump was recommended and declined in favour of keeping the current release branch. This does not block the change, but the CHANGELOG entry should be unambiguous about the break.
