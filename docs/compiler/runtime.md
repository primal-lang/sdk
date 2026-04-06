# Runtime

**Files**: `lib/compiler/runtime/runtime.dart`, `lib/compiler/runtime/term.dart`, `lib/compiler/runtime/bindings.dart`

The runtime evaluates compiled code through **term substitution and reduction**. It receives `IntermediateRepresentation` from the semantic analyzer and lowers semantic IR to runtime terms for execution.

## Initialization

When a `RuntimeFacade` is created, the `RuntimeInputBuilder` constructs a `RuntimeInput`:

1. Standard library functions are fetched from `StandardLibrary.get()` as `FunctionTerm` instances and stored in a functions map.
2. The `Lowerer` is created with access to this functions map.
3. Each `SemanticFunction` from `IntermediateRepresentation` is lowered to a `CustomFunctionTerm` and added to the map.
4. Function references (`SemanticIdentifierNode`) are lowered to `FunctionReferenceTerm`, which holds the function name and a reference to the shared functions map.

Note: `IntermediateRepresentation` contains only `FunctionSignature` references for the standard library (not `FunctionTerm`), keeping the semantic output free of runtime types. The actual runtime terms are instantiated during this initialization step.

## Term Hierarchy

All runtime values are terms. The base `Term` class defines:

- `type` - returns the term's `Type`.
- `substitute(Bindings)` - replaces bound variables with their argument values.
- `reduce()` - reduces the term to a value.
- `native()` - converts to a native Dart value.

**Literal terms** (self-evaluating):
`BooleanTerm`, `NumberTerm`, `StringTerm`, `FileTerm`, `DirectoryTerm`, `TimestampTerm`

**Collection terms** (substitute recursively; self-evaluating):
`ListTerm`, `MapTerm`, `SetTerm`, `VectorTerm`, `StackTerm`, `QueueTerm`

**Reference terms**:

- `FunctionReferenceTerm(name, functions)` - holds a function name and the functions map; `reduce()` returns the referenced `FunctionTerm`.
- `BoundVariableTerm(name)` - replaced during substitution via bindings.

**Call term**:
`CallTerm(callee, arguments)` - on evaluation, reduces the callee to a `FunctionTerm`, then calls `apply()` with the arguments.

**Function terms**:

- `FunctionTerm` - base, with name and parameters.
- `CustomFunctionTerm` - user-defined; `apply()` substitutes arguments into the body, then reduces.
- `NativeFunctionTerm` - built-in; delegates to a Dart implementation.

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

## Evaluation Model

Function application follows these steps:

1. Reduce the callee expression to get a `FunctionTerm`.
2. Create `Bindings` from the function's parameters and the provided arguments.
3. Substitute all `BoundVariableTerm`s in the function body with their bound values.
4. Reduce the resulting term.

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
