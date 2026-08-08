---
title: Function Declaration Update
tags:
  - roadmap
  - syntax
  - breaking-change
sources:
  - lib/compiler/syntactic/syntactic_analyzer.dart
  - lib/compiler/errors/syntactic_error.dart
---

# Function Declaration Update

**TLDR**: A function that takes no parameters is declared without parentheses — `pi = 3.14` instead of `pi() = 3.14`. Call sites do not change: `pi()` still invokes it and a bare `pi` is still the function value. Breaking change, shipping in 0.5.5.

## Decision

Empty parentheses are removed from the **declaration site only**.

```
pi = 3.14159            // declaration: no parentheses
area(r) = pi() * r * r  // call site: unchanged
```

Everything after the parser is untouched. A zero-parameter function is still a function: it is still invoked with `pi()`, a bare `pi` still evaluates to the function value, and it can still be passed as an argument and inspected with `function_arity`, `function_name`, `function_parameters` and `is_function`.

`main` follows the same rule as every other function — it is not special-cased anywhere in the pipeline:

```
main = factorial(5)          // no command-line arguments
main(name) = "Hi, " + name   // takes command-line arguments
```

## Design Space

Four coherent positions were considered.

| Option                   | Declaration     | Use        | Verdict    |
| ------------------------ | --------------- | ---------- | ---------- |
| Status quo               | `pi() = 3.14`   | `pi()`     | Rejected   |
| **Half step**            | **`pi = 3.14`** | **`pi()`** | **Chosen** |
| Half step + static check | `pi = 3.14`     | `pi()`     | Rejected   |
| Full step                | `pi = 3.14`     | `pi`       | Rejected   |

### Why not the status quo

The empty parentheses carry no information. In practice they appear almost entirely on `main`: across all 20 sample programs, _every_ zero-parameter declaration is `main()`, and in `docs/` 30 of roughly 55 are `main()`, with most of the rest being `test_*` functions and roadmap sketches.

### Why not the full step

Making a bare `pi` invoke the function would let `area(r) = pi * r * r` work and would keep the declaration and its use symmetric. It was rejected because zero-parameter functions would stop being first-class values. Confirmed against a prototype:

- `apply0(greet)` fails with `"hello" is not a function`
- `is_function(pi)` returns `false`
- `function_arity(time_now)` fails with `Expected: (Function). Actual: (Timestamp)`

Only `apply0(() -> greet)` still works, so every nullary passed as a value would need eta-expansion.

### Why not the static check

A check rejecting a bare nullary used as an operator operand would turn `pi * r * r` into a compile error instead of a runtime one. It is sound rather than heuristic — `*` declares `Parameter.number('a'), Parameter.number('b')`, and the semantic analyzer already knows the arity of every identifier, so a Function operand is always wrong. It was rejected because it is not specific to this change: it is a general static type check the language could add today, and it cuts against the dynamic runtime type checking the language deliberately relies on.

## Evidence

A prototype implementing the declaration-site change was run against the full suite.

- **10,469 tests, 1 failure** — `Syntactic Analyzer: Missing parentheses throws error`, the test that asserts the rule being replaced. The change is functionally inert.
- **The grammar stays unambiguous.** A declaration always begins with an identifier, and an identifier can never continue a preceding expression, so the greedy expression parser always stops at the boundary. `one = two three = 4 four(x) = x` on a single line splits into three declarations correctly.
- **No collision with the roadmap.** Destructuring is scoped to `do ... end`, `where` and comprehensions, so top-level declarations will still always begin with an identifier. Currying (`addFive = add(5, _)`, called as `addFive()(3)`) and tuples (`point = (10, 20)`) are unaffected.
- **Precedent for a breaking change at this level.** 0.5.3 shipped "Breaking change: dots are no longer valid in identifiers" in a patch bump.

## Accepted Costs

- A declaration no longer mirrors its call site for zero-parameter functions, and the exception lands on `main` — the first line every learner writes.
- `area(r) = pi * r * r` remains a runtime error, not a compile error: `Invalid argument types for function "*". Expected: (Number, Number). Actual: (Function, Number)`. Nothing suggests adding `()`.
- Every existing program breaks. Migration is mechanical: `sed -i -E 's/^([a-zA-Z]\w*)\(\) =/\1 =/' *.prm`.
- Hard break — no deprecation window, no legacy branch in the parser, no leniency in the REPL.

## Unchanged

- **Lambdas.** `() -> x` stays legal. Its parentheses are a parameter list at a value site, not a declaration, and the only symmetric alternative (`-> x`) is worse.
- **Display form.** `pi()` remains what `:list`, the REPL echo and error messages print, since it still mirrors the call site.
- **Standard library.** The zero-parameter core functions (`time_now`, `uuid_v4`, `num_decimal_random`, `console_read`, `num_infinity`) are declared in Dart, so `time_now()` and friends are unaffected.
- **Semantic analyzer, lowerer and runtime.** No changes at any stage after parsing.

