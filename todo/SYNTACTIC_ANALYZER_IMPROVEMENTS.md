# Syntactic Analyzer: Detailed Improvement Plan

This document details specific issues identified in the syntactic analyzer and provides a concrete plan for addressing each one.

---

## Table of Contents

1. [Issue #2: Type Checks Mix Syntactic and Semantic Concerns](#issue-2-type-checks-mix-syntactic-and-semantic-concerns)
2. [Issue #3: `ResultState` Doesn't Implement `process()`](#issue-3-resultstate-doesnt-implement-process)
3. [Issue #4: `previous` Assumes Non-Null](#issue-4-previous-assumes-non-null)
4. [Issue #7: Lambda Allocation in `match()`](#issue-7-lambda-allocation-in-match)
5. [Issue #8: `MapEntryExpression` Lacks Location Info](#issue-8-mapentryexpression-lacks-location-info)

---

## Issue #2: Type Checks Mix Syntactic and Semantic Concerns

### Location

`lib/compiler/syntactic/expression_parser.dart`, lines 187-231 (the `call()` method)

### Current Behavior

The `call()` method explicitly checks the runtime type of parsed expressions to decide whether they can be called or indexed:

```dart
Expression call() {
  Expression exp = primary();

  while (true) {
    if (match([(t) => t is OpenParenthesisToken])) {
      // TYPE CHECK: Only allows IdentifierExpression or CallExpression
      if ((exp is IdentifierExpression) || (exp is CallExpression)) {
        exp = finishCall(exp);
      } else {
        throw InvalidTokenError(
          previous,
          'callable expression (identifier or function call) before',
        );
      }
    } else if (match([(t) => t is OpenBracketToken])) {
      // TYPE CHECK: Only allows specific expression types
      if ((exp is IdentifierExpression) ||
          (exp is CallExpression) ||
          (exp is StringExpression) ||
          (exp is ListExpression) ||
          (exp is MapExpression)) {
        // ... perform indexing
      } else {
        throw InvalidTokenError(
          previous,
          'indexable expression (identifier, function call, string, list, or map) before',
        );
      }
    } else {
      break;
    }
  }

  return exp;
}
```

### Why This Is Problematic

#### 1. Violates Separation of Concerns

The parser's job is to convert a stream of tokens into an Abstract Syntax Tree (AST). Deciding what is "callable" or "indexable" is a **semantic** decision that belongs in semantic analysis.

The classic compiler pipeline is:
```
Lexical Analysis → Syntactic Analysis → Semantic Analysis → Code Generation
                   (tokens → AST)       (type checking)
```

Mixing semantic checks into the parser blurs this boundary and makes both harder to maintain.

#### 2. Rejects Valid Syntax

Consider this input:
```
(1 + 2)(x)
```

**Syntactically**, this is valid:
- A parenthesized expression `(1 + 2)`
- Followed by a function call syntax `(x)`

The parser should produce:
```
CallExpression(
  callee: CallExpression(+, [1, 2]),  // from binary operation
  arguments: [IdentifierExpression(x)]
)
```

But currently, the parser **rejects** this because `CallExpression.fromBinaryOperation` returns a `CallExpression`, which IS in the allowed list... but wait, let me trace through more carefully:

Actually, `1 + 2` produces a `CallExpression` (because operators are desugared), so this specific case would pass. Let me find a case that actually fails:

```
(1)(x)
```

Here:
- `(1)` is parsed as `NumberExpression(1)` (parentheses just group, don't change type)
- `(x)` attempts to call it

Since `NumberExpression` is not in `[IdentifierExpression, CallExpression]`, this throws `InvalidTokenError`.

**But is `(1)(x)` valid Primal?** That's a semantic question! The parser shouldn't decide. It should build:
```
CallExpression(
  callee: NumberExpression(1),
  arguments: [IdentifierExpression(x)]
)
```

And let semantic analysis report: "Cannot call a number."

#### 3. Error Messages Are Misleading

The error says "invalid token" but the token `(` is perfectly valid. The problem isn't the token—it's that the preceding expression can't be called. This is a type error, not a syntax error.

#### 4. Whitelist Is Incomplete/Arbitrary

For calling (lines 192-193):
```dart
if ((exp is IdentifierExpression) || (exp is CallExpression))
```

For indexing (lines 201-205):
```dart
if ((exp is IdentifierExpression) ||
    (exp is CallExpression) ||
    (exp is StringExpression) ||
    (exp is ListExpression) ||
    (exp is MapExpression))
```

Why isn't `BooleanExpression` in the indexing list? Because booleans can't be indexed. But that's a semantic decision! What if a future version of Primal adds a type that can be indexed? You'd need to update the parser.

### Proposed Solution

Remove all type checks from `call()`. Accept any expression as a callee or indexee:

```dart
Expression call() {
  Expression exp = primary();

  while (true) {
    if (match([(t) => t is OpenParenthesisToken])) {
      // No type check - any expression can syntactically be "called"
      exp = finishCall(exp);
    } else if (match([(t) => t is OpenBracketToken])) {
      // No type check - any expression can syntactically be "indexed"
      final Token operator = AtToken(
        Lexeme(
          value: '@',
          location: previous.location,
        ),
      );
      final Expression idx = expression();
      consume((t) => t is CloseBracketToken, ']');
      exp = CallExpression.fromBinaryOperation(
        operator: operator,
        left: exp,
        right: idx,
      );
    } else {
      break;
    }
  }

  return exp;
}
```

Then add validation in semantic analysis to report meaningful errors like:
- "Cannot call expression of type Number"
- "Cannot index expression of type Boolean"

### Impact on Tests

**Tests that will break:**

From `test/compiler/expression_parser_test.dart`:

```dart
test('non-identifier call throws InvalidTokenError', () {
  expect(
    () => getExpression('5(1)'),
    throwsA(isA<InvalidTokenError>()),
  );
});

test('non-indexable bracket access throws InvalidTokenError', () {
  expect(
    () => getExpression('5[0]'),
    throwsA(isA<InvalidTokenError>()),
  );
});
```

**Required test changes:**

1. **Remove** or **modify** the above tests since `5(1)` and `5[0]` will now parse successfully
2. **Add tests** verifying that these parse into the expected AST:
   ```dart
   test('Number followed by call syntax parses as CallExpression', () {
     final Expression expression = getExpression('5(1)');
     expect(expression, isA<CallExpression>());
     final call = expression as CallExpression;
     expect(call.callee, isA<NumberExpression>());
     expect(call.arguments.length, 1);
   });

   test('Number followed by index syntax parses as index operation', () {
     final Expression expression = getExpression('5[0]');
     expect(expression.toString(), '@(5, 0)');
   });
   ```

3. **Add semantic analysis tests** to verify that type errors are caught during semantic analysis (not parsing):
   ```dart
   // In semantic_analyzer_test.dart
   test('Calling a number produces semantic error', () {
     expect(
       () => analyze('main = 5(1)'),
       throwsA(isA<SemanticError>()), // or whatever error type
     );
   });
   ```

### Files to Modify

| File | Change |
|------|--------|
| `lib/compiler/syntactic/expression_parser.dart` | Remove type checks in `call()` |
| `lib/compiler/semantic/semantic_analyzer.dart` | Add "is callable" / "is indexable" validation |
| `test/compiler/expression_parser_test.dart` | Update/remove error tests, add AST structure tests |
| `test/compiler/semantic_analyzer_test.dart` | Add type validation tests |

---

## Issue #3: `ResultState` Doesn't Implement `process()`

### Location

`lib/compiler/syntactic/syntactic_analyzer.dart`, lines 141-143

### Current Behavior

```dart
class ResultState extends State<void, FunctionDefinition> {
  const ResultState(super.iterator, super.output);
  // No process() override!
}
```

Looking at the `State` base class (`lib/compiler/models/state.dart`):

```dart
class State<I, O> {
  final O output;
  final ListIterator<I> iterator;

  const State(this.iterator, this.output);

  State get next => process(iterator.next);  // Calls process()

  State process(I input) => this;  // Default: returns self
}
```

### Why This Is Problematic

#### 1. Silent Infinite Loop Risk

The default `process()` implementation returns `this`. If someone accidentally calls `.next` on a `ResultState`:

```dart
State state = ResultState(iterator, functionDef);
state = state.next;  // Calls process(), which returns 'this'
state = state.next;  // Same thing - infinite loop if in a while loop
```

The current code in `SyntacticAnalyzer.analyze()` avoids this by checking `if (state is ResultState)` before the next iteration:

```dart
while (iterator.hasNext) {
  state = state.next;

  if (state is ResultState) {
    result.add(state.output);
    state = InitState(iterator);  // Reset before next state.next call
  }
}
```

But this relies on the loop structure being exactly right. It's a fragile implicit contract.

#### 2. `ResultState` Has `void` as Input Type

```dart
class ResultState extends State<void, FunctionDefinition>
```

The generic type `I` is `void`, meaning `process(I input)` becomes `process(void input)`. In Dart, you can't actually pass a `void` value, so calling `iterator.next` (which returns a `Token`, not `void`) would cause a type mismatch at runtime if the type system were stricter.

Currently it "works" because:
1. `process()` is never called on `ResultState`
2. Dart's type system allows this due to how `void` and generics interact

#### 3. Code Doesn't Express Intent

A reader looking at `ResultState` might wonder: "What happens if `process()` is called?" The answer requires understanding the entire state machine flow, not just the class itself.

### Proposed Solution

Override `process()` to throw an explicit error:

```dart
class ResultState extends State<void, FunctionDefinition> {
  const ResultState(super.iterator, super.output);

  @override
  State process(void input) {
    throw StateError(
      'ResultState is a terminal state and should not be processed. '
      'Check for ResultState before calling next.',
    );
  }
}
```

Alternatively, override the `next` getter directly:

```dart
class ResultState extends State<void, FunctionDefinition> {
  const ResultState(super.iterator, super.output);

  @override
  State get next => throw StateError(
    'ResultState is a terminal state. Check for ResultState before calling next.',
  );
}
```

The second approach is cleaner because it prevents `iterator.next` from being called at all (which could advance the iterator unexpectedly).

### Impact on Tests

**New tests to add** in `test/compiler/syntactic_analyzer_test.dart`:

```dart
test('ResultState.next throws StateError', () {
  final iterator = ListIterator<Token>([]);
  final resultState = ResultState(
    iterator,
    FunctionDefinition(
      name: 'test',
      expression: BooleanExpression(booleanToken(true, 1, 1)),
    ),
  );

  expect(
    () => resultState.next,
    throwsA(isA<StateError>()),
  );
});
```

### Files to Modify

| File | Change |
|------|--------|
| `lib/compiler/syntactic/syntactic_analyzer.dart` | Override `next` in `ResultState` to throw |
| `test/compiler/syntactic_analyzer_test.dart` | Add test for `ResultState.next` throwing |

---

## Issue #4: `previous` Assumes Non-Null

### Location

`lib/compiler/syntactic/expression_parser.dart`, line 351

### Current Behavior

```dart
Token get previous => iterator.previous!;
```

The `!` operator (null assertion) assumes `iterator.previous` is never null.

Looking at `ListIterator.previous` (`lib/utils/list_iterator.dart`):

```dart
T? get previous {
  if (_index > 0) {
    return _list[_index - 1];
  } else {
    return null;  // Returns null when at position 0!
  }
}
```

### Why This Is Problematic

#### 1. Crash on Edge Case

If `previous` is accessed before any call to `advance()` or `next`, the iterator is at position 0, `iterator.previous` returns `null`, and the `!` operator throws a runtime exception.

#### 2. Current Safety Is Coincidental

The code is currently safe because:

1. `SyntacticAnalyzer.analyze()` checks `iterator.hasNext` before creating `ExpressionParser`
2. The state machine always advances at least once (consuming the function name) before expression parsing begins
3. Within `ExpressionParser`, `previous` is only accessed after `match()` or `advance()` returns true

But these guarantees are spread across multiple files and aren't documented or enforced.

#### 3. Standalone `ExpressionParser` Usage Is Unsafe

In tests, `ExpressionParser` is used directly:

```dart
Expression getExpression(String input) {
  final List<Token> tokens = getTokens(input);
  final ExpressionParser parser = ExpressionParser(ListIterator(tokens));
  return parser.expression();
}
```

If `getTokens` returned an empty list (e.g., for whitespace-only input), and if the parsing logic somehow accessed `previous` before advancing, it would crash.

Currently this doesn't happen because `primary()` calls `peek` first (which handles empty input gracefully by throwing `UnexpectedEndOfFileError`). But the safety is implicit.

### Proposed Solution

#### Option A: Defensive Check in Getter

Add a null check with a descriptive error:

```dart
Token get previous {
  final Token? token = iterator.previous;
  if (token == null) {
    throw StateError(
      'Attempted to access previous token before any tokens were consumed. '
      'This indicates a bug in the parser.',
    );
  }
  return token;
}
```

#### Option B: Document the Precondition

If performance is a concern (avoiding the null check on every access), document the precondition clearly:

```dart
/// Returns the most recently consumed token.
///
/// PRECONDITION: At least one token must have been consumed via [advance]
/// or [match] before calling this getter. Violating this precondition
/// results in a null assertion failure.
Token get previous => iterator.previous!;
```

#### Option C: Use Late Initialization Pattern

Track the previous token explicitly:

```dart
class ExpressionParser {
  final ListIterator<Token> iterator;
  Token? _previous;

  const ExpressionParser(this.iterator);

  Token advance() {
    if (!iterator.isAtEnd) {
      _previous = iterator.peek;
      iterator.advance();
    }
    return previous;
  }

  Token get previous {
    if (_previous == null) {
      throw StateError('No token has been consumed yet.');
    }
    return _previous!;
  }

  // ... rest of class
}
```

This approach makes `ExpressionParser` self-contained and doesn't rely on `ListIterator.previous`.

### Recommended Approach

**Option A** provides the best balance of safety and simplicity. The null check is minimal overhead and provides a clear error message if the invariant is violated.

### Impact on Tests

**New tests to add** in `test/compiler/expression_parser_test.dart`:

```dart
group('ExpressionParser edge cases', () {
  test('accessing previous before advance throws StateError', () {
    final parser = ExpressionParser(ListIterator([
      identifierToken('x', 1, 1),
    ]));

    // Directly access previous without consuming any tokens
    // This tests the defensive check
    expect(
      () => parser.previous,
      throwsA(isA<StateError>()),
    );
  });

  test('previous returns last consumed token after advance', () {
    final token = identifierToken('x', 1, 1);
    final parser = ExpressionParser(ListIterator([token]));

    parser.advance();
    expect(parser.previous, equals(token));
  });
});
```

Note: These tests require making `previous` accessible for testing, or testing through the public API in a way that exercises the edge case.

### Files to Modify

| File | Change |
|------|--------|
| `lib/compiler/syntactic/expression_parser.dart` | Add null check to `previous` getter |
| `test/compiler/expression_parser_test.dart` | Add edge case tests |

---

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

| File | Change |
|------|--------|
| `lib/compiler/syntactic/expression_parser.dart` | Add static predicates, update `match()` calls |
| `test/compiler/expression_parser_test.dart` | (Optional) Add performance test |

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

| File | Change |
|------|--------|
| `lib/compiler/syntactic/expression.dart` | Add `location` field to `MapEntryExpression` |
| `lib/compiler/syntactic/expression_parser.dart` | Pass `key.location` when creating `MapEntryExpression` |
| `test/compiler/syntactic_analyzer_test.dart` | Update all `MapEntryExpression` constructions |
| `test/compiler/expression_parser_test.dart` | Update map-related tests if needed |

---

## Summary: Implementation Order

Recommended order of implementation (least to most disruptive):

| Order | Issue | Risk | Effort | Files Changed |
|-------|-------|------|--------|---------------|
| 1 | #3: `ResultState.next` throws | Very Low | Low | 2 |
| 2 | #4: `previous` null check | Very Low | Low | 2 |
| 3 | #7: Static predicates | Very Low | Medium | 2 |
| 4 | #8: `MapEntryExpression` location | Low | Medium | 4 |
| 5 | #2: Remove type checks from parser | Medium | High | 4+ |

Issues #3, #4, and #7 are pure improvements with no behavioral changes.

Issue #8 is a data model change that requires updating tests but doesn't change parser behavior.

Issue #2 is the most significant change, as it moves validation from syntactic to semantic analysis. This should be done last after the other improvements are stable.

---

## Test Plan Summary

### New Tests to Add

| Test File | Test Description |
|-----------|------------------|
| `syntactic_analyzer_test.dart` | `ResultState.next` throws `StateError` |
| `expression_parser_test.dart` | `previous` before advance throws `StateError` |
| `expression_parser_test.dart` | `previous` after advance returns correct token |
| `expression_parser_test.dart` | (Optional) Performance benchmark |
| `syntactic_analyzer_test.dart` | `MapEntryExpression` has correct location |
| `expression_parser_test.dart` | `5(1)` parses as `CallExpression` with `NumberExpression` callee |
| `expression_parser_test.dart` | `5[0]` parses as index operation on `NumberExpression` |
| `semantic_analyzer_test.dart` | Calling a number produces semantic error |
| `semantic_analyzer_test.dart` | Indexing a boolean produces semantic error |

### Tests to Modify

| Test File | Current Test | Change Required |
|-----------|--------------|-----------------|
| `expression_parser_test.dart` | `'non-identifier call throws InvalidTokenError'` | Remove or change to expect successful parse |
| `expression_parser_test.dart` | `'non-indexable bracket access throws InvalidTokenError'` | Remove or change to expect successful parse |
| `syntactic_analyzer_test.dart` | All `MapEntryExpression` constructions | Add `location` parameter |

---

## Conclusion

These five issues range from minor (lambda allocation) to architectural (mixing syntactic and semantic concerns). Addressing them will:

1. **Improve correctness** - Better separation of concerns, explicit error handling
2. **Improve maintainability** - Self-documenting code, explicit invariants
3. **Improve error messages** - Better source location reporting
4. **Improve performance** - Reduced allocations (minor impact, but good practice)

The recommended implementation order minimizes risk by starting with isolated changes and building toward the larger architectural refactoring.
