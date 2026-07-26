---
title: Testing
tags:
  - roadmap
  - stdlib
  - testing
sources:
  - lib/compiler/runtime/term.dart
  - lib/compiler/library/control/try.dart
  - lib/compiler/library/control/if.dart
  - lib/compiler/library/error/throw.dart
  - lib/compiler/library/comparison/comp_eq.dart
  - lib/compiler/library/logic/bool_and.dart
  - lib/compiler/library/operators/operator_double_and.dart
  - lib/compiler/errors/runtime_error.dart
  - lib/compiler/errors/semantic_error.dart
  - lib/compiler/lexical/lexical_analyzer.dart
  - lib/compiler/syntactic/syntactic_analyzer.dart
  - lib/compiler/semantic/semantic_analyzer.dart
  - lib/compiler/semantic/intermediate_representation.dart
  - lib/compiler/lowering/runtime_facade.dart
  - lib/compiler/warnings/semantic_warning.dart
  - lib/extensions/string_extensions.dart
  - lib/main/main_cli.dart
---

# Testing

**TLDR**: Five standard-library assertion functions (`assert.equal`, `assert.notEqual`, `assert.true`, `assert.false`, `assert.throws`) that raise a dedicated `AssertionFailedError`, paired with a CLI test mode (`primal --test file.prm`) that discovers zero-argument `test.*` functions, runs them in source order, and classifies each result as pass, fail, or error.

This specification adds a testing workflow to Primal without introducing any new
syntax. Assertions are ordinary native functions; tests are ordinary
zero-argument function definitions; discovery is a naming convention enforced by
the CLI, not by the compiler.

## 1. Feature Intent

Primal is expression-oriented and has no statement sequencing, so a program
cannot run many assertions one after another inside `main()`. The feature
therefore has two halves:

- **An assertion library** — helpers that express test expectations in Primal
  itself and signal failure through the runtime error system.
- **A CLI test runner** — a mode that compiles one file, discovers
  zero-argument functions whose names begin with `test.`, executes them
  independently, and reports results.

