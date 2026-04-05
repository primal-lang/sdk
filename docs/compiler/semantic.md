# Semantic Analysis

**Files**: `lib/compiler/semantic/semantic_analyzer.dart`, `lib/compiler/semantic/semantic_node.dart`, `lib/compiler/semantic/semantic_function.dart`, `lib/compiler/semantic/lowerer.dart`

The semantic analyzer validates parsed function definitions and produces `IntermediateRepresentation` containing a **semantic IR** (intermediate representation) that preserves source locations and resolved references.

## Pipeline Position

```
Syntactic AST (Expression, FunctionDefinition)
    ↓
Semantic Analyzer
    ↓
Semantic IR (SemanticNode, SemanticFunction)
    ↓
Lowerer
    ↓
Runtime Nodes (Node, CustomFunctionNode)
```

## Semantic Checks

1. **Function extraction** - converts each `FunctionDefinition` into a `SemanticFunction` with untyped parameters.
2. **Duplicate function detection** - reports an error if two functions share the same name.
3. **Duplicate parameter detection** - reports an error if a function has repeated parameter names.
4. **Identifier resolution** - for every identifier in a function body:
   - If it matches a parameter name, it becomes a `SemanticBoundVariableNode`.
   - If it matches a known function name (custom or standard library), it becomes a `SemanticIdentifierNode` with a resolved function reference.
   - Otherwise, an `UndefinedIdentifierError` is raised.
5. **Call validation** - for direct identifier calls (e.g., `foo(1, 2)`), the argument count is checked against the callee's parameter count. Indirect calls (e.g., `f()(x)`) are validated at runtime.
6. **Literal validation** - rejects attempts to call non-callable literals (numbers, booleans, strings, lists, maps) or index non-indexable literals (numbers, booleans).
7. **Unused parameter warnings** - parameters that are never referenced in the function body produce a warning.

Nested structures (`SemanticCallNode`, `SemanticListNode`, `SemanticMapNode`) are checked recursively.

## Semantic IR

The semantic IR is a bound AST that preserves source information lost in runtime nodes:

### SemanticNode Hierarchy

**File**: `lib/compiler/semantic/semantic_node.dart`

| Node Type                   | Description                                                       |
| --------------------------- | ----------------------------------------------------------------- |
| `SemanticBooleanNode`       | Boolean literal with location                                     |
| `SemanticNumberNode`        | Numeric literal with location                                     |
| `SemanticStringNode`        | String literal with location                                      |
| `SemanticListNode`          | List literal with location and semantic elements                  |
| `SemanticMapNode`           | Map literal with location and semantic entries                    |
| `SemanticIdentifierNode`    | Function reference with location and resolved `FunctionSignature` |
| `SemanticBoundVariableNode` | Parameter reference with location                                 |
| `SemanticCallNode`          | Function call with location, callee, and arguments                |

### SemanticFunction

**File**: `lib/compiler/semantic/semantic_function.dart`

```dart
class SemanticFunction {
  final String name;
  final List<Parameter> parameters;
  final SemanticNode body;
  final Location location;
}
```

Represents a user-defined function with its semantic body and source location.

## Intermediate Code

**File**: `lib/compiler/semantic/intermediate_representation.dart`

The output of semantic analysis:

- `customFunctions`: `Map<String, SemanticFunction>` - user-defined functions with semantic IR bodies.
- `standardLibrarySignatures`: `Map<String, FunctionSignature>` - signatures of built-in functions (without runtime dependencies).
- `warnings`: `List<GenericWarning>` - any warnings produced during analysis.

The actual runtime `FunctionNode` instances for the standard library are obtained during lowering via `StandardLibrary.get()`, not stored in `IntermediateRepresentation`. This keeps the semantic output free of runtime types.

Helper methods:

- `containsFunction(name)` - checks if a function exists (custom or stdlib).
- `allFunctionNames` - returns all function names.
- `getCustomFunction(name)` - returns a custom function by name.
- `getStandardLibrarySignature(name)` - returns a stdlib function signature by name.

## Lowerer

**File**: `lib/compiler/semantic/lowerer.dart`

The lowerer converts semantic IR to runtime nodes for evaluation:

```dart
class Lowerer {
  CustomFunctionNode lowerFunction(SemanticFunction function);
  Node lowerNode(SemanticNode node);
}
```

- `lowerFunction()` converts user-defined functions to `CustomFunctionNode`.
- `lowerNode()` converts semantic expressions to runtime `Node` instances.

This pass strips source locations and produces the minimal runtime representation needed for the substitution-based evaluation model. The lowerer operates only on semantic types (`SemanticNode`, `SemanticFunction`) and produces runtime types (`Node`, `CustomFunctionNode`), maintaining clean phase separation.

| Semantic Node               | Runtime Node        |
| --------------------------- | ------------------- |
| `SemanticBooleanNode`       | `BooleanNode`       |
| `SemanticNumberNode`        | `NumberNode`        |
| `SemanticStringNode`        | `StringNode`        |
| `SemanticListNode`          | `ListNode`          |
| `SemanticMapNode`           | `MapNode`           |
| `SemanticIdentifierNode`    | `FunctionRefNode`   |
| `SemanticBoundVariableNode` | `BoundVariableNode` |
| `SemanticCallNode`          | `CallNode`          |

## Phase Boundaries

The semantic phase maintains strict separation from the runtime phase:

- **No runtime imports** - `semantic_node.dart`, `semantic_analyzer.dart`, and `intermediate_representation.dart` do not import from `runtime/`.
- **FunctionSignature abstraction** - instead of storing `FunctionNode` references, the semantic phase uses `FunctionSignature` for call validation.
- **Lowering is one-way** - `Lowerer` converts semantic IR to runtime nodes, but never the reverse.

This separation ensures that:

1. Semantic analysis can be performed without instantiating runtime nodes.
2. The runtime layer remains focused purely on evaluation.
3. Future optimizations can operate on semantic IR without affecting runtime behavior.

## Design Rationale

Separating semantic IR from runtime nodes enables:

- **Source locations** - error messages and diagnostics can point to exact source positions.
- **Resolved references** - function identifiers are resolved at compile time, enabling static arity checking.
- **Extensibility** - future passes (optimization, type inference) can operate on the semantic IR without affecting runtime evaluation.
- **Clean separation** - the runtime layer focuses purely on evaluation, not validation.
