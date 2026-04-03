# Semantic Analyzer Review

## Scope

This document reviews:

- `docs/compiler/semantic.md`
- `lib/compiler/semantic/semantic_analyzer.dart`
- `lib/compiler/semantic/intermediate_code.dart`

It also references a few adjacent files where that is necessary to understand the current behavior:

- `lib/compiler/runtime/node.dart`
- `lib/compiler/runtime/runtime.dart`
- `docs/compiler.md`
- `docs/compiler/syntactic.md`
- `docs/primal.md`
- `test/compiler/semantic_analyzer_test.dart`

The goal of this review is to answer four questions in detail:

1. What does the semantic analyzer do today?
2. Is it good, bad, or normal for this language and project?
3. Does it have flaws, mistakes, inconsistencies, or design gaps?
4. How should it be improved, including test and documentation follow-up?

## Executive Summary

The semantic analyzer is not bad. For a small dynamically typed language, it is a normal and fairly reasonable first semantic pass.

Its strongest qualities are:

- It is small and easy to understand.
- Its responsibilities are limited and mostly clear.
- It performs the most important early checks for this language: duplicate names, identifier binding, direct-call arity validation, and unused parameter warnings.
- It already supports first-class functions and higher-order use cases by intentionally leaving some checks to runtime.

Its main weaknesses are:

- It is a shallow binding pass, not a rich semantic phase.
- It loses source-location information before analysis, which makes diagnostics much weaker than they should be.
- It does not fully resolve function references, so runtime still depends on global mutable scope for identifier-based function lookup.
- It has at least one real traversal bug where some nested nodes are not validated before a top-level shape error is thrown.
- Its public API is a little broader than the implementation it can safely support.
- The documentation is slightly more confident and complete than the implementation really is.

My overall judgment is:

- Quality: decent
- Maturity: early-stage but coherent
- Category: minimal semantic analyzer
- Main issue: not that it is "wrong" in concept, but that it stops halfway between a name binder and a real semantic IR builder

## What The Analyzer Does Today

The implementation in `lib/compiler/semantic/semantic_analyzer.dart` does the following:

1. Converts parsed `FunctionDefinition` values into `CustomFunctionNode` values with `Parameter.any(...)` parameters.
2. Builds one combined function set from user-defined functions plus the standard library.
3. Rejects duplicate function names.
4. Rejects duplicate parameter names.
5. Walks each custom function body and:
   - converts parameter references from `IdentifierNode` to `BoundVariableNode`
   - accepts names that match known functions
   - rejects unknown identifiers
6. Validates argument count for direct identifier calls such as `foo(1, 2)`.
7. Rejects calls to obvious non-callable literals such as `5(1)` and `[1, 2](0)`.
8. Rejects indexing into obvious non-indexable literals such as `5[0]`.
9. Records an `UnusedParameterWarning` for parameters never referenced in the body.

That is a reasonable list for a first semantic phase in a dynamic language.

It is important, however, to describe it accurately:

- It does not infer types.
- It does not propagate types.
- It does not attempt control-flow analysis.
- It does not validate indirect calls.
- It does not resolve function identifiers into stable function references.
- It does not preserve source locations for semantic diagnostics.

So this phase is best described as a binding and shallow validation pass, not as a deep semantic analysis phase.

## Overall Assessment

### Is It Good, Bad, or Normal?

It is normal, with some good choices and some unfinished edges.

I would not call it bad because:

- the implementation is compact and readable
- the current behavior is internally understandable
- the tests cover many core scenarios
- the design fits the language's dynamic nature

I would not call it especially strong yet because:

- too much meaning is still deferred to runtime
- diagnostic quality is low
- there is at least one real mismatch between intended behavior and implementation
- the public contract suggests broader support than the code actually guarantees

If I had to summarize it in one sentence:

This is a good minimal semantic pass for an educational dynamic language, but it should either stay intentionally minimal and be documented as such, or be pushed further into a proper binding layer with better diagnostics and less runtime indirection.

## Strengths

### 1. The Responsibility Boundary Is Mostly Understandable

The analyzer checks names, direct call shape, and a few obviously invalid literal cases. It leaves type validation and higher-order indirect-call validation to runtime. That division is not unreasonable for Primal because:

- the language is dynamically typed
- functions are first-class values
- indirect calls cannot be validated precisely without richer value-flow information

