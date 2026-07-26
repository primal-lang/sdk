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
  - lib/compiler/library/comparison/comp_neq.dart
  - lib/compiler/library/logic/bool_and.dart
  - lib/compiler/library/operators/operator_double_and.dart
  - lib/compiler/errors/runtime_error.dart
  - lib/compiler/errors/semantic_error.dart
  - lib/compiler/lexical/lexical_analyzer.dart
  - lib/compiler/syntactic/syntactic_analyzer.dart
  - lib/compiler/semantic/semantic_analyzer.dart
  - lib/compiler/semantic/intermediate_representation.dart
  - lib/compiler/lowering/runtime_facade.dart
  - lib/compiler/runtime/runtime.dart
  - lib/compiler/warnings/semantic_warning.dart
  - lib/extensions/string_extensions.dart
  - lib/main/main_cli.dart
  - lib/utils/console.dart
---

# Testing

**TLDR**: Five standard-library assertion functions (`assert.equal`, `assert.notEqual`, `assert.true`, `assert.false`, `assert.throws`) that raise a dedicated `AssertionFailedError`, paired with a CLI test mode (`primal --test file.prm`) that discovers zero-argument `test.*` functions, runs them in source order, and classifies each result as pass, fail, or error. Giving the CLI a trustworthy exit code also changes an existing behaviour: a failing non-test run now exits `1` rather than `0`.

