# Semantic Analysis

**Files**: `lib/compiler/semantic/semantic_analyzer.dart`, `lib/compiler/semantic/semantic_node.dart`, `lib/compiler/semantic/semantic_function.dart`, `lib/compiler/semantic/intermediate_representation.dart`, `lib/compiler/lowering/lowerer.dart`, `lib/compiler/lowering/runtime_input_builder.dart`, `lib/compiler/lowering/runtime_facade.dart`

The semantic analyzer validates parsed function definitions and produces `IntermediateRepresentation` containing a **semantic IR** (intermediate representation) that preserves source locations and resolved references.

## Pipeline Position

```
Syntactic AST (Expression, FunctionDefinition)
    ↓
Semantic Analyzer
    ↓
Semantic IR (IntermediateRepresentation)
    ↓
RuntimeInputBuilder → Lowerer
    ↓
RuntimeInput (Map<String, FunctionTerm>)
    ↓
RuntimeFacade (evaluation entry point)
```

## Semantic Checks

1. **Function extraction** - converts each `FunctionDefinition` into a `SemanticFunction` with untyped parameters.
2. **Duplicate function detection** - reports a `DuplicatedFunctionError` if two custom functions share the same name, or if a custom function conflicts with a standard library function.
3. **Duplicate parameter detection** - reports a `DuplicatedParameterError` if a function has repeated parameter names.
4. **Identifier resolution** - for every identifier in a function body:
   - If it matches a let binding name (within scope), it becomes a `SemanticBoundVariableNode` with `isLetBinding: true`.
   - If it matches a parameter name, it becomes a `SemanticBoundVariableNode` with `isLetBinding: false`.
   - If it matches a known function name (custom or standard library), it becomes a `SemanticIdentifierNode` with a resolved `FunctionSignature`.
   - Otherwise, an `UndefinedIdentifierError` is raised (with optional function context via the `inFunction` parameter).
5. **Call validation** - for direct identifier calls (e.g., `foo(1, 2)`):
   - If the callee is a parameter or let binding, it becomes a `SemanticBoundVariableNode` (validated at runtime).
   - If the callee is a known function, the argument count is checked against the callee's arity. Mismatches raise `InvalidNumberOfArgumentsError`.
   - If the callee is undefined, an `UndefinedFunctionError` is raised.
   - Indirect calls (e.g., `f()(x)`) are validated at runtime.
6. **Literal validation** - rejects attempts to call non-callable literals (numbers, booleans, strings, lists, maps) with `NotCallableError`, or index non-indexable literals (numbers, booleans) with `NotIndexableError`.
7. **Unused parameter warnings** - parameters that are never referenced in the function body produce an `UnusedParameterWarning`.
8. **Let expression validation** - for `let name = value in body`:
   - Reports `ShadowedLetBindingError` if a binding name matches a function parameter.
   - Reports `DuplicatedLetBindingError` if binding names are repeated within the same let expression.
   - Bindings are processed sequentially, so later bindings can reference earlier ones.
   - Let bindings can shadow function names (the binding takes precedence within the body).

Nested structures (`SemanticCallNode`, `SemanticListNode`, `SemanticMapNode`) are checked recursively.

## Semantic IR

The semantic IR is a bound AST that preserves source information lost in runtime terms:

### SemanticNode Hierarchy

**File**: `lib/compiler/semantic/semantic_node.dart`

