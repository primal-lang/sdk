## Fix 4: Make `MapEntryExpression` extend `Localized`

### Problem

`MapEntryExpression` has a `location` field but doesn't extend any base class, unlike other expression-related types. This is inconsistent with the codebase pattern where locatable syntax elements extend `Localized`.

Map entries are not standalone expressions in the grammar (they only appear inside `{}`), so they should not extend `Expression`. However, they should extend `Localized` for consistency.

### Location

- **File**: `lib/compiler/syntactic/expression.dart`
- **Lines**: 69-79

### Change

```dart
// Before
class MapEntryExpression {
  final Location location;
  final Expression key;
  final Expression value;

  const MapEntryExpression({
    required this.location,
    required this.key,
    required this.value,
  });
}

// After
class MapEntryExpression extends Localized {
  final Expression key;
  final Expression value;

  const MapEntryExpression({
    required super.location,
    required this.key,
    required this.value,
  });
}
```

### Import Changes

The file already imports `location.dart` (line 2), so no new imports are needed.

### Tests

- **New test**: Add to `syntactic_analyzer_test.dart` to verify `MapEntryExpression` extends `Localized`:

```dart
test('MapEntryExpression extends Localized', () {
  final List<FunctionDefinition> functions = getFunctions(
    'map = {"key": "value"}',
  );
  final MapExpression mapExpr = functions[0].expression as MapExpression;
  final MapEntryExpression entry = mapExpr.value[0];

  expect(entry, isA<Localized>());
});
```

- **Existing test**: The test `test('MapEntryExpression has correct location', ...)` at line 235 already verifies that `MapEntryExpression.location` works correctly. This test will continue to pass after the change.

### Documentation

- **Update**: `docs/compiler/syntactic.md`
- **Section**: "Expression Tree" (lines 73-84)

Update the bullet point for `MapExpression` to clarify that `MapEntryExpression` extends `Localized`:

```markdown
- `MapExpression` (contains `List<MapEntryExpression>`)
  - `MapEntryExpression` extends `Localized` (not `Expression`, as map entries only appear within map literals)
```

### Risk

Low - this is a minor structural change. The `Localized` base class provides `location`, `==`, and `hashCode`, which are compatible with the current implementation. The only behavioral change is that `MapEntryExpression` instances will now compare equal based on location (inherited from `Localized`), which is more correct than the default reference equality.
