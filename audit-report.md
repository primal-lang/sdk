## Warnings

### 1. FunctionNode static recursion depth counter is not thread-safe

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/runtime/node.dart`
**Lines**: 311-349

- **Issue**: The `_currentDepth` static variable used for recursion depth tracking is shared across all instances. While the documentation states Primal is single-threaded, if multiple `RuntimeFacade` instances are used concurrently (e.g., in a web server context), the counter could produce incorrect results or allow one execution to exhaust depth for another.

- **Impact**: In concurrent usage scenarios, recursion limits may be incorrectly enforced, potentially allowing deeper recursion than intended or incorrectly blocking shallow recursion.

- **Fix**: Document the single-threaded assumption explicitly, or consider passing depth through the evaluation context rather than using static state.

**Follow-up**:

- **Tests**: Add test verifying `resetDepth()` properly resets counter between evaluations
  - Success case: Sequential evaluations should each start at depth 0
- **Docs**: Document single-threaded runtime requirement in `docs/primal.md`

---

### 2. num.pow can produce NaN or infinity without validation

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/arithmetic/num_pow.dart`
**Lines**: 32-38

- **Issue**: The `pow` function does not validate inputs for cases that produce special values:
  - `pow(-1, 0.5)` returns `NaN` (square root of negative number)
  - `pow(0, -1)` returns `infinity`
  - `pow(1000, 1000)` returns `infinity` (overflow)

- **Impact**: Users receive confusing `NaN` or `infinity` results instead of descriptive errors, inconsistent with other numeric functions like `num.sqrt` and `num.log` which validate inputs.

- **Fix**:

```dart
@override
Node evaluate() {
  final Node a = arguments[0].evaluate();
  final Node b = arguments[1].evaluate();

  if ((a is NumberNode) && (b is NumberNode)) {
    // Check for negative base with fractional exponent
    if (a.value < 0 && b.value != b.value.truncate()) {
      throw InvalidNumericOperationError(
        function: name,
        reason: 'cannot raise negative number to fractional power',
      );
    }
    final num result = pow(a.value, b.value);
    if (result.isNaN || result.isInfinite) {
      throw InvalidNumericOperationError(
        function: name,
        reason: 'result is not a finite number',
      );
    }
    return NumberNode(result);
  } else {
    // ... existing error handling
  }
}
```

**Follow-up**:

- **Tests**: Add tests for edge cases
  - Success case: `num.pow(2, 10)` returns `1024`
  - Failure case: `num.pow(-1, 0.5)` should throw error
  - Failure case: `num.pow(0, -1)` should throw error
- **Docs**: Update `docs/reference/arithmetic.md` to document these constraints

---

### 3. RuntimeFacade.mainExpression does not escape quotes in arguments

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/lowering/runtime_facade.dart`
**Lines**: 50-59

- **Issue**: When constructing the main expression with arguments, the code uses string interpolation without escaping special characters:

  ```dart
  'main(${arguments.map((e) => '"$e"').join(', ')})'
  ```

  If an argument contains a double quote (`"`) or backslash (`\`), the generated expression will be malformed and cause a parse error.

- **Impact**: Command-line arguments containing quotes or backslashes cause cryptic parse errors instead of being passed correctly to the main function.

- **Fix**:

```dart
Expression mainExpression(List<String> arguments) {
  final FunctionNode? main = _runtimeInput.getFunction('main');

  if ((main != null) && main.parameters.isNotEmpty) {
    final String escapedArgs = arguments
        .map((e) => '"${e.replaceAll('\\', '\\\\').replaceAll('"', '\\"')}"')
        .join(', ');
    return _parseExpression('main($escapedArgs)');
  } else {
    return _parseExpression('main()');
  }
}
```

**Follow-up**:

- **Tests**: Add test for arguments with special characters
  - Success case: `primal program.pri 'hello "world"'` should work
  - Success case: `primal program.pri 'path\to\file'` should work
- **Docs**: No doc changes needed

---

## Info

### 1. Missing const constructors on several Type subclasses

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/models/type.dart`
**Lines**: 1-108

- **Issue**: The base `Type` class and all its subclasses are designed to be immutable singleton types but the base `Type` class lacks the `@immutable` annotation. While all subclasses properly use `const` constructors, adding the annotation would enable static analysis to catch any future violations.

- **Impact**: Minor - documentation and static analysis benefit only.

- **Fix**: Add `@immutable` annotation:

```dart
import 'package:meta/meta.dart';

@immutable
class Type {
  const Type();
}
```

**Follow-up**:

- **Tests**: No test changes needed
- **Docs**: No doc changes needed

---

### 2. Parameter class lacks equality operator override

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/models/parameter.dart`
**Lines**: 1-53

- **Issue**: The `Parameter` class does not override `==` or `hashCode`. This means two `Parameter` instances with the same name and type are not considered equal, which could cause issues if parameters are ever used as map keys or in sets.

- **Impact**: Low - currently parameters are compared by name only in `FunctionSignature._parametersEqual`, so this doesn't cause issues in practice.

- **Fix**:

```dart
@override
bool operator ==(Object other) =>
    identical(this, other) ||
    other is Parameter && name == other.name && type.runtimeType == other.type.runtimeType;

@override
int get hashCode => Object.hash(name, type.runtimeType);
```

**Follow-up**:

- **Tests**: Add unit tests for Parameter equality
- **Docs**: No doc changes needed

---

### 3. json.decode silently filters null values from arrays and maps

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/json/json_decode.dart`
**Lines**: 70-84

- **Issue**: When decoding JSON, null values in arrays are silently removed (`element.where((e) => e != null)`) and null values in maps are skipped (`if (value != null)`). This is intentional since Primal doesn't support null, but it means the decoded data structure may have fewer elements than the original JSON.

- **Impact**: Users may be surprised that `json.decode("[1, null, 2]")` returns `[1, 2]` instead of throwing an error. The current behavior is reasonable but could be better documented.

- **Fix**: No code change needed, but add documentation.

**Follow-up**:

- **Tests**: Tests already exist covering this behavior
- **Docs**: Update `docs/reference/json.md` to document that null values are stripped during decoding

---

### 4. list.zip behavior with mismatched lengths may be unexpected

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_zip.dart`
**Lines**: 32-56

- **Issue**: When the two input lists have different lengths, `list.zip` applies the function only where both elements exist, and includes remaining elements unmodified. This is a valid design choice but differs from typical zip implementations that either truncate to the shorter length or require equal lengths.

- **Impact**: Users familiar with zip from other languages may expect different behavior. The function works correctly but could benefit from clearer documentation.

- **Fix**: No code change needed, but add documentation.

**Follow-up**:

- **Tests**: Existing tests should cover this behavior
- **Docs**: Update `docs/reference/list.md` to clarify the behavior with mismatched lengths

---

## Notes

The codebase is well-structured with consistent patterns:

- Empty collection checks are properly implemented throughout (`list.first`, `list.last`, `stack.peek`, etc.)
- Division by zero is consistently checked in division and modulo operations
- Index bounds checking is thorough in list, string, and map access functions
- Error handling follows a consistent pattern with descriptive error types
- The lexer state machine is complete and handles all edge cases including escape sequences

Static analysis (`dart analyze`) reports no issues, confirming the codebase follows Dart best practices.
