### 9. Missing `const` constructor on `Parameter` class

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/models/parameter.dart`
**Line**: 3-11

- **Issue**: The `Parameter` class has only `final` fields but uses factory constructors that prevent const usage. While not a bug, const constructors would enable compile-time constant parameters.
- **Impact**: Minor: slightly less efficient memory usage for parameter instances.
- **Suggestion**: Consider using `const Parameter._({...})` and adjusting factory constructors, or leave as-is since the performance impact is negligible.

add/update the tests to cover this case.
update @docs if needed

### 10. Potential unbounded recursion in evaluation

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/runtime/node.dart`
**Line**: 268-271

- **Issue**: The `CallNode.evaluate()` method and recursive function calls in Primal have no depth limit. Deeply recursive or infinitely recursive user code will cause a stack overflow.
- **Impact**: Malicious or buggy Primal code like `f(x) = f(x)` will crash the interpreter with a stack overflow. This is expected behavior for a simple interpreter but could be improved with a recursion depth limit.
- **Suggestion**: Consider adding an optional depth counter for evaluation, especially if the interpreter is exposed to untrusted input.

add/update the tests to cover this case.
update @docs if needed

### 11. `LiteralNode.from` doesn't handle all node types

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/runtime/node.dart`
**Line**: 37-51

- **Issue**: The `LiteralNode.from` factory only handles `bool`, `num`, `String`, `List<Node>`, and `Map<Node, Node>`. It doesn't handle `DateTime`, `File`, `Directory`, or `Set<Node>`.
- **Impact**: If `LiteralNode.from` is called with one of these types (e.g., via JSON decoding of unexpected data), it will throw an unhelpful `InvalidLiteralValueError`.
- **Suggestion**: Either extend the factory to handle all types or document that it only handles JSON-compatible types.

add/update the tests to cover this case.
update @docs if needed

### 12. Duplicate class names across files

**File**: Multiple files in `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/`

- **Issue**: Many library function files define a private `NodeWithArguments` class. While this works due to Dart's file-level privacy, it could cause confusion during debugging or refactoring.
- **Impact**: No functional impact, but reduces code clarity. If someone tries to extract shared functionality, they'll encounter naming conflicts.
- **Suggestion**: Consider using unique class names or moving the pattern to a shared base class.

add/update the tests to cover this case.
update @docs if needed

### 13. `error.throw` evaluates first argument before throwing

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/error/throw.dart`
**Line**: 32-35

- **Issue**: The `error.throw` function evaluates argument `a` (the error code) before throwing. The string representation of `b` uses `.toString()` on the unevaluated node, which may produce unexpected output if `b` is a complex expression.
- **Impact**: The error message might show the AST representation of `b` rather than its evaluated string value.
- **Suggestion**: Evaluate `b` and ensure it's a `StringNode` before using its value, or clarify the intended behavior in documentation.

add/update the tests to cover this case.
update @docs if needed
