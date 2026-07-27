# Implementation Plan — Testing (0.5.2)

Source specification: `docs/dev/roadmap/0.5.2/testing.md`

Five standard-library assertion natives (`assert.equal`, `assert.notEqual`,
`assert.true`, `assert.false`, `assert.throws`) raising a dedicated
`AssertionFailedError`, plus a CLI test mode (`primal --test file.prm`) that
discovers zero-argument `test.*` functions, runs them in source order, and
classifies each result as pass, fail or error. `runCli` gains an exit-code
contract; failing non-test runs now exit `1` instead of `0`.

---

## 0. Decisions Taken Where The Spec Leaves A Gap

These are the only places the specification does not fully determine the
implementation. Each is recorded here so it can be challenged.

- [x] **Shared value renderer.** §4.4 requires every helper *and* the CLI runner
      to render a `Term` through `Runtime.format` under a guard that falls back
      to `term.toString()`. Rather than duplicating that guard six times, add
      `static String render(Term term)` to `Runtime` (the renderer's own home;
      `runtime.dart` already imports `term.dart`). This is one method beyond the
      spec's literal "promote `format` to `static`".
- [x] **`RuntimeFacade._runtime` is removed.** Once both call sites use
      `Runtime.format(...)`, the private field is unused and the analyzer flags
      it. `Runtime`'s instance surface (`input`, `reduceTerm`) is left untouched.
- [x] **"No tests discovered" means no `test.` prefix at all.** A file whose only
      `test.*` functions take parameters reports each skip and summarises
      `N tests: N skipped` (exit `2`) rather than also printing the
      "no tests found" line. Both paths exit `2`; only the message differs.
- [x] **Exit-code precedence: `2` beats `1`.** A run with both a skipped `test.*`
      and a failing test exits `2` — `2` means "the run did not measure what it
      claimed to", which subsumes the failure report.
- [x] **An abort prints the summary too.** §4.7 says the partial report is
      printed before returning `2`. Per-test lines are printed as they complete;
      on abort the runner also prints the blank line and the summary of what was
      collected, then the abort message on stderr.
- [x] **Usage-error texts** (not fixed by the spec), both on stderr with the
      runner's literal `Error: ` prefix:
      - `Error: --test cannot be combined with --watch.`
      - `Error: --test requires exactly one file argument.`

---

## 1. Errors — `lib/compiler/errors/runtime_error.dart`

- [x] Change `RuntimeError`'s constructor to
      `const RuntimeError(String message, {String category = 'Runtime error'}) : super(category, message);`
      (default-valued, so all existing subclasses compile untouched).
- [x] Add `AssertionFailedError extends RuntimeError`:
      - constructor `({required String function, required String actual, required String expected})`
      - `super('"$function" failed: expected $expected, actual $actual', category: 'Assertion error')`
      - stores **no** fields (§4.4).
- [x] Add `AssertionArgumentError extends RuntimeError`:
      - constructor `AssertionArgumentError(InvalidArgumentTypesError cause) : super(cause.message)`
      - inherits the `'Runtime error'` category, so it renders byte-identically
        to the error it wraps.
- [x] Place both after `RecursionLimitError`, keeping file order stable.

## 2. Renderer — `lib/compiler/runtime/runtime.dart`

- [x] Promote `format`, `getList`, `getSet` and `getMap` to `static` (all four,
      since `format` delegates to the other three).
- [x] Add `static String render(Term term)`: returns
      `format(term.native()).toString()`, falling back to `term.toString()` when
      either `native()` or `format` throws (§4.4, "rendering must not escape").

## 3. Lowering — `lib/compiler/lowering/runtime_facade.dart`

- [x] `evaluate`: `_runtime.format(...)` → `Runtime.format(...)`.
- [x] `format`: `_runtime.format(value)` → `Runtime.format(value)`.
- [x] Delete the now-unused `_runtime` field and its initializer.
- [x] No behaviour change; the existing `RuntimeFacade.evaluate` / `format`
      tests are the regression guard.

## 4. Assertion Natives — `lib/compiler/library/assert/`

All five follow the two-class native pattern (`NativeFunctionTerm` +
`NativeFunctionTermWithArguments`), declare parameters `a` (and `b`), return
`BooleanTerm(true)` on success and never return `false`.

- [x] `assert_equal.dart` — `class AssertEqual`, `assert.equal(a: Equatable, b: Equatable)`
      1. reduce `a`, then `b`
      2. `CompEq.execute(function: this, a: a, b: b)` (passing `this` attributes
         type errors to `assert.equal`)
      3. `InvalidArgumentTypesError` → rethrow as `AssertionArgumentError`
      4. `true` → `BooleanTerm(true)`; `false` → `AssertionFailedError`
         (`expected: render(b)`, `actual: render(a)`)
      5. every other error propagates unchanged
