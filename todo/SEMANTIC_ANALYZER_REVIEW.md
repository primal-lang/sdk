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
