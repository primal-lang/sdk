# Implementation Plan — Dot to Underscore (0.5.3)

Spec: `docs/dev/roadmap/0.5.3/dot-to-underscore.md`

**Goal**: remove `.` from the identifier character set and rename every dotted standard
library name to its underscore form (`num.abs` -> `num_abs`), so `.` is free to become a
member access operator in later releases.

**Constraint for this session**: the full test suite must **not** be run. Only individual
tests written or touched in this session may be executed. The user runs the full suite at
the end.

---

## Verified baseline

Measured against the working tree before any change (all figures reproduced, not copied
from the spec):

| Fact                                                       | Verified |
| ---------------------------------------------------------- | -------- |
| Standard library declares 316 names, 296 dotted, 27 prefixes | yes      |
| Substituting `.` -> `_` yields zero collisions in the library | yes      |
| 20 undotted names: 17 operators + `debug`, `if`, `try`       | yes      |
| `isIdentifier` has exactly one consumer (`IdentifierState`)  | yes      |
| Web stub strings: 16 file + 11 directory + 2 env + 1 console = 30 | yes |
| Non-declaration dotted strings elsewhere in `lib/`: none     | yes      |
| `test/**/*.dart`: 11,790 library names **inside** string literals | yes |
| `test/**/*.dart`: 298 library names **outside** string literals (Dart code — must not be touched) | yes |
| `test/**/*.dart`: 246 residual dotted tokens inside literals needing hand review | yes |
| `test/**/*.prm`: 19 files, 92 library + 57 user-defined occurrences | yes |
| `docs/lang/`: 1,214 · `docs/dev/architecture/`: 167 · `docs/dev/roadmap/`: 136 dotted tokens | yes |
| `README.md`: 1 library name (`num.pow`, line 106) + 2 grammar regexes | yes |
| `CHANGELOG.md`: 108 — left intact                            | yes      |

**Deviation from spec, noted**: the spec says `README.md` has "0 library names". It has
one (`num.pow` at `README.md:106`). It gets renamed with the rest.

**Explicitly out of scope** (spec §"The rule is lexical only"): name validation in
`RuntimeFacade.renameFunction` / `defineFunction`. `:rename foo a.b` still succeeds.

**Not part of this feature**: the `pubspec.yaml` / `main_cli.dart` version bump from
`0.5.2` to `0.5.3`. That belongs to the `prepare-release` skill. The CHANGELOG entry *is*
part of this feature because the spec requires it.

---

## Phase 0 — Migration tooling

The `.prm` migrator ships. The doc/test sweeper is a one-shot internal script and lives in
the scratchpad, never in the repo.

### 0.1 `scripts/migrate_dots.dart` (shipped)

- [x] Create `scripts/migrate_dots.dart` with a scanner that mirrors the **pre-change**
      lexing rules and classifies each character as one of: code, identifier, number,
      string, line comment, block comment.
  - Identifier: starts with a letter, continues while letter/digit/`.`/`_`.
  - Number: starts with a digit; consumes digits, `_`, one `.` into a decimal part, and
    `e`/`E` exponents — so `1.5` and `1.5e3` are never rewritten.
  - String: `'` and `"` delimited, backslash escapes consumed as a pair.
  - Comments: `//` to end of line; `/* ... */` non-nested (matching
    `StartMultiLineCommentState` / `ClosingMultiLineCommentState`).
- [x] Rewrite `.` -> `_` **only** within identifier spans.
- [x] Collision detection: before writing, collect (a) every name the file defines after
      rewriting and (b) every standard library name after rewriting. Refuse the file with
      a diagnostic naming the offending identifier when a rewritten name collides with a
      library name, or when two distinct source names collapse onto the same new name.
- [x] Report a per-file count of rewritten dots; print a total.
- [x] CLI: accept file and/or directory arguments, recurse into directories for `*.prm`,
      support `--dry-run`, exit non-zero when any file is refused.
- [x] Keep the logic in top-level testable functions so the test can import the file
      directly by relative path (no new `lib/` code — this is a dev tool, and adding it to
      `lib/` would pull it into the web build).
- [x] Hard-code the standard library name table by importing
      `package:primal/compiler/library/standard_library.dart` rather than duplicating a
      list, so the tool cannot drift from the library.

