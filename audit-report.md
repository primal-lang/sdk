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
