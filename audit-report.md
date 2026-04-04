## Info

### `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/operators/operator_div.dart` and `num_div.dart`

**Lines 35-36**: Division by zero returns `Infinity` instead of error

- **Issue**: Unlike `num.mod` and `%` which check for division by zero, the division operators `/` and `num.div` do not. Dividing by zero returns `Infinity` or `-Infinity`.
- **Impact**: This is consistent with Dart behavior and may be intentional for IEEE 754 floating-point semantics, but it differs from the explicit error thrown by modulo operations.
- **Suggestion**: Consider adding a consistency comment or explicit documentation.

add/update the tests to cover this case.

### `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/control/try.dart`

**Line 36-38**: Catch-all exception handler includes all errors

- **Issue**: `catch (e)` catches all exceptions including `Error` types (like `OutOfMemoryError`). This is very broad.
- **Impact**: Potentially masks serious errors that shouldn't be caught.
- **Suggestion**: Consider catching only `Exception` or specific Primal error types: `on RuntimeError catch (e)`.

### `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/json/json_decode.dart`

add/update the tests to cover this case.

**Line 64**: `getMap` uses `LiteralNode.from()` which throws for non-primitive keys

- **Issue**: If a JSON map has a key that's not a primitive (bool, num, String), `LiteralNode.from()` will throw `InvalidLiteralValueError`. However, JSON keys are always strings, so this is not reachable in practice.
- **Impact**: None in practice, but defensive programming would check this.

### `/home/max/Repositories/personal/primal-sdk/lib/utils/list_iterator.dart`

**Line 37**: `last` getter has no empty-list guard

- **Issue**: Calling `last` on an empty list throws `StateError` from Dart. No check is performed.
- **Impact**: If caller doesn't check, internal Dart error surfaces.
- **Suggestion**: This may be intentional (caller is expected to check), but could benefit from a guard or documentation.

add/update the tests to cover this case.

### `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_filter.dart`

**Lines 39-43**: Silent failure when predicate returns non-boolean

- **Issue**: If the predicate function returns a non-boolean, the element is silently excluded (because `value is BooleanNode && value.value` is false for non-booleans).
- **Impact**: User code with a buggy predicate silently produces unexpected results instead of an error.
- **Suggestion**: Consider throwing an error if the predicate doesn't return a boolean:

```dart
if (value is! BooleanNode) {
  throw InvalidArgumentTypesError(
    function: name,
    expected: [const BooleanType()],
    actual: [value.type],
  );
}
```

add/update the tests to cover this case.