### 0.2 Internal sweep script (scratchpad only, not committed)

- [x] Write a Dart-aware sweeper that finds string-literal *content* spans in `.dart`
      files, excluding `$identifier` and `${...}` interpolation regions (which are Dart
      code, e.g. `'${tempDir.path}/x'`), and rewrites only exact matches of the 296-name
      table inside those spans.
- [x] Write a Markdown sweeper that rewrites exact matches of the 296-name table.
- [x] Write a residual reporter that lists every remaining dotted token inside `.dart`
      string literals and in `.md` files, for hand review.

---

## Phase 1 — Compiler changes

- [x] `lib/extensions/string_extensions.dart:104` —
      `bool get isIdentifier => isLetter || isDigit || isUnderscore;` (drop `isDot`).
      Leave `isDot` itself in place: `IntegerState` depends on it.
- [x] `lib/main/main_cli.dart:25` — `const String testPrefix = 'test_';`
- [x] `lib/main/main_cli.dart:38` — help text `Run the "test." functions in a file`
      -> `test_`.
- [x] `lib/main/main_cli.dart:221` — doc comment `` the `test.` functions `` -> `` `test_` ``.
- [x] `lib/main/main_cli.dart:20` — doc comment on `testPrefix` still reads correctly.

---

## Phase 2 — Standard library rename (`lib/`)

Scripted, but confined to `lib/compiler/library/**` and `lib/compiler/platform/**`. The
table-driven sweep must **never** run over the rest of `lib/`: `function.name`,
`function.parameters`, `file.read`, `set.add`, `map.containsKey` and friends are also
ordinary Dart member expressions here.

- [x] Rewrite the 296 dotted `name:` string literals under `lib/compiler/library/**`
      (one per file), matching only on the `name:` declaration line.
- [x] Verify exactly 296 files changed and that the 20 undotted names are untouched.
- [x] Rewrite the 30 `UnimplementedFunctionWebError` strings:
  - `lib/compiler/platform/file/platform_file_web.dart` (16)
  - `lib/compiler/platform/directory/platform_directory_web.dart` (11)
  - `lib/compiler/platform/environment/platform_environment_web.dart` (2)
  - `lib/compiler/platform/console/platform_console_web.dart` (1)
- [x] Do **not** rename any Dart file or class. `num.asDegrees` -> `num_asDegrees` still
      lives in `num_as_degrees.dart`; this mismatch is intentional per the spec.
- [x] Re-extract the name table from `lib/` and confirm: 316 names, 0 containing `.`,
      0 duplicates.
- [x] `dart analyze lib` is clean.

---

## Phase 3 — `test/**/*.prm`

- [x] Run `scripts/migrate_dots.dart --dry-run` over `test/resources/` and review the
      report (expect ~149 rewrites across 20 files; `gcd_lcm.prm` has none).
- [x] Confirm no file is refused for a collision. If one is, resolve it by hand and record
      the resolution here.
- [x] Apply the migration.
- [x] Spot-check that `test/resources/samples/binary_search.prm:2` still reads `i.e.` in
      its comment (the tool must not touch comments).
- [x] Confirm `test/resources/sample.prm` now declares 14 `test_*` functions
      (`test_greeting` ... `test_factorial_negative`), all still matched by the `test_`
      prefix.

---

## Phase 4 — `test/**/*.dart`

### 4.1 Table-driven sweep of string literals

- [x] Run the sweeper over all 85 `.dart` files under `test/`, rewriting only the
      296-name table inside string literal content, excluding interpolations.
- [x] Confirm the rewrite count is 11,790 and that the 298 out-of-literal occurrences
      (`path.join`, `stack.peek`, `console.write`, `file.path`, `directory.path`, …) are
      untouched.
- [x] `dart analyze test` is clean.

### 4.2 Residual hand review (246 occurrences, 86 distinct tokens)

Each residual dotted token inside a string literal falls into one of three buckets.
Walk the generated report and classify every one:

- [x] **Primal identifiers -> rename**: `test.only`, `test.first`, `test.second`,
      `test.third`, `test.zebra`, `test.apple`, `test.stillEqual`, `test.notBoolean`,
      `test.bad`, `test.ok`, `test.x`, `test.helper`, `test.real`, `test.func`,
      `test.greeting`, `test.isOdd`, `test.factorial.negative`, `test.math.addition`,
      `test.parse.invalidNumber`, `fibonacci.helper`, `nfibonacci.helper`,
      `assert.somethingElse`, `math.add`, `my.func`, `lib.func2`, `module.function`,
      `module.submodule.function`, `first.function`, `second.function`, `list.get`,
      `obj.method`, `obj.method_name`, `obj.arr`, `obj.check`, `foo.bar`, `foo.bar.baz`,
      `a.b`, `a.b.c`, `a.b.c.d`, `a.b.c.d.e`, `a.b.d`, `c.d`, `is.even`.
- [x] **Dart identifiers in test descriptions -> leave**: `Compiler.compile`,
      `Compiler.expression`, `Compiler.functionDefinition`, `Console.*`, `Bindings.from`,
      `ValueTerm.from`, `CallExpression.*`, `Lowerer.*`, `Runtime.*`, `ResultState.next`,
      `Type.accepts`, `AnyType.accepts`, `IntermediateRepresentation.empty`.
- [x] **Deliberately arbitrary / data strings -> decide case by case**: `test.function`,
      `exact.function.name`, `\u{1F600}.emoji.function` (`platform_web_test.dart` —
      asserting error text is preserved verbatim; these are runtime strings that never
      reach the lexer, so they stay), plus `name.with.dots`, `key.with.dots`,
      `name_with.special`, `with_special.chars`, `VAR.NAME`, `SPECIAL.CHARS`,
      `archive.tar.gz`, `ss.SSS`, `binary.dat`, `file.TXT`, `file.mp3` and all `*.prm` /
      `*.dart` / `*.txt` filenames.
- [x] For each token in bucket 3 that is a **dotted identifier fed to the lexer**, the
      test now asserts behaviour that no longer exists — convert it to an
      `InvalidCharacterError` expectation or rename it, and record which was chosen.

### 4.3 Tests asserting the deleted behaviour

- [x] `test/extensions/string_extensions_test.dart:330` — flip
      `expect(true, equals('.'.isIdentifier))` to `expect(false, …)`. The `isDot`
      assertion near line 123 stays `true`.
- [x] `test/compiler/lexical_analyzer_test.dart:655` — `'Identifier with dot'` (`is.even`):
      invert to assert `InvalidCharacterError`.
- [x] `test/compiler/lexical_analyzer_test.dart:670` — `'Identifier complex'`
      (`isToday_butNot.31st`): invert or retarget to `isToday_butNot_31st`.
- [x] `test/compiler/lexical_analyzer_test.dart:4722` — `'Identifier with multiple dots'`
      (`a.b.c`): invert to assert `InvalidCharacterError` at column 2.
- [x] Sweep for any other test that asserts a dot lexes as part of an identifier.

---

## Phase 5 — New tests

### 5.1 Lexical (`test/compiler/lexical_analyzer_test.dart`)

- [x] A dotted **call site** `num.abs(1)` raises `InvalidCharacterError` at `[1, 4]`.
- [x] A dotted **definition** `foo.bar(n) = n` raises `InvalidCharacterError` at `[1, 4]`.
- [x] A **leading** dot `.foo(n) = n` still raises `InvalidCharacterError` at `[1, 1]`
      (unchanged behaviour, guards the "consistent rather than new" claim).
- [x] `num_abs`, `foo_`, `foo__bar` lex as single `IdentifierToken`s.
- [x] `_foo` is still rejected (no underscore branch in `InitState`).
- [x] Decimal literal regression: `1.5`, `1.5e3`, `0.5`, `1_000.5` still lex as
      `NumberToken` — guards the `isDot` retention.
- [x] `1..10` still fails with `Invalid character "." … Expected: digit` — the spec is
      explicit that ranges are **not** unblocked by this change.

### 5.2 Extensions (`test/extensions/string_extensions_test.dart`)

- [x] Add an explicit assertion that `'.'.isIdentifier` is `false` while `'.'.isDot` is
      `true`, so the two can never be conflated again.

### 5.3 CLI (`test/compiler/main_cli_test.dart`)

