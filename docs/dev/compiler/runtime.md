---
title: Runtime
tags: [compiler, runtime]
sources: [lib/compiler/runtime/]
---

# Runtime

**TLDR**: The runtime evaluates programs using a substitution-based model (beta reduction), where function application binds arguments to parameters and reduces the substituted body, with eager evaluation for arguments and lazy evaluation for conditionals.

**Files**: `lib/compiler/runtime/runtime.dart`, `lib/compiler/runtime/term.dart`, `lib/compiler/runtime/bindings.dart`, `lib/compiler/runtime/runtime_input.dart`

The runtime evaluates compiled code through **term substitution and reduction**. It receives `IntermediateRepresentation` from the semantic analyzer and lowers semantic IR to runtime terms for execution.

## Initialization

When a `RuntimeFacade` is created, the `RuntimeInputBuilder` constructs a `RuntimeInput`:

1. Standard library functions are fetched from `StandardLibrary.get()` as `FunctionTerm` instances and stored in a functions map.
2. The `Lowerer` is created with access to this functions map.
3. Each `SemanticFunction` from `IntermediateRepresentation` is lowered to a `CustomFunctionTerm` and added to the map.
4. Function references (`SemanticIdentifierNode`) are lowered to `FunctionReferenceTerm`, which holds the function name and a reference to the shared functions map.

Note: `IntermediateRepresentation` contains only `FunctionSignature` references for the standard library (not `FunctionTerm`), keeping the semantic output free of runtime types. The actual runtime terms are instantiated during this initialization step.

## RuntimeInput

`RuntimeInput` holds the shared functions map used by the runtime:

- `functions` - a `Map<String, FunctionTerm>` containing all available functions (standard library and user-defined).
- `containsFunction(String name)` - returns whether a function with the given name exists.
- `getFunction(String name)` - returns the `FunctionTerm` for the given name, or `null`.

## Runtime

`Runtime` wraps a `RuntimeInput` and provides evaluation and output formatting:

- `reduceTerm(Term term)` - reduces a term to its value by calling `term.reduce()`.
- `format(dynamic value)` - converts a native Dart value to its display representation. Booleans and numbers pass through unchanged. Strings, `DateTime`, `File`, and `Directory` values are quoted. Collections (`Set`, `List`, `Map`) are formatted recursively. Throws `InvalidValueError` for unrecognized types.

## Term Hierarchy

All runtime values are terms. The base `Term` class defines:

- `type` - returns the term's `Type`.
- `substitute(Bindings bindings)` - replaces bound variables with their argument values. Default: returns `this`.
- `reduce()` - reduces the term to a value. Default: returns `this`.
- `native()` - converts to a native Dart value.

### ValueTerm

`ValueTerm<T>` is the abstract base for all terms that hold a typed value. It implements `Term` with:

- `value` - the underlying Dart value of type `T`.
- `substitute(Bindings bindings)` - returns `this` (values are self-evaluating).
- `reduce()` - returns `this`.
- `native()` - returns `value`.
- `ValueTerm.from(dynamic value)` - static factory that wraps a native Dart value in the appropriate term type (`bool` to `BooleanTerm`, `num` to `NumberTerm`, `String` to `StringTerm`, `DateTime` to `TimestampTerm`, `File` to `FileTerm`, `Directory` to `DirectoryTerm`, `Set<Term>` to `SetTerm`, `List<Term>` to `ListTerm`, `Map<Term, Term>` to `MapTerm`). Throws `InvalidLiteralValueError` for unrecognized types.

### Literal Terms

Self-evaluating terms that extend `ValueTerm`:

`BooleanTerm`, `NumberTerm`, `StringTerm`, `FileTerm`, `DirectoryTerm`, `TimestampTerm`

### Collection Terms

Collection terms extend `ValueTerm`, override `substitute` to recurse into their elements, and override `native()` to return unwrapped Dart collections:

- `ListTerm` - wraps `List<Term>`.
- `VectorTerm` - wraps `List<Term>`.
- `SetTerm` - wraps `Set<Term>`.
- `StackTerm` - wraps `List<Term>`.
- `QueueTerm` - wraps `List<Term>`.
- `MapTerm` - wraps `Map<Term, Term>`. Additionally provides `asMapWithKeys()`, which returns a `Map<dynamic, Term>` with native keys but term values.

### Reference Terms

- `FunctionReferenceTerm(name, functions)` - holds a function name and the functions map; `reduce()` returns the referenced `FunctionTerm`. Throws `NotFoundInScopeError` if the name is not in the map.
- `BoundVariableTerm(name)` - replaced during substitution via bindings. Calling `native()` throws a `StateError` since bound variables must be substituted before evaluation.
- `LetBoundVariableTerm(name)` - represents a reference to a let binding; replaced during `LetTerm` reduction via partial substitution. Unlike `BoundVariableTerm`, it is not affected by function parameter bindings.
- `LambdaBoundVariableTerm(name)` - represents a reference to a lambda parameter; replaced during `LambdaTerm.apply()` via partial substitution. Returns itself when the name is not found in bindings, allowing outer scope substitution to pass through without affecting lambda parameter references.

### Call Term

