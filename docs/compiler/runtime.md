# Runtime

**Files**: `lib/compiler/runtime/runtime.dart`, `lib/compiler/runtime/node.dart`, `lib/compiler/runtime/bindings.dart`

The runtime evaluates compiled code through **node substitution and reduction**. It receives `IntermediateRepresentation` from the semantic analyzer and lowers semantic IR to runtime nodes for execution.

## Initialization

When a `RuntimeFacade` is created, the `RuntimeInputBuilder` constructs a `RuntimeInput`:

1. Standard library functions are fetched from `StandardLibrary.get()` as `FunctionNode` instances and stored in a functions map.
2. The `Lowerer` is created with access to this functions map.
3. Each `SemanticFunction` from `IntermediateRepresentation` is lowered to a `CustomFunctionNode` and added to the map.
4. Function references (`SemanticIdentifierNode`) are lowered to `FunctionReferenceNode`, which holds the function name and a reference to the shared functions map.

Note: `IntermediateRepresentation` contains only `FunctionSignature` references for the standard library (not `FunctionNode`), keeping the semantic output free of runtime types. The actual runtime nodes are instantiated during this initialization step.

## Node Hierarchy

All runtime values are nodes. The base `Node` class defines:

- `type` - returns the node's `Type`.
- `substitute(Bindings)` - replaces bound variables with their argument values.
- `evaluate()` - reduces the node to a value.
- `native()` - converts to a native Dart value.

**Literal nodes** (self-evaluating):
`BooleanNode`, `NumberNode`, `StringNode`, `FileNode`, `DirectoryNode`, `TimestampNode`

**Collection nodes** (substitute recursively; self-evaluating):
`ListNode`, `MapNode`, `SetNode`, `VectorNode`, `StackNode`, `QueueNode`

**Reference nodes**:

- `FunctionReferenceNode(name, functions)` - holds a function name and the functions map; `evaluate()` returns the referenced `FunctionNode`.
- `BoundVariableNode(name)` - replaced during substitution via bindings.

**Call node**:
`CallNode(callee, arguments)` - on evaluation, evaluates the callee to a `FunctionNode`, then calls `apply()` with the arguments.

**Function nodes**:

- `FunctionNode` - base, with name and parameters.
- `CustomFunctionNode` - user-defined; `apply()` substitutes arguments into the body, then evaluates.
- `NativeFunctionNode` - built-in; delegates to a Dart implementation.

### Native Function Implementation Pattern

Each native function follows a two-class pattern:

```dart
// 1. Definition class - declares name, parameters, and types
class FunctionName extends NativeFunctionNode {
  FunctionName() : super(
    name: 'namespace.function',
    parameters: [Parameter.type('arg1'), Parameter.any('arg2')],
  );

  @override
  Node node(List<Node> arguments) => _Node(
    name: name, parameters: parameters, arguments: arguments,
  );
}

// 2. Evaluation class - implements the actual logic
class _Node extends NativeFunctionNodeWithArguments {
  @override
  Node evaluate() {
    // Validate argument types, compute result, return a Node
  }
}
```

## Evaluation Model

Function application follows these steps:

1. Evaluate the callee expression to get a `FunctionNode`.
2. Create `Bindings` from the function's parameters and the provided arguments.
3. Substitute all `BoundVariableNode`s in the function body with their bound values.
4. Evaluate the resulting node.

This is a substitution-based evaluation model consistent with lambda calculus beta-reduction.

## Function Resolution

Function references are resolved at lowering time, not runtime. The `Lowerer` converts `SemanticIdentifierNode` (which contains a resolved `FunctionSignature`) to `FunctionReferenceNode`, passing the shared functions map. At evaluation time, `FunctionReferenceNode.evaluate()` looks up the function in the map.

This approach:

- Supports forward references and mutual recursion (the map is populated as functions are lowered)
- Maintains explicit dependency injection (the functions map is passed at construction time)

## Separation from Semantic Analysis

The runtime layer is intentionally minimal:

- It receives **lowered** nodes (no source locations).
- Semantic validation happens earlier in the pipeline.
- Runtime errors (type mismatches, missing keys) are detected during evaluation.

This separation keeps the runtime focused on evaluation while semantic analysis handles validation and source tracking.