The REPL gains one behaviour for free: `x = 5` now defines a zero-parameter function instead of raising an error, because `Compiler.functionDefinition` is tried before expression evaluation.

## Grammar

```
declaration := IDENTIFIER "(" parameters ")" "=" expression
             | IDENTIFIER "=" expression

parameters  := IDENTIFIER ("," IDENTIFIER)*
```

`parameters` is now non-empty: an empty parameter list has no valid spelling.

### Valid

```
pi = 3.14159
main = factorial(5)
greet(name) = "Hello, " + name + "!"
main(name) = greet(name)
identity = (x) -> x
```

### Invalid

```
pi() = 3.14159
```

```
Syntax error: function "pi" takes no parameters and must be declared
without parentheses. Write "pi = ..." instead of "pi() = ...".
```

## Implementation Plan

### 1. Grammar

Both edits are in `lib/compiler/syntactic/syntactic_analyzer.dart`. Permitting the new form and forbidding the old one are separate, deliberate changes — see [[dev/architecture/patterns/state-machine-pattern]].

- [ ] `FunctionNameState.process` — add an `AssignToken` branch that parses the body with `ExpressionParser` and returns `ResultState(iterator, output.build(...))`, mirroring `FunctionParametrizedState`. `ExpressionParser` is already imported.
- [ ] `FunctionNameState.process` — change the fallback error text from `"'(' after function name"` to `"'(' or '=' after function name"`.
- [ ] `FunctionWithParametersState.process` — replace the `CloseParenthesisToken` branch with a throw of the new error. This state is entered only immediately after `(`, so a `)` here means exactly zero parameters; no lookahead is needed.
- [ ] `FunctionWithParametersState.process` — change the fallback error text from `'identifier or )'` to `'identifier'`.
- [ ] Verify `FunctionParametrizedState` still compiles unchanged; it is now reachable only from `FunctionWithNewParametersState`.

### 2. Errors

- [ ] Add `EmptyParameterListError extends SyntacticError` to `lib/compiler/errors/syntactic_error.dart`, following [[dev/architecture/error/error-hierarchy]]. It takes the offending token and the function name — `FunctionDefinitionBuilder.name` is in scope at the throw site.
- [ ] Message names the fix, using the wording under [Invalid](#invalid) above.

### 3. Tests

- [ ] `test/compiler/syntactic_analyzer_test.dart` — invert `Missing parentheses throws error`: `pi = 3.14` must now parse into a `FunctionDefinition` with `parameters: []`.
- [ ] Add a test asserting `pi() = 3.14` throws `EmptyParameterListError`.
- [ ] Migrate the inline sources in the same file (`enabled() = true`, `list() = [1, 2, 3]`, …) to the new form.
- [ ] Add a test asserting `main(name) = ...` still parses, so the one-or-more parameter path stays covered.
- [ ] Sweep inline program sources across `test/compiler/`, `test/runtime/`, `test/errors/` and `test/helpers/`.
- [ ] Migrate `test/resources/samples/*.prm` (20 files, all `main() =`) and `test/resources/sample.prm`.
- [ ] Confirm `--test` discovery still works with `test_foo = ...`, including the zero-argument requirement and the skip-on-parameters path in `lib/main/main_cli.dart`.
- [ ] Confirm the REPL path: `pi = 3.14` defines, `pi()` evaluates, `pi() = 3.14` is rejected.

### 4. Documentation

- [ ] `README.md` — the `pi() = 3.14159` example in the Syntax section and the Main function section.
- [ ] `docs/lang/design/function-definitions.md` — the "Zero-Parameter Functions" section states the rule being reversed and must be rewritten; also `## The main() Function` and the `main()` examples throughout. See [[lang/design/function-definitions]].
- [ ] `docs/dev/architecture/pipeline/syntactic.md` — the grammar line for a nullary function and the numbered state descriptions.
- [ ] `docs/dev/architecture/patterns/state-machine-pattern.md` — the state tree and the `FunctionNameState` / `FunctionWithParametersState` code excerpts.
- [ ] `docs/dev/architecture/pipeline/example.md` — the worked example walks `main() = max(square(3), square(4))` token by token through the state machine; the row tables and transition tables all need updating.
- [ ] Sweep the remaining `name() =` occurrences across `docs/`, including the roadmap sketches under 0.6.0–1.0.0, so they stay consistent with the language they will be built on.
- [ ] Run `kb-lint` to confirm `docs/` still matches `lib/`.

### 5. Release

Handled by the `prepare-release` skill; listed here for completeness.

- [ ] `pubspec.yaml` — `version: 0.5.5`.
- [ ] `lib/main/main_cli.dart` — `const String version = '0.5.5'`.
- [ ] `CHANGELOG.md` — a `## 0.5.5` section with Language → Changed, phrased like the 0.5.3 entry: **Breaking change: functions without parameters are declared without parentheses**.
- [ ] Include the `sed` migration one-liner in the changelog entry.