This specification adds a testing workflow to Primal without introducing any new
syntax. Assertions are ordinary native functions; tests are ordinary
zero-argument function definitions; discovery is a naming convention enforced by
the CLI, not by the compiler. The one change to existing behaviour is the exit
code ([§4.8](#48-runcli-return-codes)).

## 1. Feature Intent

Primal is expression-oriented and has no statement sequencing, so a program
cannot run many assertions one after another inside `main()`. The feature
therefore has two halves:

- **An assertion library** — helpers that express test expectations in Primal
  itself and signal failure through the runtime error system.
- **A CLI test runner** — a mode that compiles one file, discovers
  zero-argument functions whose names begin with `test.`, executes them
  independently, and reports results.

`assert.throws` is the only helper the language cannot express at all. The other
four have rough hand-written equivalents, but not equivalent ones: only the
helpers raise `AssertionFailedError`, and only `AssertionFailedError` lets the
runner report a **failure** rather than an **error**
([§3.1](#31-overlap-with-existing-constructs)). The runner is what makes any of
it usable in a real project.

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
having `main` assign `exitCode`. Two of the existing exit paths do not fit that
shape and must be specified explicitly ([§4.8](#48-runcli-return-codes)):

- **The REPL path never returns.** `_runRepl` calls `Console.prompt`, which is
  `while (true) { promptOnce(handler); }` (`lib/utils/console.dart`). There is
  no value for `runCli` to produce; the process leaves only through `exit(0)`.
- **The watch path returns while the process is still alive.** `_watchFile`
  registers a `FileSystemEvent` listener and returns immediately
  (`lib/main/main_cli.dart`); the subscription is what keeps the process up, and
  SIGINT calls `exit(0)`. Any code assigned to `exitCode` there is set long
  before the program finishes.

The catch-all in `runCli` is the third case, and it is a **behaviour change**
rather than an addition: today every compile and runtime failure exits `0`.
[§4.8](#48-runcli-return-codes) makes it exit `1`.

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

Four of the five helpers have an approximate hand-written equivalent:

```primal
assert.true(c)        ≈  if (c) true else error.throw("assertion", "…")
assert.false(c)       ≈  if (!c) true else error.throw("assertion", "…")
assert.equal(a, b)    ≈  if (a == b) true else error.throw("assertion", "…")
assert.notEqual(a, b) ≈  if (a != b) true else error.throw("assertion", "…")
```

The relation is `≈`, not `≡`, and the difference is the whole point of
[§3.4](#34-a-dedicated-error-type-not-a-magic-code): the right-hand forms raise
`CustomError`, which the runner classifies as a test **error**, never a test
**fail** ([§6.6](#66-user-thrown-custom-errors-are-errors-not-failures)). They
also collapse their diagnostics into a user-written string. So the helpers are
not sugar for something already available — they are the only way to produce a
*failure* rather than an *error*.

Only `assert.throws` adds capability the language cannot express at all, because
it cannot be written in Primal
([§2.2](#22-native-functions-receive-unreduced-arguments)). The surface stays
deliberately small — five functions, no variants.

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

**Trade-off, stated plainly: the first version has no custom assertion messages
at all.** Per-assertion labels are lost inside a `&&` chain, and the failing
test's name plus the generated message must carry the whole diagnosis.

The `if` / `error.throw` form of [§3.1](#31-overlap-with-existing-constructs) is
**not** a workaround for this, and this specification does not present it as one:
it raises `CustomError`, so the runner reports **error** rather than **fail**
([§6.6](#66-user-thrown-custom-errors-are-errors-not-failures)). A user reaching
for it to label an assertion silently loses the fail/error distinction — the
distinction §3.4 exists to protect.

If custom messages prove necessary, the follow-up is a sixth helper —
`assert.fail(message)` raising `AssertionFailedError` directly — not a message
parameter on the other five. It is deliberately **out of scope** here
([§4.1](#41-scope)); adding it later is additive and breaks nothing.

### 3.3 `assert.throws` Is Narrower Than `try`

Adopting `try`'s catch-all ([§2.3](#23-try-catches-every-throwable)) would mean
`assert.throws(assert.equal(1, 2))` **passes**, and that an interpreter defect
inside the asserted expression is reported as a successful test. This
specification catches `RuntimeError` only, and never `AssertionFailedError`.

`RecursionLimitError` is excluded on the **same** ground, even though it is a
`RuntimeError` (`lib/compiler/errors/runtime_error.dart`). It signals an
exhausted interpreter budget, not a rejection the test expressed — treating it
as a satisfied expectation would let `assert.throws(runaway())` report green for
a function that never terminates. It is rethrown unchanged
([§4.3](#43-assertion-functions)), which makes it a test **error**.

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
_which_ error was thrown, a second discovery prefix, any `*_test.prm` filename
convention, and custom assertion messages in any form — including the
`assert.fail(message)` helper sketched in [§3.2](#32-no-message-parameter).

### 4.2 Pseudo-Grammar

No grammar changes. Assertions are ordinary calls and tests are ordinary
definitions; the relevant productions are unchanged and reproduced only to show
that nothing is added:

```ebnf
function_definition ::= identifier "(" [ parameter_list ] ")" "=" expression
call                ::= identifier "(" [ argument_list ] ")"
identifier          ::= letter { letter | digit | "." | "_" }   (* dots included *)
```

Only the CLI surface grows, and the grammar below describes the parser that
exists rather than an idealised one. `runCli` scans **every** argument for
flags regardless of position and accumulates the rest into `remainingArgs`
(`lib/main/main_cli.dart`); `remainingArgs[0]` is the file and the remainder are
program arguments. `test/compiler/cli_test.dart` pins that a flag written
*after* the file path still takes effect, so options and non-options genuinely
interleave:

```ebnf
invocation ::= "primal" { option | non_option }
option     ::= "--help" | "-h" | "--version" | "-v"
             | "--debug" | "-d" | "--watch" | "-w"
             | "--test"  | "-t"                        (* new *)
non_option ::= file | program_arg   (* first non-option is the file *)
test_name  ::= "test." identifier_tail   (* runner convention, not grammar *)
```

`primal --test file.prm` and `primal file.prm --test` are therefore both valid,
and `--test` combines with `--debug` in either order. The "exactly one file"
rule of [§4.7](#47-cli-test-runner) is a check on `remainingArgs.length`, not on
argument position.

### 4.3 Assertion Functions

```primal
assert.equal(a: Equatable, b: Equatable): Boolean
assert.notEqual(a: Equatable, b: Equatable): Boolean
assert.true(a: Boolean): Boolean
assert.false(a: Boolean): Boolean
assert.throws(a: Any): Boolean
```

**Parameter names are `a`, `b` — this is binding, not cosmetic.** All 311
existing natives declare their parameters as `a`, `b`, `c` without exception,
and the names are user-visible three ways: `NativeFunctionTerm.substitute`
resolves bindings by parameter name (`lib/compiler/runtime/term.dart`),
`FunctionTerm.toString()` prints them in signatures and in the REPL's `:list`,
and 0.5.1's `function.parameters` returns them to Primal code
(`lib/compiler/library/introspection/function_parameters.dart`). The reference
documentation follows the same convention (`comp.eq(a: Equatable, b: Equatable)`
in [[lang/reference/core/comparison]]). The prose below writes *actual* and
*expected* for readability only; those are role names, never identifiers.

Common behaviour:

- On success every helper returns `true`.
- On failure every helper throws `AssertionFailedError`.
- No helper ever returns `false`.
- All are implemented with the two-class native pattern
  (`NativeFunctionTerm` + `NativeFunctionTermWithArguments`), validating
  argument types by hand ([§2.6](#26-native-parameter-types-are-not-enforced-generically)).

#### `assert.equal(a, b)` — actual, expected

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
5. Any error propagates **unchanged**, whether it is raised while *reducing*
   either operand in step 1 or by the *comparison* in step 2. Both are test
   **errors**, not failures: `assert.equal(to.number("x"), 1)` reports the
   `ParseError` from `to.number`
   (`lib/compiler/library/casting/to_number.dart`), not an assertion failure.

#### `assert.notEqual(a, b)` — actual, expected

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
5. Any error propagates **unchanged**, from operand reduction or from the
   comparison, exactly as for `assert.equal`.

Implementation note: `CompNeq.execute` is declared to return `Term`, not
`BooleanTerm` (unlike `CompEq.execute`), even though it only ever produces a
`BooleanTerm`. The native must narrow the result rather than assume it.

#### `assert.true(a)` / `assert.false(a)`

1. Reduce the condition.
2. If it is not a `BooleanTerm`, throw `InvalidArgumentTypesError` — same shape
   as `if` (`lib/compiler/library/control/if.dart`).
3. If the value matches the expected polarity, return `true`; otherwise throw
   `AssertionFailedError`.

#### `assert.throws(a)`

Reduce the expression inside a guarded region and classify the outcome:

| Outcome of reducing the expression                                | Result                                                                 |
| ----------------------------------------------------------------- | ---------------------------------------------------------------------- |
| throws `AssertionFailedError`                                     | rethrow **unchanged** — a nested assertion failure is not "a throw"    |
| throws `RecursionLimitError`                                      | rethrow **unchanged** — an exhausted budget is not an expectation met  |
| throws any other `RuntimeError` (including `CustomError`)         | return `true`                                                          |
| throws a non-`RuntimeError`                                       | rethrow **unchanged** — an interpreter defect must not be masked       |
| completes normally                                                | throw `AssertionFailedError`                                           |

**Implementation constraint — the guarded region must not enclose its own
failure.** `AssertionFailedError` and `RecursionLimitError` are both
`RuntimeError` subclasses, so the two obvious transcriptions are wrong:

- Throwing the "completed normally" `AssertionFailedError` *inside* the `try`
  lets `on RuntimeError` catch it and return `true` — `assert.throws(42)` would
  **pass**, inverting [§5.2](#52-invalid-with-expected-results) and
  [§6.1](#61-nested-assertion-inside-assertthrows).
- Ordering `on RuntimeError` before the narrower clauses swallows both
  rethrow cases for the same reason.

The required shape is: reduce inside the `try`, capture the outcome, and throw
the failure **after** the guarded region; within the region, `on
AssertionFailedError` and `on RecursionLimitError` must precede `on
RuntimeError`. Non-`RuntimeError` throwables are not caught at all, so no clause
is needed for them.

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

**Value rendering — decided.** A reduced `Term` is turned into its `String` with
`Runtime.format(term.native()).toString()`
(`lib/compiler/runtime/runtime.dart`), the same renderer the CLI already uses to
print a program's result. `Term.toString()` must **not** be used: `ValueTerm`
renders through `value.toString()` (`lib/compiler/runtime/term.dart`), which
drops the quotes on strings, so `assert.equal("3", "2")` would print
`expected 2, actual 3` — indistinguishable from the numeric case, and a direct
defeat of the argument in [§3.2](#32-no-message-parameter) that a generated
message reports actual versus expected better than a user-written one. With
`Runtime.format` the same failure reads:

```text
Assertion error: "assert.equal" failed: expected "2", actual "3"
```

The rule applies to every rendered value, including the `actual` of
`assert.throws` and the `not `-prefixed `expected` of `assert.notEqual`.

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
  `CompEq.execute`, so a same-length list, vector, stack or queue whose elements
  are of different kinds *throws*
  ([§6.4](#64-collection-comparison-splits-four-ways)). Map **values** behave the
  same way.
- Sets and map **keys** are the exception, and inheriting `comp.eq` means
  inheriting that too. `CompEq.compareSets` compares `a.native()` against
  `b.native()` with `Set.contains`, and `CompEq.compareMaps` matches keys with
  `containsKey` over `asMapWithKeys()`
  (`lib/compiler/library/comparison/comp_eq.dart`). Neither path calls
  `CompEq.execute`, so a kind mismatch there can never throw — it compares
  unequal and produces a **fail**, where the list rule would produce an
  **error**.
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
| `assert.equal` over equal-length lists, vectors, stacks or queues with mismatched element kinds | `InvalidArgumentTypesError` from the recursive element comparison → test **error** |
| `assert.equal` over maps with mismatched **value** kinds | `InvalidArgumentTypesError` from the recursive value comparison → test **error** |
| `assert.equal` over sets with mismatched element kinds | no error — `compareSets` compares native values → `AssertionFailedError` → test **fail** |
| `assert.equal` over maps with mismatched **key** kinds | no error — `compareMaps` matches keys with `containsKey` → `AssertionFailedError` → test **fail** |
| `assert.equal` values differ                      | `AssertionFailedError` → test **fail**                                            |
| `assert.notEqual` across incomparable types       | `InvalidArgumentTypesError` — `CompNeq.execute` delegates to `CompEq.execute` → test **error** |
| `assert.notEqual` values are equal                | `AssertionFailedError` → test **fail**                                            |
| `assert.throws` over a non-throwing expression    | `AssertionFailedError` → test **fail**                                            |
| `assert.throws` over a nested failed assertion    | rethrown unchanged → test **fail**, attributed to the inner assertion             |
| `assert.throws` over an expression exceeding the recursion limit | `RecursionLimitError` rethrown unchanged → test **error** ([§3.3](#33-assertthrows-is-narrower-than-try)) |
| an operand of `assert.equal` / `assert.notEqual` throws while reducing | propagates unchanged → test **error**, never a fail                  |
| errors from nested expressions                    | propagate unchanged unless intentionally caught by `assert.throws`                |
| user function named `assert.*` in a source file   | `DuplicatedFunctionError` at compile time                                         |
| user function named `assert.*` in the REPL        | `CannotRedefineStandardLibraryError`                                              |

### 4.7 CLI Test Runner

#### Invocation

```text
primal --test file.prm
primal -t file.prm
```

- Exactly one non-option argument, i.e. `remainingArgs.length == 1`. Zero or more
  than one is a usage error; test mode takes no program arguments.
- Flags may appear in any position, before or after the file
  ([§4.2](#42-pseudo-grammar)).
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
- `test.*` functions with one or more parameters are skipped, **reported** on
  stderr, and **fail the run with exit code `2`** even if every discovered test
  passes. They are never skipped silently, and never silently green — a test
  that accidentally gained a parameter must not disappear
  ([§6.5](#65-test-with-parameters)). The reasoning is the same as for
  "no tests discovered": the invocation, not the code under test, is wrong.
- Discovering zero tests is an error.

#### Execution

- Execute in source-declaration order
  ([§3.6](#36-source-order-not-lexicographic-order)).
- Build each call expression with the compiler's expression parser
  (`compiler.expression('test.name()')`), the way `RuntimeFacade.mainExpression`
  already does.
- Evaluate it with **`RuntimeFacade.evaluateToTerm`**, not `evaluate`.
  `evaluate` returns `_runtime.format(result.native()).toString()` — a formatted
  `String` (`lib/compiler/lowering/runtime_facade.dart`), which cannot express
  "returned exactly `true`" without a string comparison that silently couples
  classification to output formatting. `evaluateToTerm` returns the `Term`, and
  it is also the method that calls `FunctionTerm.resetDepth()`, so recursion
  depth is still isolated per test ([§2.10](#210-miscellaneous)).
- A test passes when the returned term satisfies
  `result is BooleanTerm && result.value`.
- Compile once, evaluate N times. Never recompile per test.

#### Result Classification

| Test outcome                    | Classification                                        |
| ------------------------------- | ----------------------------------------------------- |
| returns `BooleanTerm(true)`     | **pass**                                              |
| throws `AssertionFailedError`   | **fail**                                              |
| throws any other `RuntimeError` | **error**                                             |
| returns any other term          | **error** — "test did not return true"                |
| throws a non-`RuntimeError`     | **abort** — stop the run, report, return exit code `2` |

The reported value in the "did not return true" case is rendered with
`Runtime.format`, the same renderer as assertion messages
([§4.4](#44-failure-representation)).

**Abort semantics.** A non-`RuntimeError` — `StateError` from an unsubstituted
bound variable (`lib/compiler/runtime/term.dart`), `StackOverflowError`, or any
interpreter defect — means the runtime can no longer be trusted, so no further
tests run. `exit()` is unavailable ([§2.9](#29-the-cli-has-no-exit-code-contract)),
so "abort" is an early `return 2`. Before returning, the runner **prints the
results collected so far** on stdout, then the aborting test's name and the
throwable on stderr. Discarding a partial report would hide which tests had
already passed and which one destabilised the run.

#### Output

Results go to **stdout**; skips, aborts and the compile-failure message go to
**stderr**. `Console` currently exposes only `print` (stdout) and `error`
(stderr, wrapped in ANSI red — `lib/utils/console.dart`), and pass lines must not
be red, so the runner uses `print` for the per-test lines and the summary and
`error` for everything on stderr. No new `Console` method is required.

One line per test, in execution order, then a blank line and a summary:

```text
PASS  test.math.addition
FAIL  test.stillEqual
      Assertion error: "assert.notEqual" failed: expected not 1, actual 1
ERROR test.notBoolean
      Runtime error: Invalid argument types for function "assert.true". Expected: (Boolean). Actual: (Number)

3 tests: 1 passed, 1 failed, 1 error
```

- The status keyword is `PASS`, `FAIL` or `ERROR`, padded to five columns, then
  the test name.
- `FAIL` and `ERROR` add the error's `toString()` on a following line, indented
  six spaces. `PASS` adds nothing.
- The summary counts every discovered test and omits the categories that are
  zero, always keeping `N tests:` and at least one category.
- With `--debug`, each line gains a trailing `[Nms]` and the compile timing is
  printed first, matching the existing `[debug] Compilation: Nms` format.

#### Process Exit Behaviour

| Code | Meaning                                                                                  |
| ---- | ---------------------------------------------------------------------------------------- |
| `0`  | every discovered test passed, and nothing was skipped                                    |
| `1`  | at least one test failed or errored                                                      |
| `2`  | usage error, compile error, no tests discovered, a skipped `test.*`, or an internal abort |

`2` is the "the invocation is wrong" code: it never means the code under test
misbehaved, only that the run did not measure what it claimed to.

### 4.8 `runCli` Return Codes

`runCli` must **return** `int` and `main` must assign `exitCode`. `exit()` must
not be called inside `runCli`
([§2.9](#29-the-cli-has-no-exit-code-contract)). Because every existing exit path
now needs a value, they are specified here in full rather than left to the
implementation:

| Path                                          | Returns                                     |
| --------------------------------------------- | ------------------------------------------- |
| `--help`, `--version`                         | `0`                                         |
| file executed successfully (no `--test`)      | `0`                                         |
| `--test` (any outcome)                        | per [§4.7](#47-cli-test-runner)             |
| watch-mode usage errors                       | `2`                                         |
| watch mode started successfully               | `0`, returned immediately while the listener keeps the process alive; SIGINT still calls `exit(0)` |
| REPL                                          | unreachable — `Console.prompt` never returns |
| the `catch` in `runCli` (compile or runtime failure) | `1`                                   |

The last row is a **breaking change to the CLI contract, not an addition**, and
it is deliberate: today `primal broken.prm` prints a red error and exits `0`,
which makes the CLI unusable in any script or CI step. The `--test` mode would
otherwise be the only part of the CLI with a trustworthy exit code.

No existing test pins the old behaviour — the error cases in
`test/compiler/cli_test.dart` assert on stderr only, and the `exitCode` `0`
assertions there all cover successful programs — but the change is user-visible
and belongs in `CHANGELOG.md` under *Changed*
([§10](#10-post-implementation)).

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

main() = "not executed under --test"
```

```text
primal --test sample.prm
```

Runs the three tests in source order, skips `main`, exits `0`:

```text
PASS  test.math.addition
PASS  test.parse.invalidNumber
PASS  test.string.basics

3 tests: 3 passed
```

### 5.2 Invalid, With Expected Results

A source file is a list of function definitions
(`lib/compiler/syntactic/syntactic_analyzer.dart`), so a bare `assert.true(1)` at
file scope is a *syntax* error, not the runtime error shown. Each case below is
therefore written as a whole test, and the expected text is the runner's actual
output ([§4.7](#47-cli-test-runner)).

```primal
test.notBoolean() = assert.true(1)
```

```text
ERROR test.notBoolean
      Runtime error: Invalid argument types for function "assert.true". Expected: (Boolean). Actual: (Number)
```

```primal
test.crossType() = assert.equal("1", 1)
```

```text
ERROR test.crossType
      Runtime error: Invalid argument types for function "assert.equal". Expected: (Equatable, Equatable). Actual: (String, Number)
```

```primal
test.stillEqual() = assert.notEqual(1, 1)
```

```text
FAIL  test.stillEqual
      Assertion error: "assert.notEqual" failed: expected not 1, actual 1
```

```primal
test.noThrow() = assert.throws(42)
```

```text
FAIL  test.noThrow
      Assertion error: "assert.throws" failed: expected a thrown error, actual 42
```

```primal
test.quotedStrings() = assert.equal("3", "2")
```

```text
FAIL  test.quotedStrings
      Assertion error: "assert.equal" failed: expected "2", actual "3"
```

The quotes come from `Runtime.format` ([§4.4](#44-failure-representation)); with
`Term.toString()` this message would read `expected 2, actual 3` and be
indistinguishable from a numeric comparison.

```primal
test.bad() = 42
```

```text
ERROR test.bad
      test "test.bad" did not return true (returned 42)
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

A file whose only test carries a parameter reports and exits `2` as well, rather
than reporting green on an empty run ([§6.5](#65-test-with-parameters)):

```primal
test.helper(x) = assert.equal(x, x)
test.real() = assert.true(true)
```

```text
primal --test sample.prm
Error: skipped "test.helper" — test functions must take no parameters
PASS  test.real

1 test: 1 passed
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

### 6.4 Collection Comparison Splits Four Ways

```primal
assert.equal([1, 2], [1, 2, 3])   // FAIL  — length differs, comp.eq returns false
assert.equal([1], "x")            // ERROR — operand kinds differ, comp.eq throws
assert.equal([1], ["x"])          // ERROR — same kind, same length, but the
                                  //         element comparison throws
assert.equal({1}, {"x"})          // FAIL  — sets never delegate to comp.eq
```

The same call site produces different classifications depending on operand kinds,
on element kinds, *and* on which collection is involved.

The third case is the one users trip over: both operands are lists of length one,
yet the result is an **error** rather than a **fail**, because
`CompEq.compareLists` delegates each element back to `CompEq.execute`, which
throws on `Number` versus `String`
(`lib/compiler/library/comparison/comp_eq.dart`). Vectors, stacks and queues all
route through `compareLists`, and `CompEq.compareMaps` does the same for map
*values*.

The fourth case is the inconsistency: sets take a different path.
`CompEq.compareSets` receives `a.native()` / `b.native()` and uses
`Set.contains`, and `compareMaps` matches *keys* with `containsKey` over
`asMapWithKeys()`. Neither calls `CompEq.execute`, so a kind mismatch there can
never throw — it simply compares unequal and produces a **fail**. Two structurally
identical assertions therefore land in different classifications:

```primal
assert.equal([1], ["x"])          // ERROR
assert.equal({1}, {"x"})          // FAIL
```

Two consequences of the native-value comparison are worth knowing but are **not**
changed by this specification, because they are pre-existing `comp.eq` behaviour
and fixing them is a separate concern:

- Set membership uses Dart equality on native values, so sets of collections
  compare by identity: `assert.equal({[1]}, {[1]})` **fails** even though the
  elements are structurally equal.
- Map keys are compared the same way, with the same caveat.

`assert.equal` inherits all of this verbatim, by design
([§4.5](#45-runtime-and-type-behaviour)).

### 6.5 `test.*` With Parameters

```primal
test.helper(x) = x + 1
```

Skipped, reported on stderr, and the run exits `2`
([§4.7](#47-cli-test-runner)). Silent skipping would hide a genuine test that
accidentally acquired a parameter; skipping loudly but still exiting `0` would
hide it just as effectively from CI, which reads the exit code and not the log.

This is the cost of reserving the prefix: a legitimate helper cannot be named
`test.something`. Helpers should be named outside the namespace.

### 6.6 User-Thrown Custom Errors Are Errors, Not Failures

```primal
test.x() = error.throw("assertion", "hand-rolled")
```

Classified as **error**, because `CustomError` is not `AssertionFailedError`.
The magic-string design could not make this distinction.

This is also why the `if` / `error.throw` form is *not* offered as a
custom-message workaround ([§3.2](#32-no-message-parameter)): the user writes
what they intend as a failing assertion and the runner reports an error. The
first version has no way to express a labelled failure, and says so.

### 6.7 `try` Swallows Assertions

```primal
test.x() = try(assert.equal(1, 2), true)
```

**Passes.** Inherent to `try`'s catch-all
([§2.3](#23-try-catches-every-throwable)); unavoidable without changing `try`,
which is out of scope here. Document it. See
[[dev/architecture/error/error-propagation]].

### 6.8 Runaway Recursion In A Test

```primal
loop(n) = loop(n + 1)
test.direct() = loop(0)                  // ERROR
test.wrapped() = assert.throws(loop(0))  // ERROR, not pass
```

Both produce `RecursionLimitError` and both are classified as **error**.
`assert.throws` does **not** absorb it ([§3.3](#33-assertthrows-is-narrower-than-try),
[§4.3](#43-assertion-functions)) — otherwise a non-terminating function would
report as a satisfied expectation.

`FunctionTerm.resetDepth()` guarantees the next test starts from a clean depth,
and the depth counter also unwinds correctly on its own: `CustomFunctionTerm.apply`
and `LambdaTerm.apply` decrement in a `finally`
(`lib/compiler/runtime/term.dart`).

## 7. Compiler Impact By Stage

| Stage     | Impact                                                                                                                                      |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Lexical   | **None.** No new tokens or keywords; dotted names already lex as single identifiers ([§2.1](#21-dotted-names-lex-as-single-identifiers)).   |
| Syntactic | **None.** Ordinary calls and ordinary zero-argument definitions.                                                                            |
| Semantic  | **None.** Signatures are auto-derived from the standard library ([§2.5](#25-standard-library-signatures-are-auto-derived)).                 |
| Lowering  | **None.** Assertions lower as ordinary native calls; tests lower like any other custom function.                                            |
| Runtime   | Five new natives following the two-class pattern, with parameters named `a`, `b` per convention ([§4.3](#43-assertion-functions)), plus `AssertionFailedError`. `assert.throws` reduces its argument under a guarded region whose failure path lies outside it ([§4.3](#43-assertion-functions)). `RuntimeError` gains an optional `category` parameter (default-valued, so existing subclasses are untouched) so failures print as `Assertion error` ([§4.4](#44-failure-representation)). |
| CLI       | New `--test` / `-t` mode; discovery, execution, classification, and reporting ([§4.7](#47-cli-test-runner)); `runCli` returns `int` and `main` assigns `exitCode` for **every** path, which changes the exit code of failing non-test runs from `0` to `1` ([§4.8](#48-runcli-return-codes)). |

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

- **Drop the `message` parameter, and ship with no custom messages at all** —
  confirmed. No helper takes a message and every failure text is auto-generated
  ([§4.4](#44-failure-representation)). The `if` / `error.throw` form is
  explicitly **not** a substitute: it raises `CustomError`, which the runner
  classifies as an error rather than a failure
  ([§6.6](#66-user-thrown-custom-errors-are-errors-not-failures)). If labelled
  failures prove necessary, the follow-up is `assert.fail(message)`, out of scope
  here ([§3.2](#32-no-message-parameter), [§4.1](#41-scope)).
- **`assert.throws` stays narrower than `try`** — confirmed. It catches
  `RuntimeError` only, rethrowing `AssertionFailedError`, `RecursionLimitError`
  and any non-`RuntimeError` unchanged
  ([§3.3](#33-assertthrows-is-narrower-than-try),
  [§4.3](#43-assertion-functions)).
- **`RecursionLimitError` is an error, not a caught throw** — confirmed. An
  exhausted interpreter budget is not an expectation the test expressed, and
  treating it as one lets a non-terminating function report green
  ([§3.3](#33-assertthrows-is-narrower-than-try), [§6.8](#68-runaway-recursion-in-a-test)).
- **The success-path throw sits outside the guarded region** — confirmed.
  `AssertionFailedError` is a `RuntimeError`, so throwing it inside the `try`
  would let `assert.throws`'s own catch clause swallow it and make
  `assert.throws(42)` pass ([§4.3](#43-assertion-functions)).
- **Values render through `Runtime.format`** — confirmed. `Term.toString()`
  drops quotes on strings, which would make `expected 2, actual 3` ambiguous and
  defeat the reason for auto-generating messages at all
  ([§4.4](#44-failure-representation)).
- **Assertion parameters are named `a`, `b`** — confirmed. All 311 existing
  natives use `a`/`b`/`c`, and the names reach users through
  `function.parameters`, `FunctionTerm.toString()` and the reference docs
  ([§4.3](#43-assertion-functions)).
- **Tests are evaluated with `evaluateToTerm`, not `evaluate`** — confirmed.
  `evaluate` returns a formatted `String`, so classifying on it would couple
  pass/fail to output formatting; `evaluateToTerm` returns the `Term` and still
  resets recursion depth ([§4.7](#47-cli-test-runner)).
- **A skipped `test.*` exits `2`** — confirmed, on the same ground as "no tests
  discovered": CI reads the exit code, not the log, so reporting a skip while
  exiting `0` hides exactly what the report was meant to surface
  ([§4.7](#47-cli-test-runner), [§6.5](#65-test-with-parameters)).
- **An abort prints the partial report** — confirmed. A non-`RuntimeError` stops
  the run, but the results already collected are printed before returning `2`,
  so it is visible which tests passed and which one destabilised the runtime
  ([§4.7](#47-cli-test-runner)).
- **`runCli` gets a return code for every path, and failing runs now exit `1`** —
  confirmed. The REPL path is unreachable, watch mode returns `0` early, and the
  catch-all returns `1`. That last one is a deliberate breaking change: a CLI
  that exits `0` on a compile error is unusable in CI
  ([§2.9](#29-the-cli-has-no-exit-code-contract), [§4.8](#48-runcli-return-codes)).
- **The runner's output format is fixed** — confirmed. `PASS`/`FAIL`/`ERROR`
  lines on stdout with an indented error line and a counting summary; skips and
  aborts on stderr ([§4.7](#47-cli-test-runner)).
- **Set and map-key comparison stays as it is** — confirmed. `comp.eq` compares
  set elements and map keys by native value without delegating to
  `CompEq.execute`, so those mismatches fail rather than error.
  `assert.equal` inherits the inconsistency verbatim; changing `comp.eq` is a
  separate concern ([§6.4](#64-collection-comparison-splits-four-ways)).
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
- **The document targets 0.5.2** — confirmed. 0.5.0 and 0.5.1 are released
  (`CHANGELOG.md`, `pubspec.yaml`), so the feature cannot land in the folder it
  was originally filed under.
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
  This is user-visible output rather than documentation. Both
  `test/compiler/main_cli_test.dart` and `test/compiler/cli_test.dart` assert on
  the help text, but only with `contains` (`'Usage: primal'`, `'--debug'`,
  `'Options:'`), so adding a line breaks nothing — the new `--test` assertions
  below are additions, not repairs.
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
- Update `CHANGELOG.md` — under *Added* for the assertions and `--test`, and
  under **Changed** for the exit-code contract: failing non-test runs now exit
  `1` instead of `0` ([§4.8](#48-runcli-return-codes)).
- `README.md` does not list CLI flags today, so it needs no change unless that
  section grows.

### Tests

Runtime coverage:

- Each helper: success, failure, and argument type error.
- `AssertionFailedError.toString()` starts with `Assertion error:`, and — as a
  regression guard on the shared base class — every other `RuntimeError`
  subclass still starts with `Runtime error:`.
- Each helper's declared parameters are `a` (and `b`), asserted through
  `function.parameters` ([§4.3](#43-assertion-functions)).
- `assert.throws`: custom error caught, non-throwing expression fails, nested
  assertion rethrown, `RecursionLimitError` rethrown rather than caught
  ([§6.8](#68-runaway-recursion-in-a-test)), non-`RuntimeError` rethrown.
  `assert.throws(42)` must **fail** — the direct regression guard against the
  catch-ordering hazard in [§4.3](#43-assertion-functions).
- `assert.equal`: cross-type propagation, unequal-length collections,
  equal-length lists with mismatched element kinds, maps with mismatched value
  kinds, and — as the counter-cases — sets with mismatched element kinds and
  maps with mismatched key kinds, which **fail** rather than error
  ([§6.4](#64-collection-comparison-splits-four-ways)); `1` versus `1.0`.
- An operand that throws while reducing propagates unchanged and is an error,
  not a failure: `assert.equal(to.number("x"), 1)`
  ([§4.3](#43-assertion-functions)).
- Failure messages render through `Runtime.format`: `assert.equal("3", "2")`
  produces `expected "2", actual "3"`, with the quotes
  ([§4.4](#44-failure-representation)).
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
- Arity-mismatched `test.*` functions skipped, reported, **and exiting `2`** even
  when every other test passes ([§6.5](#65-test-with-parameters)).
- `main` not executed; no REPL fallthrough when `main` is absent.
- No-tests-found error.
- All three classifications plus the non-`true` return case, asserted against the
  output format of [§4.7](#47-cli-test-runner) — the `PASS`/`FAIL`/`ERROR`
  prefix, the indented error line, and the summary counts.
- A test returning the *string* `"true"` is an **error**, not a pass — the guard
  that classification reads the `Term` and not formatted output
  ([§4.7](#47-cli-test-runner)).
- Results appear on stdout, skips and aborts on stderr.
- Exit codes asserted through `runCli`'s return value, never via `exit()`.
- Every row of the `runCli` table in [§4.8](#48-runcli-return-codes), including
  the changed one: a non-test run whose program fails now returns `1`. Watch-mode
  and REPL paths are covered by their existing tests plus a return-value
  assertion where one is reachable.
- `--test` combined with `--watch`, with multiple files, and with no file.
- `--test` written *after* the file path, and combined with `--debug` in both
  orders ([§4.2](#42-pseudo-grammar)).
- `--help` output lists `--test` and `-t`.
- A user function named `assert.*` in a source file fails compilation with
  `DuplicatedFunctionError` (not `CannotRedefineStandardLibraryError`).

## 11. Implementation Complexity

**Low to medium.**

The lexer, parser, semantic analyzer, and lowerer need no changes at all, and
argument laziness comes free with the native calling convention. Each helper is
a short two-class native, plus one error class.

Two pieces carry the real risk, and neither is large:

- **The exit-code contract.** Threading an `int` out of `runCli` without calling
  `exit()` is mechanically small, but it forces a decision on every existing exit
  path, one of which changes user-visible behaviour
  ([§4.8](#48-runcli-return-codes)). Specified, it is an afternoon; unspecified,
  it is where the design leaks.
- **`assert.throws`'s guarded region.** The natural transcription is wrong and
  fails silently in the passing direction ([§4.3](#43-assertion-functions)), so
  the `assert.throws(42)` test is not optional.

The rest — discovery, classification, and reporting — is straightforward, and
dropping the `message` parameter removes roughly a third of the per-helper logic.

## 12. Recommendation

**Adopt.** Five assertion natives raising a dedicated `AssertionFailedError`,
plus a minimal `primal --test file.prm` runner that discovers zero-argument
`test.*` functions, ignores `main`, executes in source order, and classifies
results as pass, fail, or error. This gives Primal a usable testing workflow
with no new syntax, no compiler-stage changes before the runtime, and an
assertion surface small enough to keep.

Adopt the exit-code change with it. `--test` is only as useful as the code it
returns, and a CLI that exits `0` on a compile error cannot be scripted
([§4.8](#48-runcli-return-codes)). It is the one breaking change here, it is
small, and no existing test depends on the old behaviour.