This is visible in `docs/primal.md`, which explicitly describes runtime type checking, and in `docs/compiler/semantic.md`, which already notes that indirect calls are validated at runtime.

### 2. Parameter Binding Is Simple And Works

The `IdentifierNode` to `BoundVariableNode` rewrite is a good idea. It gives the runtime a clear distinction between:

- names that should come from argument bindings
- names that should still be resolved as functions

That is the one genuinely semantic transformation currently performed by the pass, and it is useful.

Example:

```primal
double(x) = x * 2
```

After semantic analysis, `x` in the body is no longer just a raw identifier. It becomes a bound variable.

### 3. Mutual Recursion Works Without Extra Complexity

Because all user-defined functions are collected before body checking, self-recursion and mutual recursion work naturally.

Example:

```primal
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
```

That is the right behavior and the current approach achieves it cleanly.

### 4. The Test Suite Already Covers Many Core Language-Level Cases

`test/compiler/semantic_analyzer_test.dart` covers:

- duplicate functions
- duplicate parameters
- undefined identifiers
- undefined functions
- arity mismatches
- nested identifier use in lists and maps
- literal call/index errors
- recursion
- higher-order call patterns
- parameter shadowing of function names

That is a better starting point than many small language projects have.

## Detailed Findings

## Finding 1: Literal callees are not recursively validated before rejection

Severity: medium

This is the clearest actual bug I found.

In `_checkCall(...)`, the analyzer only recursively validates the callee when the callee is itself a `CallNode`:

- `lib/compiler/semantic/semantic_analyzer.dart:234-243`

It then recursively validates all arguments:

- `lib/compiler/semantic/semantic_analyzer.dart:245-256`

Then it immediately rejects non-callable literals:

- `lib/compiler/semantic/semantic_analyzer.dart:258-264`

That ordering creates a blind spot for literal callees that themselves contain nested expressions.

### Example

```primal
main = [z](0)
```

What should happen conceptually:

- the analyzer should inspect the list literal
- it should discover that `z` is undefined
- it should raise `UndefinedIdentifierError`

What happens today:

- the analyzer sees that the callee is a list literal
- it throws `NotCallableError`
- the nested undefined identifier `z` is never checked

I verified this behavior directly. The compiler reports:

```text
NotCallableError
Compilation error: Cannot call list literal "[z]"
```

By contrast, this related example does inspect the nested content:

```primal
main = [z][0]
```

That one correctly reports `UndefinedIdentifierError`, because indexing validation uses the already-checked first argument.

### Why this matters

The bug is not catastrophic, but it is still a real semantic inconsistency:

- nested expressions are supposed to be checked recursively
- the documentation says nested `CallNode`, `ListNode`, and `MapNode` are checked recursively
- in this case, they are not

### A second example

```primal
main = {"a": z}("a")
```

Today, the same structural issue causes the analyzer to reject the map as a non-callable literal before reporting that `z` is undefined.

Observed behavior:

```text
NotCallableError
Compilation error: Cannot call map literal "{a: z}"
```

### Recommended fix

In `_checkCall(...)`, recursively validate any callee node shape that can contain nested expressions before performing literal-call rejection. The simplest safe approach is:

- validate `callee` with `checkNode(...)` unless it is an `IdentifierNode`
- preserve the direct-identifier special case for arity checking
- then perform literal-call rejection using the validated callee

That would make the traversal logic consistent.

## Finding 2: The analyzer does not fully resolve function references

Severity: medium

Today the analyzer resolves parameter names, but it does not resolve function names into a stable semantic representation.

In `_checkIdentifier(...)`:

- parameter names become `BoundVariableNode`
- known function names remain `IdentifierNode`

Source:

- `lib/compiler/semantic/semantic_analyzer.dart:210-214`

The same pattern exists in `_checkCalleeIdentifier(...)`, where direct identifier calls are arity-checked but the callee stays an `IdentifierNode`:

- `lib/compiler/semantic/semantic_analyzer.dart:365-379`

At runtime, `IdentifierNode.evaluate()` looks up the name in a global static `Runtime.SCOPE`:

- `lib/compiler/runtime/node.dart:210-221`
- `lib/compiler/runtime/runtime.dart:13-18`

