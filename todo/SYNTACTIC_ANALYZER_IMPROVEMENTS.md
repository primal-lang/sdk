## Issue #8: `MapEntryExpression` Lacks Location Info

### Location

`lib/compiler/syntactic/expression.dart`, lines 69-74

### Current Behavior

```dart
class MapEntryExpression {
  final Expression key;
  final Expression value;

  const MapEntryExpression({required this.key, required this.value});
}
```

Compare to other expression types:

```dart
abstract class Expression extends Localized {
  const Expression({required super.location});  // Has location!
  Node toNode();
}

class BooleanExpression extends LiteralExpression<bool> { /* has location */ }
class NumberExpression extends LiteralExpression<num> { /* has location */ }
class ListExpression extends LiteralExpression<List<Expression>> { /* has location */ }
class MapExpression extends LiteralExpression<List<MapEntryExpression>> { /* has location */ }
```

### Why This Is Problematic

#### 1. Poor Error Localization

Consider this code:

```primal
config = {"name": 123, "debug": "yes"}
```

If semantic analysis detects that `"name": 123` is invalid (e.g., expected a string value), the error can only point to the `MapExpression`'s location (the opening `{`), not to the specific entry.

**Current error:**

```
Error at line 1, column 10: Type mismatch in map
```

**Desired error:**

```
Error at line 1, column 11: Expected string value for key "name", got number
                    ^^^^^
```

Without location info on `MapEntryExpression`, we can't produce the better error.

#### 2. Inconsistency in Data Model

Every other syntactic construct has location information:

- `Expression` has `location`
- `Token` has `location`
- `FunctionDefinition` has an expression with a location
- Even `ListExpression` elements are `Expression`s with locations

But `MapEntryExpression` is a special case without location. This inconsistency complicates code that needs to traverse the AST and report positions.

#### 3. Limited Debugging/Tooling Support

IDE features like "go to definition" or "show type on hover" need source locations. Without location on map entries, these features can't work for map key-value pairs.

### Proposed Solution

Add `location` to `MapEntryExpression`:

```dart
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
```

Update the parser to provide the location (`lib/compiler/syntactic/expression_parser.dart`, lines 286-304):

```dart
Expression map(Token token) {
  final List<MapEntryExpression> pairs = [];

  if (!check((t) => t is CloseBracesToken)) {
    do {
      final Expression key = expression();
      consume((t) => t is ColonToken, ':');
      final Expression value = expression();
      pairs.add(MapEntryExpression(
        location: key.location,  // Use the key's location as the entry's location
        key: key,
        value: value,
      ));
    } while (match([(t) => t is CommaToken]));
  }

  consume((t) => t is CloseBracesToken, '}');

  return MapExpression(
    location: token.location,
    value: pairs,
  );
}
```

### Alternative: Use Key's Location Directly

If adding a field to `MapEntryExpression` is considered too invasive, error messages could use `entry.key.location` directly. However, this is a workaround rather than a proper fix:

- It couples error reporting to knowledge about `MapEntryExpression`'s internal structure
- It doesn't help if the error is about the entry as a whole (not specifically the key)

### Impact on Tests

**Tests that construct `MapEntryExpression` will need updating:**

From `test/compiler/syntactic_analyzer_test.dart`:

```dart
// Before:
MapEntryExpression(
  key: NumberExpression(numberToken(1, 1, 8)),
  value: StringExpression(stringToken('one', 1, 11)),
),

// After:
MapEntryExpression(
  location: const Location(row: 1, column: 8),
  key: NumberExpression(numberToken(1, 1, 8)),
  value: StringExpression(stringToken('one', 1, 11)),
),
```

**All map-related tests need this update:**

- `test('Literal map definition', ...)`
- `test('Indexing map', ...)`
- Any test in `expression_parser_test.dart` that creates maps

**New tests to add:**

```dart
test('MapEntryExpression has correct location', () {
  final List<FunctionDefinition> functions = getFunctions(
    'map = {"key": "value"}',
  );
  final MapExpression mapExpr = functions[0].expression as MapExpression;
  final MapEntryExpression entry = mapExpr.value[0];

  // Entry location should be the key's location
  expect(entry.location, equals(const Location(row: 1, column: 8)));
});
```

### Files to Modify

| File                                            | Change                                                 |
| ----------------------------------------------- | ------------------------------------------------------ |
| `lib/compiler/syntactic/expression.dart`        | Add `location` field to `MapEntryExpression`           |
| `lib/compiler/syntactic/expression_parser.dart` | Pass `key.location` when creating `MapEntryExpression` |
| `test/compiler/syntactic_analyzer_test.dart`    | Update all `MapEntryExpression` constructions          |
| `test/compiler/expression_parser_test.dart`     | Update map-related tests if needed                     |

Update any document in @docs/ if necessary.

Plan for adding/updating any test if necessary to cover all the new changes.