`assert.throws` is the only helper that adds capability the language does not
already have. The other four are ergonomic shorthands (see
[§3.1](#31-overlap-with-existing-constructs)), and the runner is what makes any
of it usable in a real project.

## 2. Confirmed Observations

Every claim below was verified against the current implementation.

### 2.1 Dotted Names Lex As Single Identifiers

`isIdentifier` accepts letters, digits, dots, and underscores
(`lib/extensions/string_extensions.dart`), and keyword classification compares
the **whole** lexeme (`isBoolean => this == 'true' || this == 'false'`;
`_identifierOrKeywordToken` in `lib/compiler/lexical/lexical_analyzer.dart`).

Consequently `assert.true`, `assert.false`, and `test.math.addition` each
produce a single `IdentifierToken`. There is **no keyword conflict** with the
`true`/`false` literals, and no lexer change is required.

### 2.2 Native Functions Receive Unreduced Arguments

`FunctionTerm.apply` is `substitute(bindings).reduce()`, and
`NativeFunctionTerm.substitute` binds argument terms without reducing them
(`lib/compiler/runtime/term.dart`). Only `CustomFunctionTerm.apply` and
`LambdaTerm.apply` force call-by-value.

Native functions are therefore **lazy in their arguments by default** — this is
exactly how `if` and `try` implement short-circuiting. Laziness inside a native
assertion costs nothing. See
[[dev/architecture/runtime/native-functions]] and
[[dev/architecture/runtime/thunks-and-lazy-evaluation]].

The converse also holds and is a hard constraint: an assertion **cannot** be
written as a Primal-level custom function, because the argument would be
reduced at the call boundary before the body ever runs (see
[§6.3](#63-assertthrows-cannot-be-abstracted)).

### 2.3 `try` Catches Every Throwable

`Try.reduce()` is `try { a.reduce() } catch (_) { b.reduce() }`
(`lib/compiler/library/control/try.dart`). The bare `catch (_)` intercepts every
Dart throwable, not just `RuntimeError` — including `RecursionLimitError`,
`StackOverflowError`, `StateError`, and any interpreter defect.

"Behaves like `try`" is therefore a much wider contract than it appears, and
this specification deliberately does not adopt it for `assert.throws`
(see [§3.3](#33-assertthrows-is-narrower-than-try)).

### 2.4 Errors Carry No Inspectable Payload

`error.throw(code: Any, message: String)` raises
`CustomError(Term code, String message)`
(`lib/compiler/library/error/throw.dart`), and `try(a, b)` discards the caught
error entirely. Primal code cannot read an error's code or message today, so an
error's identity is only meaningful to the Dart-side runner. Typed catch and an
optional `error.throw` message are planned in [[dev/roadmap/0.8.0/try]].

### 2.5 Standard-Library Signatures Are Auto-Derived

`standardLibrarySignatures` is built from `StandardLibrary.getSignatures()`
(`lib/compiler/semantic/semantic_analyzer.dart`). Registering a native in the
standard library automatically supplies its signature to arity checking, so
**semantic analysis requires no change**.

### 2.6 Native Parameter Types Are Not Enforced Generically

`NativeFunctionTerm.substitute` performs no type validation; every native
validates its arguments by hand inside `reduce()` (`if.dart`, `throw.dart`,
`comp_eq.dart`). Declared `Parameter` types are metadata used for introspection
and error messages only. Each assertion must perform its own type checks. See
[[dev/architecture/typing/runtime-type-checking]].

### 2.7 Equality Semantics

`CompEq.execute` (`lib/compiler/library/comparison/comp_eq.dart`) throws
`InvalidArgumentTypesError` when the two operands are of different kinds, but
returns `false` for same-kind collections of differing length. Numeric
comparison uses Dart's `num ==`, so `1 == 1.0` is `true`.

### 2.8 `&&` Short-Circuits

`OperatorDoubleAnd` delegates to `BoolAnd.execute`, which reduces the second
argument only when the first is `true`
(`lib/compiler/library/operators/operator_double_and.dart`,
`lib/compiler/library/logic/bool_and.dart`).

What lets a single-expression test body hold several assertions is **left-to-right
reduction**, not short-circuiting: assertions never return `false`
([§4.3](#43-assertion-functions)), so the short-circuit branch is unreachable on
success and strict `&` would chain them identically. Short-circuiting matters
only on failure — the first assertion to throw prevents the rest from running,
so a test reports one failure at a time.

### 2.9 The CLI Has No Exit-Code Contract

`runCli` returns `void` and never sets an exit code
(`lib/main/main_cli.dart`); a program that throws prints in red and the process
still exits `0`. `exit()` is called only for `:quit` and SIGINT. `runCli` is
also unit-tested in-process with a fake console
(`test/compiler/main_cli_test.dart`), so calling `exit()` inside it would
terminate the test runner.

Adding exit codes therefore requires changing `runCli` to return `int` and
having `main` assign `exitCode`.

### 2.10 Miscellaneous

- Zero-argument function definitions parse today (`main()` is one).
- `customFunctions` is a `Map` populated in source order during semantic
  analysis, so declaration order is available at no cost.
- No "unused function" warning exists — only unused-parameter warnings
  (`lib/compiler/warnings/semantic_warning.dart`). `test.*` functions will not
  produce warnings in a normal run.
- `RuntimeFacade.evaluateToTerm` calls `FunctionTerm.resetDepth()`, so
  evaluating each test through the facade isolates recursion depth for free.
- Defining a function whose name collides with the standard library is a compile
  error, but the error is `DuplicatedFunctionError`, raised by
  `SemanticAnalyzer.analyze` (`lib/compiler/semantic/semantic_analyzer.dart`).
  `CannotRedefineStandardLibraryError` is a **different** path: it is thrown only
  by `RuntimeFacade.defineFunction`, i.e. when a name is redefined interactively
  in the REPL.

## 3. Design Decisions And Rationale

This section records where the specification departs from the first draft of
this document, and why.

### 3.1 Overlap With Existing Constructs

Four of the five helpers are already expressible:

```primal
assert.true(c)        ≡  if (c) true else error.throw("assertion", "…")
assert.false(c)       ≡  if (!c) true else error.throw("assertion", "…")
assert.equal(a, b)    ≡  if (a == b) true else error.throw("assertion", "…")
assert.notEqual(a, b) ≡  if (a != b) true else error.throw("assertion", "…")
```

Only `assert.throws` adds capability, because it cannot be written in Primal at
all ([§2.2](#22-native-functions-receive-unreduced-arguments)). The assertions
are ergonomics; the runner is the feature. The surface stays deliberately small —
five functions, no variants.

`assert.notEqual` earns its place on the same ground as `assert.equal`: the
alternative, `assert.true(a != b)`, collapses both operands into a single boolean
before the assertion sees them, so its failure message can only say "expected
true, actual false". `assert.notEqual` keeps the values and reports them
([§4.4](#44-failure-representation)). It is a genuine widening of the surface
this section otherwise argues against — accepted deliberately, because inequality
is a common enough expectation that users would otherwise reach for the
diagnostically blind form.

### 3.2 No `message` Parameter

**Decided — the parameter is dropped.** The first draft gave every helper a
mandatory, lazily evaluated `message` argument. This specification removes it and
auto-generates failure text instead.

- The language has no optional parameters, no variadic parameters, and no
  overloading (functions are keyed by name in a `Map<String, FunctionTerm>`), so
  a message parameter can only be **mandatory** — verbose at every call site.
- A user-supplied string cannot report actual versus expected, which is the only
  reason to prefer `assert.equal(a, b)` over `assert.true(a == b)`. An
  auto-generated message can, and does.
- Lazy messages make message type errors path-dependent: `assert.false(true, 123)`
  raises `InvalidArgumentTypesError`, but `assert.false(false, 123)` passes
  silently with a malformed message. Removing the parameter removes the hazard.

Trade-off, stated plainly: per-assertion labels are lost inside a `&&` chain.
The failing test's name plus the generated message must carry the diagnosis.
Custom messages remain available with no new machinery via the `if` /
`error.throw` form above.

### 3.3 `assert.throws` Is Narrower Than `try`

Adopting `try`'s catch-all ([§2.3](#23-try-catches-every-throwable)) would mean
`assert.throws(assert.equal(1, 2))` **passes**, and that an interpreter defect
inside the asserted expression is reported as a successful test. This
specification catches `RuntimeError` only, and never `AssertionFailedError`.

### 3.4 A Dedicated Error Type, Not A Magic Code

The first draft represented failure as `error.throw("assertion", message)`, on
the grounds that reusing `CustomError` is more consistent than a new error type.
The codebase does the opposite: `lib/compiler/errors/runtime_error.dart` defines
a dedicated `RuntimeError` subclass per failure category. A magic string code is
also:

- **forgeable** — user code calling `error.throw("assertion", "x")` would be
  classified as a test _failure_ rather than an _error_, with no way for the
  runner to tell them apart;
- **diagnostically empty** — `CustomError` carries only the user's string, so
  actual and expected values cannot be reported.

This specification adds `AssertionFailedError extends RuntimeError`. See
[[dev/architecture/error/error-hierarchy]].

### 3.5 Discovery Is A Runner Concern

Test discovery reads `IntermediateRepresentation.customFunctions` after
compilation. It belongs to the CLI, not to semantic analysis — the semantic
analyzer needs no change whatsoever
([§2.5](#25-standard-library-signatures-are-auto-derived)).

### 3.6 Source Order, Not Lexicographic Order

`customFunctions` already preserves declaration order, so source order is
deterministic, free, and correlates directly with the file. Sorting adds work
for no benefit and makes ordering ASCII-dependent (`test.A` before `test.a`).

## 4. Specification

### 4.1 Scope

Add five standard-library functions:

```primal
assert.equal(actual, expected)
assert.notEqual(actual, expected)
assert.true(condition)
assert.false(condition)
assert.throws(expression)
```

Add one runtime error type, `AssertionFailedError`.

Add one CLI mode:

```text
primal --test file.prm
```

Reserve the `test.` prefix for user tests
([§4.7](#47-cli-test-runner)).

Out of scope for the first version: directory or project-level discovery, test
filtering, fixtures, tagging, setup/teardown, structured (JSON) output, asserting
_which_ error was thrown, a second discovery prefix, and any `*_test.prm`
filename convention.

### 4.2 Pseudo-Grammar

No grammar changes. Assertions are ordinary calls and tests are ordinary
definitions; the relevant productions are unchanged and reproduced only to show
that nothing is added:

```ebnf
function_definition ::= identifier "(" [ parameter_list ] ")" "=" expression
call                ::= identifier "(" [ argument_list ] ")"
identifier          ::= letter { letter | digit | "." | "_" }   (* dots included *)
```

Only the CLI surface grows:

```ebnf
invocation ::= "primal" { option } [ file ] { program_arg }
option     ::= "--help" | "-h" | "--version" | "-v"
             | "--debug" | "-d" | "--watch" | "-w"
             | "--test"  | "-t"                        (* new *)
test_name  ::= "test." identifier_tail   (* runner convention, not grammar *)
```

### 4.3 Assertion Functions

```primal
assert.equal(actual: Equatable, expected: Equatable): Boolean
assert.notEqual(actual: Equatable, expected: Equatable): Boolean
assert.true(condition: Boolean): Boolean
assert.false(condition: Boolean): Boolean
assert.throws(expression: Any): Boolean
```

Common behaviour:

- On success every helper returns `true`.
- On failure every helper throws `AssertionFailedError`.
- No helper ever returns `false`.
- All are implemented with the two-class native pattern
  (`NativeFunctionTerm` + `NativeFunctionTermWithArguments`), validating
  argument types by hand ([§2.6](#26-native-parameter-types-are-not-enforced-generically)).

#### `assert.equal(actual, expected)`

1. Reduce `actual`, then reduce `expected`.
2. Compare with `CompEq.execute` — identical semantics to `==` and `comp.eq`.
   Pass `this` as the `function` argument, following the existing pattern
   (`OperatorDoubleAnd` passes `this` to `BoolAnd.execute`). `CompEq.execute`
   builds its type error from `function.name` and `function.parameterTypes`
   (`lib/compiler/library/comparison/comp_eq.dart`), so a type mismatch is
   reported against **`assert.equal`**, not `comp.eq`. See
   [§9](#9-open-questions), *type-error attribution*.
3. `true` → return `true`.
4. `false` → throw `AssertionFailedError`.
5. Any error raised by the comparison itself propagates **unchanged**.

#### `assert.notEqual(actual, expected)`

The mirror of `assert.equal`, and specified only by its differences:

1. Reduce `actual`, then reduce `expected`.
2. Compare with `CompNeq.execute`, passing `this` as the `function` argument —
   identical semantics to `!=` and `comp.neq`. `CompNeq.execute` delegates to
   `CompEq.execute` and negates the result
   (`lib/compiler/library/comparison/comp_neq.dart`), so the type rules,
   the recursive collection comparison, and the error attribution are exactly
   those of [`assert.equal`](#43-assertion-functions).
3. `true` (the operands differ) → return `true`.
4. `false` (the operands are equal) → throw `AssertionFailedError`.
5. Any error raised by the comparison itself propagates **unchanged**.

Implementation note: `CompNeq.execute` is declared to return `Term`, not
`BooleanTerm` (unlike `CompEq.execute`), even though it only ever produces a
`BooleanTerm`. The native must narrow the result rather than assume it.

#### `assert.true(condition)` / `assert.false(condition)`

1. Reduce `condition`.
2. If it is not a `BooleanTerm`, throw `InvalidArgumentTypesError` — same shape
   as `if` (`lib/compiler/library/control/if.dart`).
3. If the value matches the expected polarity, return `true`; otherwise throw
   `AssertionFailedError`.

#### `assert.throws(expression)`

Reduce `expression` inside a guarded region and classify the outcome:

| Outcome of reducing `expression`                                                 | Result                                                              |
| -------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| throws `AssertionFailedError`                                                    | rethrow **unchanged** — a nested assertion failure is not "a throw" |
| throws any other `RuntimeError` (including `CustomError`, `RecursionLimitError`) | return `true`                                                       |
| throws a non-`RuntimeError`                                                      | rethrow **unchanged** — an interpreter defect must not be masked    |
| completes normally                                                               | throw `AssertionFailedError`                                        |

Documented limitation: because errors carry no inspectable payload
([§2.4](#24-errors-carry-no-inspectable-payload)), `assert.throws` cannot assert
_which_ error was raised. An expression that fails for the wrong reason still
passes. A future `assert.throwsCode` becomes possible once
[[dev/roadmap/0.8.0/try]] lands.

### 4.4 Failure Representation

Add to `lib/compiler/errors/runtime_error.dart`, alongside the existing
subclasses:

```text
RuntimeError
  constructor gains an optional category:
    const RuntimeError(String message, {String category = 'Runtime error'})
      : super(category, message)

AssertionFailedError extends RuntimeError
  category: 'Assertion error'
  fields:   function: String, actual: String, expected: String
  message:  '"<function>" failed: expected <expected>, actual <actual>'
  renders:  'Assertion error: "assert.equal" failed: expected 2, actual 3'
```

The optional named parameter defaults to `'Runtime error'`, so every existing
`RuntimeError` subclass compiles unchanged — none of them pass a category. The
message body deliberately omits the word "Assertion": the category already
supplies it, and `Assertion error: Assertion "…" failed` reads as a stutter.

All five helpers supply both values, so neither field is optional:

| Helper            | `expected`                        | `actual`                          |
| ----------------- | --------------------------------- | --------------------------------- |
| `assert.equal`    | the reduced `expected`            | the reduced `actual`              |
| `assert.notEqual` | `not ` + the reduced `expected`   | the reduced `actual`              |
| `assert.true`     | `true`                            | the reduced condition             |
| `assert.false`    | `false`                           | the reduced condition             |
| `assert.throws`   | `a thrown error`                  | the value the expression produced |

`assert.notEqual` is the one helper whose `actual` and `expected` hold the *same*
value on failure — being equal is what failure means for it — so the `not` prefix
is what keeps the shared template readable:
`Assertion error: "assert.notEqual" failed: expected not 1, actual 1`.

(The first draft declared both fields `String?` without defining what the message
renders when either is absent. Making them required removes the question rather
than adding template branches for a case no helper produces.)

Because it is a `RuntimeError`, it is still catchable by `try` — consistent with
the rest of the language, and noted as [§6.7](#67-try-swallows-assertions).

**Display prefix — decided.** `RuntimeError`'s constructor currently hard-codes
the category string `'Runtime error'`
(`lib/compiler/errors/runtime_error.dart`) and `GenericError.toString()` renders
`'<errorType>: <message>'`, so without a change an assertion failure would print
under the same prefix that marks a genuine error — exactly the distinction the
runner draws in [§4.7](#47-cli-test-runner). This specification therefore adds
the optional `category` parameter above and prints failures as
`Assertion error: …`. The change is confined to one constructor, but it is a
change to a shared base class rather than a pure addition, and
[§7](#7-compiler-impact-by-stage) records it.

### 4.5 Runtime And Type Behaviour

- Success value is always `true`, which makes `&&` the natural composition
  operator for multiple assertions in one test body
  ([§2.8](#28--short-circuits)).
- `assert.true` and `assert.false` require a boolean, matching `if`.
- `assert.equal` inherits `comp.eq`'s type rules exactly — including
  `1 == 1.0` being `true` and unequal-length collections comparing `false`
  rather than erroring. Equal-length collections do **not** get the same
  treatment: `CompEq.compareLists` delegates each element back to
  `CompEq.execute`, so a same-length collection whose elements are of different
  kinds *throws*
  ([§6.4](#64-collection-comparison-splits-three-ways)). Map values behave the
  same way.
- `assert.notEqual` inherits the identical rules, because `CompNeq.execute` is a
  negation wrapper around `CompEq.execute`. In particular a type mismatch is an
  **error** for both, never a passing "not equal" — `assert.notEqual(1, "1")`
  throws rather than succeeding.
- Arguments are lazy because the helpers are native, but only `assert.throws`
  depends on that.
- Assertions are available on the web target too, since they live in the shared
  standard library. Only `--test` is CLI-only.

### 4.6 Error Conditions

| Condition                                         | Result                                                                            |
| ------------------------------------------------- | --------------------------------------------------------------------------------- |
| `assert.true` / `assert.false` with a non-boolean | `InvalidArgumentTypesError` → test **error**                                      |
| `assert.equal` across incomparable types          | `InvalidArgumentTypesError` from `CompEq.execute`, reported against `assert.equal` → test **error** |
| `assert.equal` over equal-length collections with mismatched element kinds | `InvalidArgumentTypesError` from the recursive element comparison → test **error** |
| `assert.equal` values differ                      | `AssertionFailedError` → test **fail**                                            |
| `assert.notEqual` across incomparable types       | `InvalidArgumentTypesError` — `CompNeq.execute` delegates to `CompEq.execute` → test **error** |
| `assert.notEqual` values are equal                | `AssertionFailedError` → test **fail**                                            |
| `assert.throws` over a non-throwing expression    | `AssertionFailedError` → test **fail**                                            |
| `assert.throws` over a nested failed assertion    | rethrown unchanged → test **fail**, attributed to the inner assertion             |
| errors from nested expressions                    | propagate unchanged unless intentionally caught by `assert.throws`                |
| user function named `assert.*` in a source file   | `DuplicatedFunctionError` at compile time                                         |
| user function named `assert.*` in the REPL        | `CannotRedefineStandardLibraryError`                                              |

### 4.7 CLI Test Runner

#### Invocation

```text
primal --test file.prm
primal -t file.prm
```

- Exactly one file argument. Zero or more than one is a usage error.
- `--test` with `--watch` is a usage error in the first version.
- `--test` with `--debug` is allowed and prints compile and per-test timings.

#### Discovery

- Compile the file once and print any warnings.
- Do **not** execute `main`, and do **not** fall through to the REPL when
  `main` is absent.
- Select custom functions whose name starts with `test.` **and** whose parameter
  list is empty.
- The `test.` prefix is **reserved**: the standard library must never register a
  function under it. Nothing enforces this in code — `StandardLibrary.get()` is a
  hand-maintained list — so it is a policy recorded here and in
  [[dev/architecture/pipeline/pipeline]]. Without it, adding a `test.*` namespace
  later would turn every existing user test into a `DuplicatedFunctionError`
  ([§4.6](#46-error-conditions)).
- `test.*` functions with one or more parameters are skipped and **reported** on
  stderr. They are never skipped silently — a test that accidentally gained a
  parameter must not disappear.
- Discovering zero tests is an error.

#### Execution

- Execute in source-declaration order
  ([§3.6](#36-source-order-not-lexicographic-order)).
- Evaluate each test as `test.name()` through `RuntimeFacade.evaluate`, which
  resets recursion depth per test
  ([§2.10](#210-miscellaneous)).
- Compile once, evaluate N times. Never recompile per test.

#### Result Classification

| Test outcome                    | Classification                              |
| ------------------------------- | ------------------------------------------- |
| returns `true`                  | **pass**                                    |
| throws `AssertionFailedError`   | **fail**                                    |
| throws any other `RuntimeError` | **error**                                   |
| returns any other value         | **error** — "test did not return true"      |
| throws a non-`RuntimeError`     | **abort** with exit code 2 (internal error) |

#### Process Exit Behaviour

| Code | Meaning                                                            |
| ---- | ------------------------------------------------------------------ |
| `0`  | every discovered test passed                                       |
| `1`  | at least one test failed or errored                                |
| `2`  | usage error, compile error, no tests discovered, or internal error |

Implementation constraint: `runCli` must **return** `int` and `main` must assign
`exitCode`. `exit()` must not be called inside `runCli`
([§2.9](#29-the-cli-has-no-exit-code-contract)).

## 5. Examples

### 5.1 Valid

```primal
test.math.addition() = assert.equal(1 + 1, 2)

test.parse.invalidNumber() = assert.throws(to.number("not a number"))

// several assertions in one test: each returns true, so && chains them
test.string.basics() =
    assert.equal(str.length("abc"), 3) &&
    assert.notEqual(str.length("abc"), 0) &&
    assert.true(str.startsWith("abc", "a")) &&
    assert.false(str.isEmpty("abc"))

// custom message, no new machinery required
test.custom() =
    if (num.isEven(4)) true else error.throw("assertion", "4 should be even")

main() = "not executed under --test"
```

```text
primal --test sample.prm
```

Runs the four tests in source order, skips `main`, exits `0`.

### 5.2 Invalid, With Expected Results

A source file is a list of function definitions
(`lib/compiler/syntactic/syntactic_analyzer.dart`), so a bare `assert.true(1)` at
file scope is a *syntax* error, not the runtime error shown. Each case below is
therefore written as a whole test.

```primal
test.notBoolean() = assert.true(1)
```

```text
Runtime error: Invalid argument types for function "assert.true". Expected: (Boolean). Actual: (Number)
→ test ERROR
```

```primal
test.crossType() = assert.equal("1", 1)
```

```text
Runtime error: Invalid argument types for function "assert.equal". Expected: (Equatable, Equatable). Actual: (String, Number)
→ test ERROR
```

```primal
test.stillEqual() = assert.notEqual(1, 1)
```

```text
Assertion error: "assert.notEqual" failed: expected not 1, actual 1
→ test FAIL
```

```primal
test.noThrow() = assert.throws(42)
```

```text
Assertion error: "assert.throws" failed: expected a thrown error, actual 42
→ test FAIL
```

```primal
test.bad() = 42
```

```text
→ test ERROR: test "test.bad" did not return true (returned 42)
```

### 5.3 Invalid Test-Mode Example

```primal
helper() = true
main() = 42
```

```text
primal --test sample.prm
Error: no zero-argument functions with the "test." prefix found in sample.prm
→ exit code 2
```

## 6. Edge Cases

### 6.1 Nested Assertion Inside `assert.throws`

```primal
test.wrong() = assert.throws(assert.equal(1, 2))
```

Must **fail**, attributed to the inner `assert.equal`. Under a
`try`-equivalent catch-all this would incorrectly pass.

### 6.2 `assert.equal(1, 1.0)` Passes

`CompEq` compares numbers with Dart's `num ==`
([§2.7](#27-equality-semantics)). Integer and decimal representations of the
same value are indistinguishable to `assert.equal`; pair it with `is.integer`
when the distinction matters.

The mirror holds and is the sharper trap: `assert.notEqual(1, 1.0)` **fails**,
even though the two literals are written differently and `is.integer`
distinguishes them.

### 6.3 `assert.throws` Cannot Be Abstracted

```primal
expectThrow(e) = assert.throws(e)
test.x() = expectThrow(to.number("z"))   // ERROR, not pass
```

`CustomFunctionTerm.apply` reduces arguments eagerly, so the error escapes at
the call boundary before `assert.throws` ever runs. This is the same limitation
that already applies to `if` and `try` — consistent, but a real footgun that
must be documented for users. See [[lang/design/lazy-evaluation]].

### 6.4 Collection Comparison Splits Three Ways

```primal
assert.equal([1, 2], [1, 2, 3])   // FAIL  — length differs, comp.eq returns false
assert.equal([1], "x")            // ERROR — operand kinds differ, comp.eq throws
assert.equal([1], ["x"])          // ERROR — same kind, same length, but the
                                  //         element comparison throws
```

The same call site produces different classifications depending on operand kinds
*and* on element kinds. The third case is the surprising one: both operands are
lists of length one, yet the result is an **error** rather than a **fail**,
because `CompEq.compareLists` delegates each element back to `CompEq.execute`,
which throws on `Number` versus `String`
(`lib/compiler/library/comparison/comp_eq.dart`). `CompEq.compareMaps` does the
same for map values.

### 6.5 `test.*` With Parameters

```primal
test.helper(x) = x + 1
```

Skipped, and reported on stderr. Silent skipping would hide a genuine test that
accidentally acquired a parameter.

### 6.6 User-Thrown Custom Errors Are Errors, Not Failures

```primal
test.x() = error.throw("assertion", "hand-rolled")
```

Classified as **error**, because `CustomError` is not `AssertionFailedError`.
The magic-string design could not make this distinction.

### 6.7 `try` Swallows Assertions

```primal
test.x() = try(assert.equal(1, 2), true)
```

**Passes.** Inherent to `try`'s catch-all
([§2.3](#23-try-catches-every-throwable)); unavoidable without changing `try`,
which is out of scope here. Document it. See
[[dev/architecture/error/error-propagation]].

### 6.8 Runaway Recursion In A Test

Produces `RecursionLimitError` → classified as **error**, and
`FunctionTerm.resetDepth()` guarantees the next test starts from a clean depth.

## 7. Compiler Impact By Stage

| Stage     | Impact                                                                                                                                      |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Lexical   | **None.** No new tokens or keywords; dotted names already lex as single identifiers ([§2.1](#21-dotted-names-lex-as-single-identifiers)).   |
| Syntactic | **None.** Ordinary calls and ordinary zero-argument definitions.                                                                            |
| Semantic  | **None.** Signatures are auto-derived from the standard library ([§2.5](#25-standard-library-signatures-are-auto-derived)).                 |
| Lowering  | **None.** Assertions lower as ordinary native calls; tests lower like any other custom function.                                            |
| Runtime   | Five new natives following the two-class pattern, plus `AssertionFailedError`. `assert.throws` reduces its argument under a guarded region. `RuntimeError` gains an optional `category` parameter (default-valued, so existing subclasses are untouched) so failures print as `Assertion error` ([§4.4](#44-failure-representation)). |
| CLI       | New `--test` / `-t` mode; discovery, execution, classification, and reporting; `runCli` returns `int` and `main` assigns `exitCode`.        |

## 8. Performance

- `assert.equal`, `assert.notEqual`, `assert.true`, and `assert.false` add one
  native call each — negligible. `assert.notEqual` adds a second, since
  `CompNeq.execute` delegates to `CompEq.execute`; still negligible.
- `assert.throws` adds a guarded region around one reduction; low overhead, and
  paid only where used.
- Test mode compiles the file **once** and evaluates each discovered test
  against the same `RuntimeFacade`. Per-test cost is a single expression
  evaluation plus a recursion-depth reset.
- Compile-time cost is five extra standard-library entries in the signature map.

## 9. Open Questions

**None outstanding.** Every question raised in review has been decided, and the
specification above already reflects each decision. Resolutions are recorded
below and referenced elsewhere in this document by their **bold lead-in**, not by
number.

### Resolved

- **Drop the `message` parameter** — confirmed. No helper takes a message;
  every failure text is auto-generated ([§4.4](#44-failure-representation)).
  Custom messages remain available with no new machinery through the `if` /
  `error.throw` form. Rationale and the accepted trade-off — per-assertion labels
  are lost inside a `&&` chain — are recorded in
  [§3.2](#32-no-message-parameter).
- **`assert.throws` stays narrower than `try`** — confirmed. It catches
  `RuntimeError` only, rethrowing `AssertionFailedError` and any
  non-`RuntimeError` unchanged ([§3.3](#33-assertthrows-is-narrower-than-try),
  [§4.3](#43-assertion-functions)).
- **A test must return exactly `true` to pass** — confirmed. "Completed without
  throwing" was rejected because a test containing no assertions at all would
  pass silently. The cost is the extra "returned a non-`true` value"
  classification in [§4.7](#47-cli-test-runner), and that a test whose final
  expression is a side effect must end in an assertion.
- **The `test.` prefix is reserved** — confirmed; the standard library must never
  claim it ([§4.7](#47-cli-test-runner)). A second discovery prefix and any
  `*_test.prm` filename convention stay out of scope
  ([§4.1](#41-scope)).
- **`AssertionFailedError` prints under its own category** — confirmed.
  `RuntimeError` gains an optional, default-valued `category` parameter and
  failures render as `Assertion error: …`
  ([§4.4](#44-failure-representation), [§7](#7-compiler-impact-by-stage)).
- **"No tests discovered" exits `2`** — confirmed. A mistyped prefix or a file
  that quietly stops matching must fail the build rather than report green. This
  is consistent with the uniform exit-code contract: `2` means the invocation was
  wrong, not that the tests passed ([§4.7](#47-cli-test-runner)).
- **Type-error attribution names the assertion** — confirmed. `assert.equal` and
  `assert.notEqual` pass `this` to `CompEq.execute` / `CompNeq.execute`, so an
  incomparable-operand error reads
  `Invalid argument types for function "assert.equal"` — the function the user
  wrote, not the primitive underneath ([§4.3](#43-assertion-functions)).

## 10. Post-Implementation

### Documentation

- Add `docs/lang/reference/core/assert.md` and link it from
  [[lang/index]] under Core.
- Cross-reference `AssertionFailedError` from [[lang/reference/core/error]].
- Add `--test` / `-t` to the `helpText` constant in `lib/main/main_cli.dart`.
  This is user-visible output rather than documentation, and both
  `test/compiler/main_cli_test.dart` and `test/compiler/cli_test.dart` assert on
  the help text, so it must change together with its tests.
- Update [[dev/architecture/pipeline/pipeline]]: standard-library function count
  (311 → 316), a new `assert.*` row (count 5) in the namespace table, the
  runtime-error table, and the CLI entry point section (`--test`, exit codes).
  The count stated there today (284) is already stale and its own namespace table
  sums to 290 — count `StandardLibrary.get()` rather than trusting either figure.
- Update [[dev/architecture/error/error-hierarchy]] with the new error type
  **and** with `RuntimeError`'s optional `category` parameter — the hierarchy is
  no longer "one category per base class"
  ([§4.4](#44-failure-representation)).
- Record the reserved `test.` prefix in [[dev/architecture/pipeline/pipeline]]
  alongside the namespace table, since nothing in code enforces it
  ([§4.7](#47-cli-test-runner)).
- Document the abstraction limitation ([§6.3](#63-assertthrows-cannot-be-abstracted))
  wherever `if`/`try` laziness is already explained.
- Update `CHANGELOG.md`. `README.md` does not list CLI flags today, so it needs
  no change unless that section grows.

### Tests

Runtime coverage:

- Each helper: success, failure, and argument type error.
- `AssertionFailedError.toString()` starts with `Assertion error:`, and — as a
  regression guard on the shared base class — every other `RuntimeError`
  subclass still starts with `Runtime error:`.
- `assert.throws`: custom error caught, non-throwing expression fails, nested
  assertion rethrown, non-`RuntimeError` rethrown.
- `assert.equal`: cross-type propagation, unequal-length collections,
  equal-length collections with mismatched element kinds and maps with
  mismatched value kinds ([§6.4](#64-collection-comparison-splits-three-ways)),
  `1` versus `1.0`.
- `assert.equal`'s type error names `assert.equal`, not `comp.eq`
  ([§9](#9-open-questions), *type-error attribution*).
- `assert.notEqual`: the same matrix as `assert.equal` with the outcomes
  inverted, plus the two cases where it is *not* a simple inversion — a type
  mismatch is an **error**, not a pass, and `assert.notEqual(1, 1.0)` fails
  ([§6.2](#62-assertequal1-10-passes)). Its type error must name
  `assert.notEqual`, not `comp.neq` or `comp.eq`.
- The `not ` prefix appears in `assert.notEqual`'s failure message
  ([§4.4](#44-failure-representation)).
- `&&` chaining of assertions.

CLI coverage (see [[dev/architecture/testing/integration-tests]]):

- Discovery of zero-argument `test.*` functions.
- Arity-mismatched `test.*` functions skipped **and reported**.
- `main` not executed; no REPL fallthrough when `main` is absent.
- No-tests-found error.
- All three classifications plus the non-`true` return case.
- Exit codes asserted through `runCli`'s return value, never via `exit()`.
- `--test` combined with `--watch`, with multiple files, and with no file.
- `--help` output lists `--test` and `-t`.
- A user function named `assert.*` in a source file fails compilation with
  `DuplicatedFunctionError` (not `CannotRedefineStandardLibraryError`).

## 11. Implementation Complexity

**Low to medium.**

The lexer, parser, semantic analyzer, and lowerer need no changes at all, and
argument laziness comes free with the native calling convention. Each helper is
a short two-class native, plus one error class.

The only non-trivial work is on the CLI: threading an exit code out of `runCli`
without calling `exit()` — a small but real signature change that touches
existing tests — plus discovery, classification, and reporting. Dropping the
`message` parameter removes roughly a third of the per-helper logic.

## 12. Recommendation

**Adopt.** Five assertion natives raising a dedicated `AssertionFailedError`,
plus a minimal `primal --test file.prm` runner that discovers zero-argument
`test.*` functions, ignores `main`, executes in source order, and classifies
results as pass, fail, or error. This gives Primal a usable testing workflow
with no new syntax, no compiler-stage changes before the runtime, and an
assertion surface small enough to keep.