There is even a TODO comment in `IdentifierNode` acknowledging the issue:

- `lib/compiler/runtime/node.dart:210-211`

### Why this matters

This means semantic analysis has not fully committed name resolution for functions. It has only proven that the name existed at analysis time.

The actual meaning of the identifier is still supplied later by:

- mutable runtime state
- a global scope object

That has several consequences:

- semantic analysis is weaker than it appears
- runtime and semantics are more tightly coupled than they need to be
- the program representation is less stable than it could be
- testing and reasoning become slightly more indirect

### Example

Given:

```primal
double(x) = x * 2
main = double(5)
```

The semantic pass confirms that `double` exists and that `main` calls it with the right arity. But the resulting `CallNode` still contains an `IdentifierNode("double")`, not a resolved function reference.

So the runtime must look `double` up again later.

### Why this is not immediately "wrong"

Because Primal supports first-class functions and is dynamically typed, deferring some function behavior to runtime is legitimate.

The problem is not that every function use must be fully reduced at compile time.

The problem is narrower:

- direct references to known top-level functions could be resolved more strongly
- direct calls to known top-level functions could carry that resolution forward
- today the analyzer stops earlier than it needs to

### Recommended fix

Introduce a resolved function-reference representation. There are several ways to do it:

1. Add a dedicated node type such as `FunctionReferenceNode(FunctionNode function)`.
2. Allow `CallNode.callee` to directly hold `FunctionNode` for statically resolved direct references.
3. Create a separate semantic IR layer rather than reusing runtime nodes as the semantic output.

Any of those would be stronger than leaving top-level resolved functions as raw identifier strings.

## Finding 3: Source locations are lost before semantic diagnostics are produced

Severity: high for tooling and user experience

Parsed expressions carry source locations:

- `lib/compiler/syntactic/expression.dart:5-157`

But semantic analysis works on runtime `Node` values created by `toNode()` during function extraction:

- `lib/compiler/semantic/semantic_analyzer.dart:68-75`

Runtime nodes do not carry source locations:

- `lib/compiler/runtime/node.dart:8-364`

Semantic errors also only contain messages, not locations:

- `lib/compiler/errors/semantic_error.dart:4-64`

### Why this matters

This is the largest architectural weakness in the current design.

As soon as semantic analysis starts, location information is gone.

That means the analyzer cannot report:

- the exact source location of an undefined identifier
- the exact source location of a wrong-arity call
- the exact location of a duplicate parameter reference inside the signature
- the location of unused parameters

For a language tool, especially one intended for education, this is a real quality gap.

### Example

If a user writes:

```primal
main = foo(bar, baz)
```

and `baz` is undefined, the analyzer can say:

```text
Compilation error: Undefined identifier "baz" in function "main"
```

But it cannot say where `baz` occurred.

That forces the user to scan the whole expression manually.

### Why this happened

The root cause is that semantic analysis currently operates on runtime nodes instead of a location-preserving semantic AST or bound tree.

That is convenient for implementation size, but expensive in diagnostic quality.

### Recommended fix

There are two realistic directions:

1. Keep semantic analysis on the syntactic `Expression` tree and only lower to runtime nodes after semantic checks finish.
2. Add location fields to runtime `Node` types and preserve them during `toNode()` conversion.

Option 1 is cleaner architecturally.
Option 2 is the smaller change.

Either would be a clear improvement over the current state.

## Finding 4: The semantic API is broader than the implementation it can safely support

Severity: low today, medium as the codebase grows

`SemanticAnalyzer.validateExpression(...)` accepts any `Node`:

- `lib/compiler/semantic/semantic_analyzer.dart:19-31`

But `checkNode(...)` only handles:

- `BoundVariableNode`
- `IdentifierNode`
- `CallNode`
- `ListNode`
- `MapNode`
- `BooleanNode`
- `NumberNode`
- `StringNode`

Source:

- `lib/compiler/semantic/semantic_analyzer.dart:157-201`

The runtime node hierarchy includes more types:

- `FileNode`
- `DirectoryNode`
- `TimestampNode`
- `VectorNode`
- `SetNode`
- `StackNode`
- `QueueNode`
- `FunctionNode`
- `NativeFunctionNodeWithArguments`

Source:

- `lib/compiler/runtime/node.dart:75-364`

### Why this matters