`CallTerm({required callee, required arguments})` - on evaluation, reduces the callee to a `FunctionTerm` via `getFunctionTerm()`, then calls `apply()` with the arguments. The `getFunctionTerm()` helper throws `InvalidFunctionError` if the reduced callee is not a `FunctionTerm`. Substitution recurses into both callee and arguments.

### Let Term

`LetTerm({required bindings, required body})` - represents a let expression with local bindings. The `bindings` field is a `List<(String, Term)>` of name-value pairs, and `body` is the expression to evaluate with bindings in scope.

**Evaluation** (`reduce()`):

1. Bindings are evaluated sequentially (call-by-value).
2. Each binding value is reduced, then substituted into subsequent bindings and the body.
3. `LetBoundVariableTerm` instances matching the binding name are replaced with the reduced value.
4. After all bindings are processed, the body is reduced and returned.

**Substitution** (`substitute(Bindings bindings)`):

- Recurses into binding values and body, propagating function parameter bindings.
- Does not affect `LetBoundVariableTerm` instances (they are handled during `reduce()`).

### Function Terms

`FunctionTerm` is the abstract base for all functions, with `name` and `parameters` fields.

**Recursion tracking**: `FunctionTerm` maintains a static recursion depth counter (`maxRecursionDepth = 1000`). This assumes single-threaded execution.

- `resetDepth()` - resets the counter to zero. Called before starting evaluation.
- `incrementDepth()` - increments the counter and returns `true`. Throws `RecursionLimitError` if the limit is exceeded.
- `decrementDepth()` - decrements the counter.

**Instance members**:

- `parameterTypes` - returns the list of parameter types.
- `equalSignature(FunctionTerm function)` - returns whether two functions share the same name.
- `toSignature()` - returns a phase-agnostic `FunctionSignature`.
- `apply(List<Term> arguments)` - validates argument count (throws `InvalidArgumentCountError` on mismatch), creates `Bindings` from parameters and arguments, substitutes, and reduces.
- `native()` - returns the function's string representation.

**Subclasses**:

- `CustomFunctionTerm` - user-defined; holds a `term` (the function body). Overrides `apply()` to increment/decrement recursion depth, eagerly evaluate all arguments before binding (call-by-value), then substitute and reduce. Overrides `substitute(Bindings bindings)` to substitute into the body term.
- `NativeFunctionTerm` - built-in; overrides `substitute(Bindings bindings)` to resolve each parameter from the bindings and pass the resulting argument list to the abstract `term(List<Term> arguments)` method, which returns a concrete evaluation term.
- `NativeFunctionTermWithArguments` - holds pre-resolved `arguments`; subclasses override `reduce()` to implement the actual logic.
- `LambdaTerm` - anonymous function created from a lambda expression; holds `body` (the lambda body term). Overrides `substitute(Bindings bindings)` to propagate substitution through the body (preserving the lambda wrapper for closures). Overrides `apply()` to substitute directly into the body and reduce, enabling proper closure semantics. Lambda parameters are represented as `LambdaBoundVariableTerm` references that survive outer substitution until the lambda is invoked.

### Native Function Implementation Pattern

Each native function follows a two-class pattern:

```dart
// 1. Definition class - declares name, parameters, and types
class FunctionName extends NativeFunctionTerm {
  FunctionName() : super(
    name: 'namespace.function',
    parameters: [Parameter.type('arg1'), Parameter.any('arg2')],
  );

  @override
  Term term(List<Term> arguments) => _Term(
    name: name, parameters: parameters, arguments: arguments,
  );
}

// 2. Evaluation class - implements the actual logic
class _Term extends NativeFunctionTermWithArguments {
  @override
  Term reduce() {
    // Validate argument types, compute result, return a Term
  }
}
```

## Bindings

`Bindings` maps parameter names to their argument terms:

- `Bindings(Map<String, Term> data)` - wraps an existing map.
- `Bindings.from({required List<Parameter> parameters, required List<Term> arguments})` - factory that pairs each parameter name with the corresponding argument term by index.
- `get(String name)` - returns the term bound to the given name. Throws `NotFoundInScopeError` if the name is not present.

## Evaluation Model

Function application follows these steps:

1. Reduce the callee expression to get a `FunctionTerm`.
2. For `CustomFunctionTerm`: increment recursion depth, eagerly evaluate all arguments (call-by-value), create `Bindings`, substitute into the body, reduce, then decrement recursion depth.
3. For `NativeFunctionTerm` (via the base `FunctionTerm.apply()`): validate argument count, create `Bindings`, substitute (which resolves parameters and delegates to `term()`), then reduce.

This is a substitution-based evaluation model consistent with lambda calculus beta-reduction.

## Function Resolution

Function references are resolved at lowering time, not runtime. The `Lowerer` converts `SemanticIdentifierNode` (which contains a resolved `FunctionSignature`) to `FunctionReferenceTerm`, passing the shared functions map. At evaluation time, `FunctionReferenceTerm.reduce()` looks up the function in the map.

This approach:

- Supports forward references and mutual recursion (the map is populated as functions are lowered)
- Maintains explicit dependency injection (the functions map is passed at construction time)

## Separation from Semantic Analysis

The runtime layer is intentionally minimal:

- It receives **lowered** terms (no source locations).
- Semantic validation happens earlier in the pipeline.
- Runtime errors (type mismatches, missing keys) are detected during evaluation.

This separation keeps the runtime focused on evaluation while semantic analysis handles validation and source tracking.
