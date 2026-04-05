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
