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