Today, `Runtime.evaluate(...)` validates expressions parsed from source:

- `lib/compiler/runtime/runtime.dart:42-47`

Those expressions currently only lower into a smaller subset of node kinds, so the mismatch is not immediately user-visible in normal parsing flows.

But the API still claims a more general contract than the implementation supports.

That creates future fragility:

- a new parser feature could start emitting new node kinds
- an internal caller could pass a valid runtime node to `validateExpression(...)`
- the semantic pass would then throw a raw `StateError`

### Recommended fix

Choose one of these and be explicit:

1. Narrow the API contract so `validateExpression(...)` only accepts nodes that come from parsed expressions.
2. Make `checkNode(...)` exhaustive for all node kinds and define behavior for each one.

Right now it sits awkwardly in between.

## Finding 5: The analyzer is intentionally shallow for indirect calls, but the boundary should be stated more precisely

Severity: low

The analyzer checks arity only for direct identifier calls:

```primal
foo(1, 2)
```

It does not check indirect calls:

```primal
f()(x)
apply(g, v)
list.map(xs, fn)
```

That is explicitly noted in the code and documentation:

- `lib/compiler/semantic/semantic_analyzer.dart:266-268`
- `docs/compiler/semantic.md:14-15`

This is not a flaw by itself. It is a reasonable limitation for a dynamic language with first-class functions.

The issue is that the analyzer currently mixes:

- static certainty for direct top-level identifiers
- runtime fallback for higher-order values

without a stronger conceptual statement of where the line is.

### Why this matters

Users reading "semantic analyzer" may assume more than is actually guaranteed.

For example:

```primal
apply(f, v) = f(v)
main = apply(num.abs, 5)
```

This is valid, but the analyzer cannot prove much about `f` beyond "it is a bound variable being called."

That is fine. It just needs to be documented as an intentional design boundary, not an accidental omission.

### Recommended fix

Document the current boundary explicitly:

- direct calls to known top-level functions get name resolution and arity checks
- bound variables that are called are accepted and validated at runtime
- call results that are called again are accepted and validated at runtime

That wording would make the current behavior much clearer.

## Finding 6: The undefined-name diagnostic model is slightly inconsistent

Severity: low

The analyzer distinguishes:

- `UndefinedIdentifierError` for unknown names in value position
- `UndefinedFunctionError` for unknown names in direct call position

Source:

- `lib/compiler/semantic/semantic_analyzer.dart:216-219`
- `lib/compiler/semantic/semantic_analyzer.dart:381-384`

That is defensible. There is a real contextual difference between:

```primal
main = x
```

and:

```primal
main = x()
```

But the documentation is not perfectly aligned with that distinction.

`docs/compiler.md` currently describes `UndefinedIdentifierError` as:

- "Reference to unknown variable/function"

and separately lists `UndefinedFunctionError` as:

- "Call to unknown function"

Source:

- `docs/compiler.md:132-138`

That wording is close, but still a little muddy because "unknown variable/function" already sounds like it covers both.

### Recommended fix

Document the split precisely:

- `UndefinedIdentifierError`: unknown name in expression/value position
- `UndefinedFunctionError`: unknown name in direct callee position

That would remove ambiguity.

## Finding 7: Top-level collisions with standard-library names are enforced but not clearly documented

Severity: low

The analyzer checks duplicates across:

- user-defined functions
- standard-library functions

Source:

- `lib/compiler/semantic/semantic_analyzer.dart:38-46`

This means a user cannot define a top-level function with the same name as a standard-library function.

For example:

```primal
num.abs(x) = x
```

is rejected as a duplicate function.

That behavior is reasonable, but I did not see it stated clearly in the semantic documentation.

### Why this matters

This is part of the language's namespace rules.

If standard-library names are effectively reserved at top level, that should be explicit.

### Recommended fix

Document that top-level function names share one namespace with the standard library, so user-defined functions cannot redefine standard-library names.

## Finding 8: The analyzer currently uses runtime nodes as semantic output, which keeps it small but limits future growth

Severity: medium

`IntermediateCode` stores a map of runtime `FunctionNode` values:

- `lib/compiler/semantic/intermediate_code.dart:6-18`

That keeps the pipeline small:

- parse
- semantically check
- run

But it also means semantic analysis has no distinct output layer with room for:

- locations
- resolved function references
- richer binding metadata
- optimization-friendly structure
- multiple diagnostics attached to nodes

### Why this matters

This is the architectural reason several other issues exist:

- no locations
- unresolved function identifiers
- weak future extensibility

### Recommended fix

If the language stays small, this may be acceptable.

If you want the compiler to grow, the best long-term move is to separate:

- syntactic AST
- semantic/bound AST or semantic IR
- runtime/evaluation nodes

That would make the pipeline clearer and reduce leakage between phases.

## Finding 9: The current warning model is minimal but coherent

Severity: observation, not a defect

There is only one semantic warning today:

- `UnusedParameterWarning`

Source:

- `lib/compiler/warnings/semantic_warning.dart:7-12`

That is fine for now. I do not think the analyzer needs a large warning system immediately.

Still, if you later want to grow warnings, this phase would be the natural place for a few lightweight additions, such as:

- unreachable `if` branches when the condition is a boolean literal
- obviously redundant calls such as calling a known zero-parameter constant with arguments
- shadowing-related informational warnings if the language evolves

I would not prioritize this now. It is a possible future direction, not a current need.

## Findings About The Documentation

### 1. `docs/compiler/semantic.md` Is Directionally Right But Slightly Stronger Than Reality

The document is compact and mostly matches the implementation, but it should be tightened in a few places.

The biggest mismatch is the recursive-checking statement:

- the doc says nested `CallNode`, `ListNode`, and `MapNode` are checked recursively
- the literal-callee case shows that this is not fully true today

It would also benefit from clearer statements about:

- direct vs indirect call validation
- the fact that function identifiers remain runtime-resolved today
- the fact that there is no source-location-aware semantic diagnostic layer yet

### 2. `docs/compiler.md` Should Clarify Undefined-Name Errors

As noted above, the compiler overview already lists both errors, but the distinction should be sharper.

It should also explain that some invalid program shapes are caught:

- statically for direct calls and obvious literal misuse
- dynamically for higher-order and type-driven behavior

### 3. The Docs Should State Whether Standard-Library Names Are Reserved At Top Level

That behavior appears to exist in the implementation through duplicate-name checking against the combined function set.

If that is intentional, it belongs in the language/compiler docs.

## Findings About The Tests

The existing semantic tests are solid for the current feature set, but they are missing a few cases that matter now.

The biggest coverage gap is around traversal order and nested validation inside literal callees.

## Recommended Improvements

### Short-Term Improvements

These are low-risk, high-value changes that would improve correctness without redesigning the entire compiler.

### 1. Fix the literal-callee traversal bug

This should be first.

Target behavior:

- `main = [z](0)` should report `UndefinedIdentifierError`
- `main = {"a": z}("a")` should report `UndefinedIdentifierError`
- `main = {"a": unknown()}("a")` should report `UndefinedFunctionError`

The analyzer should validate nested content before rejecting the outer literal as non-callable.

### 2. Clarify the current semantic boundary in docs

Even if the code stays exactly as it is, the documentation should be more explicit about what is and is not guaranteed.

### 3. Tighten the `validateExpression(...)` contract

Either make it exhaustive or make it narrower.

Right now it is too easy for future code to assume it validates "any node" when that is not actually true.

### Medium-Term Improvements

These changes would materially improve the quality of the semantic phase.

### 4. Preserve source locations into semantic diagnostics

This is the biggest quality upgrade available.

Even without any new static analysis features, location-aware errors would make the language much easier to use.

### 5. Resolve direct function references more strongly

If the analyzer already knows that an identifier refers to a specific function, it should be able to encode that fact in the output representation.

That would reduce dependence on global runtime scope and make the semantic output more meaningful.

### Long-Term Improvements

These are architectural changes that are probably only worth doing if the compiler is going to grow significantly.

### 6. Separate semantic IR from runtime nodes

This would make it easier to add:

- better diagnostics
- richer binding information
- future optimizations
- cleaner runtime execution

### 7. Consider multi-error reporting

Right now the analyzer fails fast on the first semantic error.

That is fine for a small interpreter, but a better user experience would be:

- collect several semantic errors from one pass
- report them together
- still abort execution

This is not required yet, but it would be a meaningful improvement later.

## Detailed Test Update Plan

This section is a plan only. It does not assume that all tests should be added immediately, but it identifies the most useful additions.