- [x] `assert_not_equal.dart` — `class AssertNotEqual`, `assert.notEqual(a: Equatable, b: Equatable)`
      - `CompNeq.execute` returns `Term`, so **narrow** to `BooleanTerm` rather
        than assuming it
      - failure message uses `expected: 'not ${render(b)}'`
- [x] `assert_true.dart` — `class AssertTrue`, `assert.true(a: Boolean)`
      - non-boolean → `AssertionArgumentError(InvalidArgumentTypesError(function: name, expected: parameterTypes, actual: [a.type]))`
      - `false` → `AssertionFailedError(expected: 'true', actual: render(a))`
- [x] `assert_false.dart` — `class AssertFalse`, `assert.false(a: Boolean)`, the mirror
- [x] `assert_throws.dart` — `class AssertThrows`, `assert.throws(a: Any)`
      - reduce `arguments[0]` **inside** the guarded region
      - clause order: `on AssertionFailedError` / `on AssertionArgumentError` /
        `on RecursionLimitError` (all `rethrow`) **before** `on RuntimeError`
        (`return BooleanTerm(true)`)
      - non-`RuntimeError` is not caught at all
      - the "completed normally" `AssertionFailedError`
        (`expected: 'a thrown error'`, `actual: render(outcome)`) is thrown
        **after** the guarded region — throwing it inside would let the native's
        own `on RuntimeError` swallow it and make `assert.throws(42)` pass

## 5. Standard Library — `lib/compiler/library/standard_library.dart`

- [x] Add the five imports (alphabetically between `arithmetic/` and `base64/`).
- [x] Add an `// Assert` section between `// Arithmetic` and `// Casting`,
      entries alphabetical by class: `AssertEqual`, `AssertFalse`,
      `AssertNotEqual`, `AssertThrows`, `AssertTrue`.
- [x] No semantic-analyzer change — signatures are auto-derived (§2.5).
- [x] Confirm the registry count goes 311 → 316.

## 6. CLI — `lib/main/main_cli.dart`

### Exit-code contract (§4.8)

- [x] `runCli` returns `int`; `main` becomes `void main(List<String> args) => exitCode = runCli(args);`
- [x] `exit()` is never called inside `runCli`.
- [x] Returns: `--help` / `--version` → `0`; successful non-test run → `0`;
      watch started → `0` (returned immediately, listener keeps the process
      alive); REPL → `0`; watch-mode usage errors → `2`; the catch-all → `1`
      (**behaviour change**: failing runs used to exit `0`).

### `--test` mode (§4.7)

- [x] Parse `--test` / `-t` alongside the existing flags (position-independent).
- [x] `--test` + `--watch` → usage error, `2`.
- [x] `remainingArgs.length != 1` → usage error, `2`.
- [x] `--test` + `--debug` allowed.
- [x] Dispatch to `_runTests(...)` **before** the pre-existing `try`, so the
      runner owns its own error boundary.
- [x] `_runTests`:
      - build step (file read + compile + `RuntimeFacade`) inside the runner's
        own `try`; any throwable → print on stderr, return `2` (with the debug
        stack trace when `--debug`)
      - print `[debug] Compilation: Nms` first, verbatim format
      - print compilation warnings
      - never execute `main`; never fall through to the REPL
      - discover `intermediateRepresentation.customFunctions.values` whose name
        starts with `test.`, in source order (`Map` preserves insertion order)
      - no `test.` function at all → stderr
        `Error: no zero-argument functions with the "test." prefix found in <file>`, return `2`
      - a `test.*` with parameters → skipped, counted, stderr
        `Error: skipped "<name>" — test functions must take no parameters`
      - each runnable test: `compiler.expression('<name>()')` then
        `runtime.evaluateToTerm(expression)` (not `evaluate` — classification
        must read the `Term`, and `evaluateToTerm` resets recursion depth)
      - classification: `BooleanTerm(true)` → pass; `AssertionFailedError` →
        fail; any other `RuntimeError` → error; any other term → error with
        `test "<name>" did not return true (returned <value>)`; non-`RuntimeError`
        → abort
      - output: `'${status.padRight(5)} $name'` on stdout, error detail indented
        six spaces on the following line, `--debug` appends ` [Nms]` measured
        around `evaluateToTerm`
      - blank line, then the summary: `1 test:` / `N tests:` followed by the
        non-zero categories in the order `passed`, `failed`, `error`, `skipped`;
        skipped tests are counted
      - abort: print the collected lines + summary on stdout, then the test name
        and throwable on stderr, return `2`
      - exit code: `2` if usage/build/no-tests/skipped/abort, else `1` if any
        fail or error, else `0`
