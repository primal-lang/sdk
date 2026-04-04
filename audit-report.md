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
