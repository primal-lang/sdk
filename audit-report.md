## Warnings

### `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_filled.dart`

**Line 36**: Missing validation for negative count

- **Issue**: `List.filled(count, element)` throws `ArgumentError` if count is negative. The function does not validate the input.
- **Impact**: Dart internal error surfaces instead of a user-friendly Primal error.
- **Fix**: Add validation for `a.value.toInt() < 0`.

add/update the tests to cover this case.

### `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/vector/vector_normalize.dart`

**Line 35-42**: Division by zero when normalizing a zero vector

- **Issue**: When the vector magnitude is zero (zero vector), the function divides each component by zero, producing `NaN` or `Infinity` values.
- **Impact**: Silent incorrect results instead of a meaningful error.
- **Fix**: Check if `magnitude.value == 0` and throw an appropriate error.

add/update the tests to cover this case.

### `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/timestamp/time_from_iso.dart`

**Line 34**: Uncaught `FormatException` from `DateTime.parse()`

- **Issue**: `DateTime.parse()` throws `FormatException` for invalid ISO strings, but this is not caught and converted to a Primal `ParseError`.
- **Impact**: Internal Dart exception surfaces to the user instead of a user-friendly error.
- **Fix**:

```dart
if (a is StringNode) {
  try {
    return TimestampNode(DateTime.parse(a.value));
  } on FormatException {
    throw ParseError(function: name, input: a.value, targetType: 'timestamp');
  }
}
```

add/update the tests to cover this case.

### `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/string/str_match.dart`

**Line 36**: Uncaught `FormatException` from invalid regex patterns

- **Issue**: `RegExp(b.value)` throws `FormatException` if the pattern is invalid, but this is not caught.
- **Impact**: Internal Dart exception surfaces to the user.
- **Fix**: Wrap in try-catch and throw a meaningful `ParseError` or similar.

add/update the tests to cover this case.

### `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_sort.dart`

**Line 42**: Unsafe cast of comparator result to `int`

- **Issue**: The comparator function's return value is cast to `int` with `value.value as int`, but `NumberNode.value` is `num`, not `int`. If the user's comparator returns a decimal (e.g., `0.5`), this cast will fail at runtime.
- **Impact**: Runtime `TypeError` for valid-looking Primal code.
- **Fix**: Use `.toInt()` instead of `as int`:

```dart
return value.value.toInt();
```

add/update the tests to cover this case.

### `/home/max/Repositories/personal/primal-sdk/lib/utils/stack.dart`

**Line 8**: Stack `pop()` method mutates internal list

- **Issue**: `_list.removeLast()` mutates `_list`, but the Stack class appears designed for immutability (other methods like `push` return a new Stack). This breaks the immutability contract.
- **Impact**: If the same Stack reference is used after `pop()`, the original stack is modified, violating Primal's immutability guarantees.
- **Note**: This class may not be used by the runtime (StackNode uses `List<Node>` directly), but the implementation is inconsistent.

add/update the tests to cover this case.

### `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_sublist.dart`

**Line 43-48**: Missing validation for `start > length`

- **Issue**: The validation only checks `end < start` and `end > length`, but not `start > length`. Dart's `sublist()` will throw `RangeError` for invalid start.
- **Impact**: Internal Dart error surfaces instead of a user-friendly Primal error.
- **Fix**: Add validation: `if (start > a.value.length)`.

add/update the tests to cover this case.

### `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/arithmetic/num_log.dart`

**Line 35**: No validation for non-positive input to logarithm

- **Issue**: `log()` of zero returns `-Infinity`, and `log()` of negative numbers returns `NaN`. These are mathematically undefined but silently produce special values.
- **Impact**: Silent incorrect results that may propagate through calculations.
- **Fix**: Validate input and throw `InvalidNumericOperationError` for non-positive values.

add/update the tests to cover this case.

---

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