- [x] `primal --test` discovers `test_*` functions and returns 0.
- [x] A file using the old `test.*` names now fails **at the lexer** with
      `InvalidCharacterError`, not with "no functions with the prefix found" — this is the
      guard for the spec's "silent-ish breakage" risk.
- [x] A helper named `test_helper` is still discovered, preserving `startsWith` semantics.

### 5.4 Migration tool (`test/scripts/migrate_dots_test.dart`)

- [x] A user-defined dotted name is rewritten (`piEstimate.helper` -> `piEstimate_helper`).
- [x] A standard library call is rewritten (`num.abs` -> `num_abs`).
- [x] A decimal literal is **not** rewritten (`1.5`, `1.5e3`, `1_000.5`).
- [x] A dot inside a **string literal** is not rewritten (both quote styles).
- [x] A dot inside a **line comment** is not rewritten (`// i.e. foo`).
- [x] A dot inside a **block comment** is not rewritten.
- [x] An escaped quote inside a string does not desynchronise the scanner.
- [x] A file that would produce a name it already defines is **refused** with a diagnostic.
- [x] A file that would produce a standard library name is **refused**.
- [x] A file with no dots is left byte-identical.
- [x] The reported per-file rewrite count is correct.

### 5.5 Integration

- [x] Confirm `function_name` introspection now returns `"list_filter"`; update the
      assertions in `test/runtime/types/introspection_test.dart`.
- [x] Run only the tests touched in this session. Record the commands used.

---

## Phase 6 — Documentation

### 6.1 Table-driven sweeps

- [x] `docs/lang/reference/` (28 pages), `docs/lang/design/` (12 pages),
      `docs/lang/index.md` — 1,214 occurrences.
- [x] `docs/dev/architecture/` — 167 occurrences across 9 of 22 pages.
- [x] Review the diff for prose that reads wrong after substitution (e.g. sentences that
      say "the `list.` prefix").

### 6.2 Normative grammar prose — invisible to any occurrence count

- [x] `README.md:94-95` — **Name** and **Parameters** regex `[a-zA-Z][\w\.]*` ->
      `[a-zA-Z]\w*` (both lines).
- [x] `README.md:106` — `num.pow` -> `num_pow`.
- [x] `docs/lang/design/function-definitions.md:33` — "Contain only letters, digits,
      underscores, or dots" -> drop "or dots".
- [x] `docs/lang/design/function-definitions.md:34` — regex `[a-zA-Z][\w.]*` ->
      `[a-zA-Z]\w*`.
- [x] `docs/lang/design/function-definitions.md:36` — the same for parameters.
- [x] `docs/lang/design/function-definitions.md:43` — `user.getName` under **Valid names**
      must move to **Invalid names** or be replaced.
- [x] `docs/dev/architecture/pipeline/lexical.md:180` — remove "Dots (`.`)" from the
      identifier character list.
- [x] `docs/dev/architecture/pipeline/lexical.md:183` — rewrite "This allows dotted names
      like `math.pi` or `list.head` …". Neither name is real, so no sweep finds them.
- [x] `docs/dev/architecture/pipeline/lexical.md` — document that `isDot` is retained for
      number lexing only, and that a dot in an identifier position raises
      `InvalidCharacterError`.

### 6.3 Test-runner prefix

- [x] `docs/dev/architecture/testing/test-organization.md` — `test.` -> `test_`.
- [x] `docs/dev/architecture/testing/integration-tests.md` — same.
- [x] `docs/lang/index.md`, `docs/lang/reference/core/assert.md`,
      `docs/dev/architecture/pipeline/pipeline.md`, `docs/lang/reference/core/error.md`,
      `docs/dev/architecture/error/error-hierarchy.md` — check each for `test.` runner
      references and update.

### 6.4 Roadmap docs — by hand, 9 files

Blind substitution corrupts these: they mix real library names, **proposed** names absent
from the table, and dots that are *already* member access and must be preserved
(`enum.name(Color.Red)` -> `enum_name(Color.Red)`).

- [x] `docs/dev/roadmap/0.6.0/http.md` — `http.*` (proposed).
- [x] `docs/dev/roadmap/0.6.0/regex.md` — `regex.*` (proposed) + `str.match`.
- [x] `docs/dev/roadmap/0.7.0/enums.md` — `enum.*`, `type.of`; **keep** `Color.Red`,
      `Color.Green`, `Color.Blue`, `Direction.North`.