| Node Type                   | Description                                                                             |
| --------------------------- | --------------------------------------------------------------------------------------- |
| `SemanticNode`              | Abstract base class for all semantic IR nodes; holds a `Location`                       |
| `SemanticLiteralNode<T>`    | Abstract base class for literal nodes; extends `SemanticNode` with a `T value`          |
| `SemanticBooleanNode`       | Boolean literal (`SemanticLiteralNode<bool>`)                                           |
| `SemanticNumberNode`        | Numeric literal (`SemanticLiteralNode<num>`)                                            |
| `SemanticStringNode`        | String literal (`SemanticLiteralNode<String>`)                                          |
| `SemanticListNode`          | List literal (`SemanticLiteralNode<List<SemanticNode>>`)                                |
| `SemanticMapEntryNode`      | Key-value pair holding two `SemanticNode` fields (`key`, `value`)                       |
| `SemanticMapNode`           | Map literal (`SemanticLiteralNode<List<SemanticMapEntryNode>>`)                         |
| `SemanticIdentifierNode`    | Function reference with `name` and optional resolved `FunctionSignature`                |
| `SemanticBoundVariableNode` | Parameter or let binding reference with `name` and `isLetBinding` flag                  |
| `SemanticCallNode`          | Function call with `callee` (`SemanticNode`) and `arguments`                            |
| `SemanticLetBindingNode`    | Let binding with `name` (String) and `value` (SemanticNode)                             |
| `SemanticLetNode`           | Let expression with `bindings` (List<SemanticLetBindingNode>) and `body` (SemanticNode) |

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

The actual runtime `FunctionTerm` instances for the standard library are obtained during lowering via `StandardLibrary.get()`, not stored in `IntermediateRepresentation`. This keeps the semantic output free of runtime types.

Factory constructors:

- `IntermediateRepresentation.empty()` - creates an empty representation with no custom functions, pre-populated standard library signatures, and no warnings.

Helper methods:

- `containsFunction(name)` - checks if a function exists (custom or stdlib).
- `allFunctionNames` - returns a `Set<String>` of all function names (custom + stdlib).
- `getCustomFunction(name)` - returns a `SemanticFunction?` by name.
- `getStandardLibrarySignature(name)` - returns a `FunctionSignature?` by name.

## Lowerer

**File**: `lib/compiler/lowering/lowerer.dart`

The lowerer converts semantic IR to runtime terms for evaluation:

```dart
class Lowerer {
  final Map<String, FunctionTerm> functions;

  const Lowerer(this.functions);

  CustomFunctionTerm lowerFunction(SemanticFunction function);
  Term lowerTerm(SemanticNode semanticNode);
}
```

The `functions` map is passed at construction and used to resolve `SemanticIdentifierNode` references into `FunctionReferenceTerm` instances.

- `lowerFunction()` converts user-defined functions to `CustomFunctionTerm`.
- `lowerTerm()` converts semantic expressions to runtime `Term` instances.

This pass strips source locations and produces the minimal runtime representation needed for the substitution-based evaluation model. The lowerer operates only on semantic types (`SemanticNode`, `SemanticFunction`) and produces runtime types (`Term`, `CustomFunctionTerm`), maintaining clean phase separation.

| Semantic Node                                     | Runtime Term            |
| ------------------------------------------------- | ----------------------- |
| `SemanticBooleanNode`                             | `BooleanTerm`           |
| `SemanticNumberNode`                              | `NumberTerm`            |
| `SemanticStringNode`                              | `StringTerm`            |
| `SemanticListNode`                                | `ListTerm`              |
| `SemanticMapNode`                                 | `MapTerm`               |
| `SemanticIdentifierNode`                          | `FunctionReferenceTerm` |
| `SemanticBoundVariableNode` (isLetBinding: false) | `BoundVariableTerm`     |
| `SemanticBoundVariableNode` (isLetBinding: true)  | `LetBoundVariableTerm`  |
| `SemanticCallNode`                                | `CallTerm`              |
| `SemanticLetNode`                                 | `LetTerm`               |

## RuntimeInputBuilder

**File**: `lib/compiler/lowering/runtime_input_builder.dart`

Bridges the semantic IR and the runtime by building a `RuntimeInput` from an `IntermediateRepresentation`:

```dart
class RuntimeInputBuilder {
  const RuntimeInputBuilder();

  RuntimeInput build(IntermediateRepresentation intermediateRepresentation);
}
```

`build()` fetches the standard library `FunctionTerm` instances via `StandardLibrary.get()`, creates a `Lowerer` with the resulting function map, then lowers each custom `SemanticFunction` into the same map. The returned `RuntimeInput` contains all functions (standard library and custom) ready for evaluation.

## RuntimeFacade

**File**: `lib/compiler/lowering/runtime_facade.dart`

