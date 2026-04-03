# Semantic Analysis

**File**: `lib/compiler/semantic/semantic_analyzer.dart`

The semantic analyzer validates the parsed function definitions and produces `IntermediateCode`. It performs the following checks:

1. **Function extraction** - converts each `FunctionDefinition` into a `CustomFunctionNode` with typed parameters.
2. **Duplicate function detection** - reports an error if two functions share the same name.
3. **Duplicate parameter detection** - reports an error if a function has repeated parameter names.
4. **Identifier resolution** - for every `FreeVariableNode` in a function body:
   - If it matches a parameter name, it is converted to a `BoundedVariableNode`.
   - If it matches a known function name (custom or standard library), it remains a `FreeVariableNode` (resolved at runtime via scope).
   - Otherwise, an `UndefinedIdentifierError` is raised.
5. **Call validation** - for every `CallNode`, the argument count is checked against the callee's parameter count.
6. **Literal validation** - rejects attempts to call non-callable literals (numbers, booleans, strings, lists, maps) or index non-indexable literals (numbers, booleans).
7. **Unused parameter warnings** - parameters that are never referenced in the function body produce a warning.

Nested structures (`CallNode`, `ListNode`, `MapNode`) are checked recursively.

## Intermediate Code

The output of semantic analysis is `IntermediateCode` (`lib/compiler/semantic/intermediate_code.dart`):

- `functions`: `Map<String, FunctionNode>` - all functions (user-defined + standard library), keyed by name.
- `warnings`: `List<GenericWarning>` - any warnings produced during analysis.
