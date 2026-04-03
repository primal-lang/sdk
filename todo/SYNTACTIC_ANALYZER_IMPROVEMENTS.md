## Issue #7: Lambda Allocation in `match()`

### Location

`lib/compiler/syntactic/expression_parser.dart`, lines 306-315 and all call sites

### Current Behavior

The `match()` method takes a list of predicate functions:

```dart
bool match(List<bool Function(Token)> predicates) {
  for (final predicate in predicates) {
    if (check(predicate)) {
      advance();
      return true;
    }
  }
  return false;
}
```

Every call to `match()` creates new lambda (closure) objects:

```dart
// Line 38 - Creates 2 new closures
while (match([(t) => t is NotEqualToken, (t) => t is EqualToken])) {

// Lines 89-94 - Creates 4 new closures
while (match([
  (t) => t is GreaterThanToken,
  (t) => t is GreaterEqualThanToken,
  (t) => t is LessThanToken,
  (t) => t is LessEqualThanToken,
])) {

// Line 111 - Creates 2 new closures
while (match([(t) => t is MinusToken, (t) => t is PlusToken])) {
```

### Why This Is Problematic

#### 1. Heap Allocation Overhead

In Dart, closures are objects allocated on the heap. Each `(t) => t is SomeToken` creates a new `Closure` instance with:

- A function pointer
- A captured environment (empty in this case, but still allocated)

#### 2. GC Pressure

Parsing happens frequently. For a program with 100 expressions:

- `equality()` creates 2 closures per call × 100 = 200 closures
- `comparison()` creates 4 closures per call × 100 = 400 closures
- `term()` creates 2 closures per call × 100 = 200 closures
- `factor()` creates 3 closures per call × 100 = 300 closures
- And so on...

These short-lived objects create garbage collection pressure.

#### 3. Redundant Work

The predicates are always the same. `(t) => t is PlusToken` at line 111 is functionally identical every time `term()` runs. Creating it fresh each time is wasteful.

### Proposed Solution

#### Option A: Static Predicate Functions (Recommended)

Define predicates as static top-level or class-level functions:

```dart
class ExpressionParser {
  // Static predicates - allocated once
  static bool _isNotEqual(Token t) => t is NotEqualToken;
  static bool _isEqual(Token t) => t is EqualToken;
  static bool _isPipe(Token t) => t is PipeToken;
  static bool _isAmpersand(Token t) => t is AmpersandToken;
  static bool _isGreaterThan(Token t) => t is GreaterThanToken;
  static bool _isGreaterEqualThan(Token t) => t is GreaterEqualThanToken;
  static bool _isLessThan(Token t) => t is LessThanToken;
  static bool _isLessEqualThan(Token t) => t is LessEqualThanToken;
  static bool _isMinus(Token t) => t is MinusToken;
  static bool _isPlus(Token t) => t is PlusToken;
  static bool _isForwardSlash(Token t) => t is ForwardSlashToken;
  static bool _isAsterisk(Token t) => t is AsteriskToken;
  static bool _isPercent(Token t) => t is PercentToken;
  static bool _isAt(Token t) => t is AtToken;
  static bool _isBang(Token t) => t is BangToken;
  static bool _isOpenParen(Token t) => t is OpenParenthesisToken;
  static bool _isCloseParen(Token t) => t is CloseParenthesisToken;
  static bool _isOpenBracket(Token t) => t is OpenBracketToken;
  static bool _isCloseBracket(Token t) => t is CloseBracketToken;
  static bool _isOpenBraces(Token t) => t is OpenBracesToken;
  static bool _isCloseBraces(Token t) => t is CloseBracesToken;
  static bool _isComma(Token t) => t is CommaToken;
  static bool _isColon(Token t) => t is ColonToken;
  static bool _isIf(Token t) => t is IfToken;
  static bool _isElse(Token t) => t is ElseToken;
  static bool _isBoolean(Token t) => t is BooleanToken;
  static bool _isNumber(Token t) => t is NumberToken;
  static bool _isString(Token t) => t is StringToken;
  static bool _isIdentifier(Token t) => t is IdentifierToken;

  // Static predicate lists - allocated once
  static final List<bool Function(Token)> _equalityPredicates = [
    _isNotEqual,
    _isEqual,
  ];
  static final List<bool Function(Token)> _comparisonPredicates = [
    _isGreaterThan,
    _isGreaterEqualThan,
    _isLessThan,
    _isLessEqualThan,
  ];
  static final List<bool Function(Token)> _termPredicates = [
    _isMinus,
    _isPlus,
  ];
  static final List<bool Function(Token)> _factorPredicates = [
    _isForwardSlash,
    _isAsterisk,
    _isPercent,
  ];
  static final List<bool Function(Token)> _unaryPredicates = [
    _isBang,
    _isMinus,
  ];

  // Usage:
  Expression equality() {
    Expression expression = logicOr();

    while (match(_equalityPredicates)) {  // No allocation!
      final Token operator = previous;
      final Expression right = logicOr();
      expression = CallExpression.fromBinaryOperation(
        operator: operator,
        left: expression,
        right: right,
      );
    }

    return expression;
  }

  // ... similar changes for other methods
}
```

#### Option B: Type-Based Matching

Change `match()` to work with `Type` objects instead of predicates:

```dart
bool matchTypes(List<Type> types) {
  if (!iterator.isAtEnd && types.contains(peek.runtimeType)) {
    advance();
    return true;
  }
  return false;
}

// Usage:
while (matchTypes([NotEqualToken, EqualToken])) {
```

**Pros:** Very clean call sites
**Cons:** `runtimeType` and `contains` have some overhead; type literals are still allocated (though often cached by the runtime)

#### Option C: Single Predicate with OR

For small predicate lists, combine into a single predicate:

```dart
static bool _isEqualityOp(Token t) => t is NotEqualToken || t is EqualToken;

while (matchSingle(_isEqualityOp)) {
```

This requires changing `match()` to accept a single predicate, but avoids list allocation entirely.

### Recommended Approach

**Option A** (static predicates) is the most straightforward improvement:

- Zero allocation per parse
- No API changes needed
- Predicates are self-documenting
- Easy to maintain

### Impact on Tests

This is a pure refactoring with no behavioral changes. **Existing tests should pass unchanged.**

Optionally, add a performance benchmark test:

```dart
test('Expression parsing performance', () {
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < 10000; i++) {
    getExpression('a + b * c - d / e % f');
  }

  stopwatch.stop();
  print('10000 parses took ${stopwatch.elapsedMilliseconds}ms');

  // Optional assertion (may need tuning based on machine):
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
});
```

### Files to Modify

| File                                            | Change                                        |
| ----------------------------------------------- | --------------------------------------------- |
| `lib/compiler/syntactic/expression_parser.dart` | Add static predicates, update `match()` calls |
| `test/compiler/expression_parser_test.dart`     | (Optional) Add performance test               |

Update any document in @docs/ if necessary.

Plan for adding/updating any test if necessary to cover all the new changes.

---

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