### Priority 1: Regression Tests For The Literal-Callee Traversal Bug

File:

- `test/compiler/semantic_analyzer_test.dart`

Add tests like:

```primal
main = [z](0)
```

Expected result after bug fix:

- throws `UndefinedIdentifierError`

Add:

```primal
main = {"a": z}("a")
```

Expected result after bug fix:

- throws `UndefinedIdentifierError`

Add:

```primal
main = {"a": unknown()}("a")
```

Expected result after bug fix:

- throws `UndefinedFunctionError`

Add:

```primal
main = [unknown()](0)
```

Expected result after bug fix:

- throws `UndefinedFunctionError`

These tests are important because they validate traversal order, not just end-state shape rules.

### Priority 2: Namespace-Rule Tests For Standard-Library Name Collisions

If the intended rule is "top-level user functions cannot redefine standard-library functions," add tests that say so explicitly.

Example:

```primal
num.abs(x) = x
```

Expected result:

- throws `DuplicatedFunctionError`

This behavior should not remain implicit.

### Priority 3: Contract Tests For `validateExpression(...)`

If the current broad API stays, add tests that verify behavior for each supported node kind and define what should happen with unsupported ones.

If the API is narrowed, add tests that validate only parser-originated node shapes and remove ambiguity from the public contract.

### Priority 4: Location-Aware Diagnostic Tests If Locations Are Added

If semantic diagnostics become location-aware, add tests that assert:

- undefined identifiers report exact row and column
- wrong-arity direct calls report exact callee location
- duplicate parameters report exact duplicated parameter location

This would significantly improve the reliability of future diagnostic work.

## Detailed Documentation Update Plan

This section is also a plan only.

### `docs/compiler/semantic.md`

Recommended updates:

1. Describe the analyzer as a shallow binding and validation pass, not a broad semantic system.
2. Clarify that only direct identifier calls receive static arity checks.
3. Clarify that function identifiers currently remain runtime-resolved after semantic analysis.
4. Fix the recursive-check wording so it matches the implementation, or update it after the traversal bug is fixed.
5. State that top-level user-defined functions share a namespace with standard-library functions.

Suggested wording direction:

- "The semantic analyzer binds parameter references, validates names, validates direct call arity, and rejects some obviously invalid literal call/index operations."
- "Indirect calls and type-sensitive behavior remain runtime-validated."

### `docs/compiler.md`

Recommended updates:

1. Sharpen the distinction between `UndefinedIdentifierError` and `UndefinedFunctionError`.
2. Clarify which errors are purely semantic-shape errors and which are runtime type/value errors.
3. Mention that some call forms are intentionally deferred to runtime due to first-class functions and dynamic typing.

### `docs/primal.md`

This file does not necessarily need a semantic-analyzer section, but if you want the language manual to be more precise, it could mention:

- names are resolved against function declarations and local parameters
- direct call shape errors can be detected before execution
- many type-related checks remain runtime checks

That would better align the language overview with the actual implementation strategy.

## Recommended Implementation Order

If the goal is pragmatic improvement with low churn, I would do the work in this order:

1. Fix the literal-callee traversal bug.
2. Add regression tests for it.
3. Update `docs/compiler/semantic.md` and `docs/compiler.md` to reflect the actual current boundary.
4. Decide whether top-level standard-library name collisions are intentional language behavior.
5. Preserve locations into semantic diagnostics.
6. Resolve direct function references more strongly.
7. Only then consider introducing a separate semantic IR, if the project needs it.

That order gives the best value without forcing a large redesign too early.

## Final Assessment

The semantic analyzer is currently a respectable minimal pass, not a broken one.

Its main strengths are simplicity, readability, and a scope that fits a small dynamic language.

Its main weaknesses are:

- one real traversal bug
- incomplete binding of function references
- loss of source locations
- a semantic/runtime boundary that is correct in spirit but under-specified in both code structure and documentation

If the project wants to keep the compiler small, the analyzer can remain lightweight. In that case, the most important work is:

- fix the traversal bug
- tighten the docs
- make the public contract more honest

If the project wants to make the compiler meaningfully stronger, the next major step should be:

- preserve locations
- introduce stronger function-reference binding
- stop using raw runtime nodes as the semantic output format

That is the real fork in the road.