- [x] Results use `Console.print` (stdout), skips/aborts/errors use
      `Console.error` (stderr) — no new `Console` method.

### Help text

- [x] Add `--test, -t       Run test functions in a file` to `helpText`.
- [x] Add a `primal -t program.prm   Run the tests in a file` example line.

---

## 7. Documentation (`docs/` and root)

- [x] **New** `docs/lang/reference/core/assert.md` — frontmatter, TLDR, function
      count, one entry per helper (signature, input, output, purity, example),
      plus the failure/error distinction, the `assert.throws` narrowing rules and
      the abstraction limitation.
- [x] `docs/lang/index.md` — link the new page under **Core**.
- [x] `docs/lang/reference/core/error.md` — cross-reference
      `AssertionFailedError` and `AssertionArgumentError`.
- [x] `docs/lang/design/lazy-evaluation.md` — document that `assert.throws`
      cannot be abstracted behind a custom function (§6.3), alongside the
      existing `if`/`try` laziness discussion.
- [x] `docs/dev/architecture/error/error-hierarchy.md` — the two new error types,
      `RuntimeError`'s optional `category` parameter (the hierarchy is no longer
      "one category per base class"), and a note that `AssertionArgumentError`
      is a recognisability wrapper rendering identically to what it wraps.
- [x] `docs/dev/architecture/runtime/native-functions.md` — `Runtime.format` is
      `static`, and is how a native reaches the shared renderer.
- [x] `docs/dev/architecture/pipeline/pipeline.md` — corrected standard-library
      count (316), new `assert.*` namespace row, runtime-error table entries,
      the reserved `test.` prefix policy, and the CLI entry-point section
      (`--test`, exit codes).
- [x] `docs/dev/architecture/testing/integration-tests.md` — how `--test` mode is
      covered (in-process via `runCli`'s return value, subprocess via real exit
      codes and per-stream assertions).
- [x] `CHANGELOG.md` — a `0.5.2` section: *Added* for the five assertions and
      `--test`; **Changed** for the exit-code contract.
- [x] `README.md` — no change (it does not list CLI flags).

## 8. Tests (`test/`)

Constraint for this session: run only the newly written tests, never the whole
suite.

### Runtime level — **new** `test/runtime/core/assert_test.dart`

- [x] Each helper: success, failure, argument type error.
- [x] Declared parameters are `a` (and `b`), asserted through `function.parameters`.
- [x] `assert.equal`: `1` vs `1.0` passes; cross-type is an **error** naming
      `assert.equal` (not `comp.eq`); unequal-length collections **fail**;
      equal-length lists with mismatched element kinds **error**; maps with
      mismatched **value** kinds **error**; sets with mismatched element kinds
      and maps with mismatched **key** kinds **fail** (written with
      `set.new([…])`, since `{…}` is map syntax).
- [x] `assert.equal("3", "2")` fails with `expected "2", actual "3"` — the quotes
      prove rendering goes through `Runtime.format`, not `Term.toString()`.
- [x] `assert.equal(to.number("x"), 1)` propagates the `ParseError` unchanged.
- [x] `assert.notEqual`: the inverted matrix, plus the two non-inversions — a
      type mismatch is an **error**, and `assert.notEqual(1, 1.0)` **fails**; its
      type error names `assert.notEqual`; the `not ` prefix appears in the message.
- [x] `assert.throws`: custom error caught; `assert.throws(42)` **fails** (the
      direct guard on catch ordering); nested `assert.equal(1, 2)` rethrown as a
      fail; `RecursionLimitError` rethrown; non-`RuntimeError` rethrown.
- [x] The matched misuse pair: `assert.throws(assert.true(1))` and
      `assert.throws(assert.equal("1", 1))` are **errors**, while
      `assert.throws(num.add(1, "x"))` **passes**.
- [x] `try(assert.equal(1, 2), true)` passes — `try`'s catch-all swallows
      assertions (§6.7).
- [x] `&&` chaining of several assertions in one expression.
- [x] A value whose rendering throws yields a **fail** with the `toString()`
      fallback, not an abort.

### Error level — `test/errors/error_formatting_test.dart`

- [x] `AssertionFailedError.toString()` starts with `Assertion error:` and uses
      the exact `"<function>" failed: expected <expected>, actual <actual>` body.
- [x] `AssertionArgumentError.toString()` is byte-identical to the
      `InvalidArgumentTypesError` it wraps.
- [x] Regression guard: other `RuntimeError` subclasses still start with
      `Runtime error:`.

### Compiler level — `test/compiler/semantic_analyzer_test.dart`