The entry point for evaluating expressions against a compiled program. Ties together semantic analysis, lowering, and runtime evaluation:

```dart
class RuntimeFacade {
  final IntermediateRepresentation intermediateRepresentation;

  factory RuntimeFacade(
    IntermediateRepresentation intermediateRepresentation,
    ExpressionParser parseExpression,
  );

  bool get hasMain;
  List<String> get userDefinedFunctionSignatures;
  void reset();
  int loadFromIntermediateRepresentation(IntermediateRepresentation representation);
  void deleteFunction(String name);
  void renameFunction(String oldName, String newName);
  Expression mainExpression(List<String> arguments);
  String executeMain([List<String>? arguments]);
  String evaluate(Expression expression);
  Term evaluateToTerm(Expression expression);
  dynamic format(dynamic value);
  void defineFunction(FunctionDefinition definition);
}
```

`ExpressionParser` is a typedef: `Expression Function(String input)`.

Key behavior:

- `hasMain` - checks if a `main` function exists in the intermediate representation.
- `userDefinedFunctionSignatures` - returns a sorted list of user-defined function signatures as strings.
- `reset()` - clears all user-defined functions from the runtime, removing their signatures and terms.
- `loadFromIntermediateRepresentation(representation)` - clears existing user-defined functions, then loads all custom functions from the provided `IntermediateRepresentation`. Returns the number of functions loaded.
- `deleteFunction(name)` - removes a user-defined function by name. Throws `FunctionNotFoundError` if the function does not exist. Throws `CannotDeleteStandardLibraryError` if attempting to delete a stdlib function.
- `renameFunction(oldName, newName)` - renames a user-defined function. Throws `FunctionNotFoundError` if `oldName` does not exist. Throws `CannotRenameStandardLibraryError` if `oldName` is a stdlib function. Throws `FunctionAlreadyExistsError` if `newName` is already in use. Note: does not update references in other user-defined functions.
- `mainExpression(arguments)` - builds a call expression for `main`, escaping string arguments. If `main` has no parameters, arguments are ignored.
- `executeMain([arguments])` - evaluates `main` and returns the formatted result as a string.
- `evaluate(expression)` - runs an expression through the full pipeline (semantic check, lowering, reduction, formatting) and returns the result as a string.
- `evaluateToTerm(expression)` - same as `evaluate` but returns the raw runtime `Term` instead of a formatted string. Resets `FunctionTerm` recursion depth before each evaluation.
- `format(value)` - delegates to `Runtime.format()`.
- `defineFunction(definition)` - allows REPL users to define or redefine functions at runtime. User-defined functions can be redefined, but standard library functions cannot. Throws `CannotRedefineStandardLibraryError` if attempting to overwrite a stdlib function. Also throws `DuplicatedParameterError` for duplicate parameters. If semantic analysis of the function body fails, the previous signature is restored.

## Phase Boundaries

The semantic phase maintains strict separation from the runtime phase:

- **No runtime imports** - `semantic_node.dart`, `semantic_analyzer.dart`, and `intermediate_representation.dart` do not import from `runtime/`.
- **FunctionSignature abstraction** - instead of storing `FunctionTerm` references, the semantic phase uses `FunctionSignature` for call validation.
- **Lowering is one-way** - `Lowerer` converts semantic IR to runtime terms, but never the reverse.
- **RuntimeFacade bridges the phases** - `RuntimeFacade` is the only component that orchestrates both semantic analysis and runtime evaluation, coordinating `SemanticAnalyzer`, `Lowerer`, and `Runtime`.

This separation ensures that:

1. Semantic analysis can be performed without instantiating runtime terms.
2. The runtime layer remains focused purely on evaluation.
3. Future optimizations can operate on semantic IR without affecting runtime behavior.

## Design Rationale

Separating semantic IR from runtime terms enables:

- **Source locations** - error messages and diagnostics can point to exact source positions.
- **Resolved references** - function identifiers are resolved at compile time, enabling static arity checking.
- **Extensibility** - future passes (optimization, type inference) can operate on the semantic IR without affecting runtime evaluation.
- **Clean separation** - the runtime layer focuses purely on evaluation, not validation.
