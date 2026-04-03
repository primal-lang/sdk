# Runtime

**Files**: `lib/compiler/runtime/runtime.dart`, `lib/compiler/runtime/node.dart`, `lib/compiler/runtime/bindings.dart`, `lib/compiler/runtime/scope.dart`

The runtime evaluates intermediate code through **node substitution and reduction**.

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

**Variable nodes**:

- `IdentifierNode(name)` - resolved at runtime by looking up `name` in the global scope.
- `BoundVariableNode(name)` - replaced during substitution via bindings.

**Call node**:
`CallNode(callee, arguments)` - on evaluation, evaluates the callee to a `FunctionNode`, then calls `apply()` with the arguments.

**Function nodes**:

- `FunctionNode` - base, with name and parameters.
- `CustomFunctionNode` - user-defined; `apply()` substitutes arguments into the body, then evaluates.
- `NativeFunctionNode` - built-in; delegates to a Dart implementation.

## Evaluation Model

Function application follows these steps:

1. Evaluate the callee expression to get a `FunctionNode`.
2. Create `Bindings` from the function's parameters and the provided arguments.
3. Substitute all `BoundVariableNode`s in the function body with their bound values.
4. Evaluate the resulting node.

This is a substitution-based evaluation model consistent with lambda calculus reduction.

## Scope

`Scope` (`lib/compiler/runtime/scope.dart`) is a global map from function names to `FunctionNode` definitions, stored as `Runtime.SCOPE`. `IdentifierNode`s in function bodies are resolved against this scope at evaluation time.