- [x] `docs/dev/roadmap/0.7.0/option.md` — `maybe.*`, `result.*` (proposed) +
      `list.first`, `list.isEmpty`; leave `i.e` in prose.
- [x] `docs/dev/roadmap/0.7.0/tuples.md` — `tuple.*` (proposed); **keep** `r.name`.
- [x] `docs/dev/roadmap/0.8.0/do.md` — 7 library names.
- [x] `docs/dev/roadmap/0.8.0/try.md` — `error.throw` ×3.
- [x] `docs/dev/roadmap/1.0.0/currification.md` — `list.map`, `list.filter`, `list.reduce`.
- [x] `docs/dev/roadmap/1.0.0/typing.md` — `data.*`, `enum.values` (proposed).
- [x] `docs/dev/roadmap/0.6.0/modules.md`, `0.7.0/record.md`, `0.8.0/destructuring.md`,
      `0.8.0/ranges.md`, `0.9.0/transpilation.md`, `1.0.0/pattern.md` — confirm they need
      no change (`transpilation.md`'s only hits are the filename `script.prm`).
- [x] `docs/dev/roadmap/0.5.3/dot-to-underscore.md` — **leave intact**. It documents the
      before/after and must keep its dotted examples.

### 6.5 CHANGELOG

- [x] Add a `## 0.5.3` entry with a **Breaking** section that states plainly: every dotted
      standard library name is renamed to its underscore form, `.` is no longer valid in
      any identifier, and the `--test` discovery prefix is now `test_`. Point at
      `scripts/migrate_dots.dart`.
- [x] Do **not** rewrite historical entries. The 0.5.2 entry's `assert.equal` etc. is what
      0.5.2 actually shipped.

---

## Phase 7 — Final verification gate

- [x] `dart analyze` (lib + test) is clean.
- [x] `dart format` applied to changed Dart files (`scripts/format.sh` covers `lib` and
      `test`; format `scripts/migrate_dots.dart` explicitly).
- [x] No `.prm` file in the repository contains a dotted identifier.
- [x] No file in `docs/` contains a dotted standard library name, **excluding**:
      `CHANGELOG.md` (history is deliberately intact),
      `docs/dev/roadmap/0.5.3/dot-to-underscore.md` (this feature's own spec), and the
      roadmap pages that legitimately retain member-access dots
      (`0.7.0/enums.md`, `0.7.0/tuples.md`).
- [x] No `name:` declaration in `lib/compiler/library/**` contains a dot.
- [x] Re-extract the name table: 316 names, 0 dotted, 0 duplicates.
- [x] Run the `delta-review` skill over the diff.
- [ ] Hand the suite to the user to run in full, and report exactly which individual tests
      were executed in this session.

### Review findings fixed

The review returned 0 critical, 6 warnings, 6 nits. All six warnings and three
of the nits were reproduced and fixed; three nits were declined with reasons.

| Finding                                                                                  | Fix                                                                          |
| ----------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| **Warning** — two distinct *dotted* names collapsing onto one were not detected (`a.b_c` + `a_b.c` -> `a_b_c`), the exact "error pointing at the wrong cause" the tool exists to prevent | `produced` is now `Map<String, Set<String>>`; more than one spelling is a refusal |
| **Warning** — the test named "Two dotted names collapsing onto one" tested a different, already-covered case | retargeted to two genuinely dotted names, plus a "repeating one name is not a collapse" guard |
| **Warning** — an unrecognised `-` option was silently dropped, so `--dryrun` **rewrote every file** | `knownOptions` allowlist; anything else exits 2 with usage                     |
| **Warning** — no I/O error handling: a permission error aborted the sweep after earlier files were already written | per-file try/catch on read and write, `followLinks: false` on recursion, failures folded into exit 1 |
| **Warning** — an unterminated string or block comment silently swallowed the rest of the file and reported success | `scan()` reports it; `migrate()` refuses with the opening `[row, column]`      |
| **Warning** — `run()` had zero test coverage, including the `if (!dryRun)` write guard    | 8 tests over a temp directory: dry-run writes nothing, recursion, refusal exit 1, missing path exit 2, unknown option exit 2 |
| **Nit** — false refusal on a part-migrated file (`num_abs(-1) + num.abs(-2)`)             | exempted when the produced name is a library name the file does not define    |
| **Nit** — only `\n` treated as a line terminator, but `SourceReader` normalises `\r`      | `_lineEnd` and `_locationOf` handle `\n`, `\r\n` and lone `\r`                 |
| **Nit** — `-h` accepted but undocumented                                                 | added to the `Options:` block                                                 |
| **Nit** — spec says the tool "reuses `SourceReader` scanning rules"; it re-implements them | **declined**: the spec page is deliberately left untouched (Phase 6.4)        |
| **Nit** — `PLAN-dot-to-underscore.md` untracked at the repository root                   | **declined**: explicitly requested at the project root                        |
| **Nit** — `pubspec.yaml`/`main_cli.dart` still `0.5.2` while CHANGELOG announces `0.5.3` | **declined**: version bump belongs to `prepare-release`, flagged to the user  |

Verified clean by the review: the `isIdentifier` change, the `testPrefix` change,
and every hand-edited test (correctly inverted, none neutered). `identifierSpans`
/ `_skipNumber` / `_isDefinitionAt` were confirmed correct for all valid
pre-change source, with no off-by-one, index overrun, infinite loop, or split
surrogate pair.

---

## Findings beyond the spec

Discovered while implementing; each is recorded because the spec's counts and
checklists did not predict it.

| Finding                                                                          | Resolution                                                                     |
| -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `README.md` has 1 library name (`num.pow:106`), not 0                            | renamed with the rest                                                          |
| A **fourth** lexer test asserts the deleted behaviour: `'Identifier with trailing dot'` (`x.`) | inverted to expect `InvalidCharacterError`                        |
| `test.` matched the import string `package:test/test.dart` in two files          | restored; caught immediately as a compile error                                |
| Nested string literals inside `${...}` interpolation are skipped by a span scanner (`RegExp.escape(passLine('test.only'))`) | fixed by hand in `cli_test.dart` and `main_cli_test.dart` |
| `\nfibonacci.helper` — the `\n` escape made a `(?<![\w.])` lookbehind see `n` as a word character | fixed by hand in `samples_test.dart`                        |
| The Markdown sweep corrupted **Dart** code inside fenced ` ```dart ` blocks: `function.name`, `function.parameters`, `path.join`, `test.txt` | restored in 3 architecture docs |
| Doc examples use invented dotted names absent from the table (`string.concat`, `string.length`, `cache.exists`, `database.fetch`, `num.isInteger`, `vector.at`, `vector.length`, `namespace.function`) | rewritten to real or underscored names |
| `<prefix>.*` glob references in prose (`is.*`, `to.*`, `num.*`) are invisible to an exact-name table | 43 rewritten across 5 docs                          |
| `.claude/skills/audit-coverage/SKILL.md` carries library names but is outside `docs/` | renamed; `list.head`/`list.tail` never existed, corrected to `list_first`/`list_rest` |
| Stale test descriptions naming a dead concept: `str.join` (the test calls `list_join`), `set.variable`, and 16 "dot notation" / 4 "namespace" labels | renamed to match what they exercise |

---

## Risks carried into review

- **~12,000-line mechanical diff across `test/`** hides genuine behavioural changes. The
  mitigation is the residual reporter plus the in-literal/out-of-literal split — not diff
  reading.
- **`testPrefix` breakage is quiet.** Missing it produces a plausible-looking user error,
  not a compile failure. Phase 5.3 is the guard.
- **Sweeping Dart code by mistake** breaks the build: `function.name` appears 55 times in
  `lib/`, only once as the Primal declaration. Never run the table outside string
  literals, and never over `lib/` at all.
- **User-side collisions**: `_` was always legal, so a user with `num_abs` gets
  `Cannot redefine standard library function` post-migration. The tool refuses instead.
- **Patch-bump semantics**: 0.5.2 -> 0.5.3 signals a safe upgrade while breaking nearly
  every program. Raised in the spec and explicitly accepted; the CHANGELOG entry is the
  only mitigation.