- [x] A user function named exactly `assert.equal` fails with
      `DuplicatedFunctionError` (not `CannotRedefineStandardLibraryError`).
- [x] Counter-case: `assert.somethingElse()` still compiles — only whole names
      collide, and `assert.` is not reserved.

### CLI level, in-process — `test/compiler/main_cli_test.dart`

- [x] Discovery of zero-argument `test.*` functions; source order preserved.
- [x] `main` is not executed and there is no REPL fallthrough when `main` is absent.
- [x] All three classifications plus the non-`true` return case, asserted against
      the exact output format: `PASS`/`FAIL`/`ERROR` prefix, six-space indented
      detail line, the exact `test "<name>" did not return true (returned <value>)`
      text, and the summary counts.
- [x] A test returning the *string* `"true"` is an **error**, not a pass.
- [x] Singular and plural summaries: `1 test: 1 passed`, `3 tests: 3 passed`.
- [x] Skipped `test.*` with parameters: reported on stderr, counted, summary
      `2 tests: 1 passed, 1 skipped`, exit `2`.
- [x] No tests found → `2`; compile error under `--test` → `2`; unreadable file
      → `2`.
- [x] `--test` + `--watch` → `2`; `--test` with no file → `2`; `--test` with
      multiple files → `2`.
- [x] `--test` written after the file path; `--test` with `--debug` in both
      orders (compile timing and per-test `[Nms]`).
- [x] `--help` lists `--test` and `-t`.
- [x] Stdout/stderr asserted **per stream**, never against one interleaved
      transcript.
- [x] Every row of the `runCli` table: help/version `0`, successful run `0`,
      REPL `0` (including a session whose last input raised an error), watch
      usage errors `2`, and the **changed** row — a non-test run whose program
      fails returns `1`.
- [x] **Deviation — no in-process "watch started" test.** A successful watch
      start leaves a live `FileSystemEvent` subscription and a SIGINT handler in
      the test isolate, which risks hanging `dart test`. The existing suite
      already avoids this (`watch mode validation` covers only the two error
      cases), and the subprocess suite starts a watch process without awaiting
      it. Followed that precedent rather than adding a hang risk.

### CLI level, subprocess — `test/compiler/cli_test.dart`

- [x] `primal --test` on a passing file exits `0` with the expected stdout.
- [x] A failing test exits `1`; a skipped `test.*` exits `2`; a compile error
      under `--test` exits `2`; a nonexistent file under `--test` exits `2`.
- [x] A failing **non-test** run now exits `1` (the breaking change, observed
      through a real process).
- [x] `--help` output lists `--test`.

## 9. Post-Review Corrections

Applied after `delta-review` (0 critical, 1 warning, 5 nits):

- [x] **Warning — over-wrapping.** `CompEq.compareLists`/`compareMaps` reduce
      collection elements lazily, so a type error from the *code under test*
      surfaced at the same `catch` as a genuine element-kind mismatch and was
      rewrapped as `AssertionArgumentError` — making
      `assert.throws(assert.equal([num.add(1, "x")], [2]))` an **error** instead
      of a pass, exactly the over-correction §6.9 argues against.
      `InvalidArgumentTypesError` now retains a `function` field, and the
      helpers wrap only errors whose `function` is their own name. Both
      directions are pinned by new tests.
- [x] **Abort on the first test printed `0 tests: 0 passed`.** A green-reading
      summary for a run that measured nothing. `_printTestSummary` now returns
      early when nothing was collected; the `categories.isEmpty` fallback is gone.
- [x] **`Runtime`'s instance surface was dead.** With `RuntimeFacade._runtime`
      removed, `input`, the public constructor and `reduceTerm()` were
      unreachable (`unused_field` only catches private fields). All three
      deleted; `Runtime` is now a documented static-only renderer. This
      supersedes the decision in [§0](#0-decisions-taken-where-the-spec-leaves-a-gap).
- [x] **`_testLine` used positional parameters** while every sibling in the file
      uses required named ones. Converted.
- [x] **Not changed — "no zero-argument functions…" message.** The wording is
      pinned verbatim by spec §5.3, and the case it under-describes (only
      parameterised `test.*` functions) reports the skips instead. Recorded in
      [§0](#0-decisions-taken-where-the-spec-leaves-a-gap).
- [x] **Not changed — version drift.** `version` in `main_cli.dart` and
      `pubspec.yaml` are still `0.5.1` while `CHANGELOG.md` now has a `0.5.2`
      section. Bumping the version belongs to `prepare-release`, not to this
      feature.

### Verification

- [x] `dart analyze` clean.
- [x] `dart format` applied to touched files.
- [x] Run only the new/changed test files individually.
- [x] Run `delta-review` before reporting.
