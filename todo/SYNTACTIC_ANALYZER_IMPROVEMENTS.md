# Syntactic Analyzer Improvement Plan

This document details issues found in the syntactic analyzer and the plan to fix them.

**Files involved:**
- `lib/compiler/syntactic/expression_parser.dart`
- `lib/compiler/syntactic/syntactic_analyzer.dart`
- `lib/compiler/syntactic/expression.dart`

---

## Issue 1: Operator Precedence - Logic vs Comparison

### Problem Description

In most programming languages, comparison operators (`>`, `<`, `>=`, `<=`) have **higher** precedence than logical operators (`&`, `|`). This allows natural expressions like:

```
a > b & c > d
```

to be parsed as:

```
(a > b) & (c > d)
```

However, the current implementation has the **opposite** precedence. The call chain in `expression_parser.dart` is:

```
expression() → ifExpression() → equality() → comparison() → logic() → term() → ...
```

In recursive descent parsing, functions called **later** in the chain have **higher** precedence (they bind tighter). Currently:

| Function     | Calls        | Precedence |
|--------------|--------------|------------|
| `equality()` | `comparison()` | Lower |
| `comparison()` | `logic()` | ↓ |
| `logic()` | `term()` | Higher |

This means `logic` binds tighter than `comparison`, so:

```
a > b & c > d
```

parses as:

```
a > (b & c) > d
```

which is almost certainly not what users expect.

### Solution

Swap the positions of `comparison()` and `logic()` in the call chain:

**Current chain:**
```
equality() → comparison() → logic() → term()
```

**Fixed chain:**
```
equality() → logic() → comparison() → term()
```

### Implementation

In `lib/compiler/syntactic/expression_parser.dart`:

1. **Modify `equality()` (line 35-50):** Change the call from `comparison()` to `logic()`.

   ```dart
   Expression equality() {
     Expression expression = logic();  // Changed from comparison()

     while (match([NotEqualToken, EqualToken])) {
       final Token operator = previous;
       final Expression right = logic();  // Changed from comparison()
       // ...
     }
     return expression;
   }
   ```

2. **Modify `logic()` (line 74-89):** Change the call from `term()` to `comparison()`.

   ```dart
   Expression logic() {
     Expression expression = comparison();  // Changed from term()

     while (match([PipeToken, AmpersandToken])) {
       final Token operator = previous;
       final Expression right = comparison();  // Changed from term()
       // ...
     }
     return expression;
   }
   ```

3. **Modify `comparison()` (line 52-72):** Change the call from `logic()` to `term()`.

   ```dart
   Expression comparison() {
     Expression expression = term();  // Changed from logic()

     while (match([GreaterThanToken, GreaterEqualThanToken, LessThanToken, LessEqualThanToken])) {
       final Token operator = previous;
       final Expression right = term();  // Changed from logic()
       // ...
     }
     return expression;
   }
   ```

### Result

New precedence (lowest to highest):
1. `if` expression
2. `equality` (`==`, `!=`)
3. `logic` (`|`, `&`)
4. `comparison` (`>`, `>=`, `<`, `<=`)
5. `term` (`+`, `-`)
6. `factor` (`*`, `/`, `%`)
7. `unary` (`!`, `-`)
8. `call` (function application, indexing)
9. `primary` (literals, identifiers, grouping)

Update the file `docs/compiler/syntactic.md` if necessary.

---

## Issue 2: AND and OR Have Same Precedence

### Problem Description

Currently, both `|` (or) and `&` (and) are handled in the same `logic()` function:

```dart
Expression logic() {
  Expression expression = term();

  while (match([PipeToken, AmpersandToken])) {  // Both here!
    // ...
  }
  return expression;
}
```

This means they have the **same** precedence and are left-associative. So:

```
a | b & c
```

parses as:

```
(a | b) & c
```

In most languages, `&` (and) has higher precedence than `|` (or), so the expected parse would be:

```
a | (b & c)
```

### Solution

Split `logic()` into two separate functions: `logicOr()` and `logicAnd()`, where `logicAnd()` has higher precedence.

### Implementation

In `lib/compiler/syntactic/expression_parser.dart`:

1. **Rename `logic()` to `logicOr()` and handle only `|`:**

   ```dart
   Expression logicOr() {
     Expression expression = logicAnd();  // Call the higher-precedence function

     while (match([PipeToken])) {  // Only OR
       final Token operator = previous;
       final Expression right = logicAnd();

       expression = CallExpression.fromBinaryOperation(
         operator: operator,
         left: expression,
         right: right,
       );
     }

     return expression;
   }
   ```

2. **Create new `logicAnd()` function:**

   ```dart
   Expression logicAnd() {
     Expression expression = comparison();  // After Issue 1 fix

     while (match([AmpersandToken])) {  // Only AND
       final Token operator = previous;
       final Expression right = comparison();

       expression = CallExpression.fromBinaryOperation(
         operator: operator,
         left: expression,
         right: right,
       );
     }

     return expression;
   }
   ```

3. **Update `equality()` to call `logicOr()` instead of `logic()`:**

   ```dart
   Expression equality() {
     Expression expression = logicOr();  // Updated
     // ...
   }
   ```

### Result

New precedence for logical operators:
- `|` (or): lower precedence
- `&` (and): higher precedence

Expression `a | b & c` now correctly parses as `a | (b & c)`.

Update the file `docs/compiler/syntactic.md` if necessary.

---

## Issue 3: Chained Indexing Doesn't Work

### Problem Description

In `call()` (lines 149-185), the indexing branch uses a simple `if` instead of a `while` loop:

```dart
Expression call() {
  Expression exp = primary();

  if (check(OpenParenthesisToken)) {
    while (match([OpenParenthesisToken])) {  // Loop for calls
      // ...
    }
  } else if (match([OpenBracketToken])) {  // NO loop for indexing!
    // ... handles only ONE index operation
  }

  return exp;
}
```

This means:

```
a[0][1]
```

will parse `a[0]` but then stop, leaving `[1]` unparsed (causing an error or incorrect behavior).

### Solution

Restructure `call()` to handle both function calls and indexing in a unified loop that can handle any combination.

### Implementation

Rewrite `call()` in `lib/compiler/syntactic/expression_parser.dart`:

```dart
Expression call() {
  Expression exp = primary();

  while (true) {
    if (match([OpenParenthesisToken])) {
      // Function call
      if ((exp is IdentifierExpression) || (exp is CallExpression)) {
        exp = finishCall(exp);
      } else {
        throw InvalidTokenError(previous);  // Use previous since we already consumed '('
      }
    } else if (match([OpenBracketToken])) {
      // Indexing
      if ((exp is IdentifierExpression) ||
          (exp is CallExpression) ||
          (exp is StringExpression) ||
          (exp is ListExpression) ||
          (exp is MapExpression)) {
        final Token operator = IdentifierToken(
          Lexeme(
            value: 'element.at',
            location: previous.location,
          ),
        );
        final Expression index = expression();
        consume(CloseBracketToken, ']');
        exp = CallExpression.fromBinaryOperation(
          operator: operator,
          left: exp,
          right: index,
        );
      } else {
        throw InvalidTokenError(previous);
      }
    } else {
      break;  // No more calls or indexing
    }
  }

  return exp;
}
```

### Result

The following expressions now work:
- `a[0][1]` - chained indexing
- `a[0][1][2]` - arbitrary depth indexing
- `matrix[i][j]` - 2D array access

Update the file `docs/compiler/syntactic.md` if necessary.

---

## Issue 4: Mixed Call/Index Chains Don't Work

### Problem Description

This is related to Issue 3. The current `if`/`else if` structure means:

```dart
if (check(OpenParenthesisToken)) {
  while (match([OpenParenthesisToken])) {
    // handle calls
  }
} else if (match([OpenBracketToken])) {
  // handle ONE index
}
```

After handling calls, we never check for `[`. After handling one index, we never check for `(` or another `[`. So:

- `f()[0]` - call a function, then index the result: **FAILS**
- `a[0]()` - index into array, then call the result: **FAILS**
- `f()[0]()` - call, index, call: **FAILS**
- `matrix[0][1]` - chained indexing: **FAILS** (same as Issue 3)

### Solution

The fix from Issue 3 (unified loop) also fixes this issue. By using a `while(true)` loop that checks for both `(` and `[` on each iteration, we can handle any sequence of calls and indexing.

### Implementation

Same as Issue 3. The rewritten `call()` function handles both scenarios in a single loop.

### Result

All these expressions now work:
- `f()` - simple call
- `a[0]` - simple index
- `f()[0]` - call then index
- `a[0]()` - index then call
- `f()[0]()` - call, index, call
- `getMatrix()[i][j]` - call then double index
- `callbacks[0]()` - index then call

Update the file `docs/compiler/syntactic.md` if necessary.

---

## Issue 5: Zero-Parameter Functions Fail

### Problem Description

In `syntactic_analyzer.dart`, when parsing a function with parameters, the state machine expects:

```
FunctionNameState --'('--> FunctionWithParametersState
```

`FunctionWithParametersState` (lines 68-82) expects the next token to be an identifier:

```dart
class FunctionWithParametersState extends State<Token, FunctionDefinition> {
  @override
  State process(Token input) {
    if (input is IdentifierToken) {  // Expects identifier!
      return FunctionWithNewParametersState(
        iterator,
        output.withParameter(input.value),
      );
    } else {
      throw InvalidTokenError(input, 'parameters list');
    }
  }
}
```

This means `f() = 1` fails because after `(`, it sees `)` instead of an identifier.

### Solution

Modify `FunctionWithParametersState` to also accept `)` (close parenthesis) for zero-parameter functions.

### Implementation

In `lib/compiler/syntactic/syntactic_analyzer.dart`, modify `FunctionWithParametersState`:

```dart
class FunctionWithParametersState extends State<Token, FunctionDefinition> {
  const FunctionWithParametersState(super.iterator, super.output);

  @override
  State process(Token input) {
    if (input is IdentifierToken) {
      return FunctionWithNewParametersState(
        iterator,
        output.withParameter(input.value),
      );
    } else if (input is CloseParenthesisToken) {
      // Zero-parameter function: f() = expr
      return FunctionParametrizedState(iterator, output);
    } else {
      throw InvalidTokenError(input, 'identifier or \')\'');
    }
  }
}
```

### Result

Both syntaxes now work:
- `f = 1` - nullary function (no parentheses)
- `f() = 1` - zero-parameter function (explicit empty parens)

Update the file `docs/compiler/syntactic.md` if necessary.

---

## Issue 6: No Trailing Comma Support

### Problem Description

In `list()` (lines 223-238) and `map()` (lines 240-258), the parsing logic is:

```dart
if (!check(CloseBracketToken)) {
  do {
    elements.add(expression());
  } while (match([CommaToken]));
}
consume(CloseBracketToken, ']');
```

After consuming a comma, it immediately tries to parse another expression. This means:

```
[1, 2, 3,]
```

fails because after the trailing comma, it tries to parse an expression but finds `]`.

### Solution

After matching a comma, check if the next token is the closing delimiter before trying to parse another element.

### Implementation

1. **Modify `list()` in `lib/compiler/syntactic/expression_parser.dart`:**

   ```dart
   Expression list(Token token) {
     final List<Expression> elements = [];

     if (!check(CloseBracketToken)) {
       do {
         elements.add(expression());
       } while (match([CommaToken]) && !check(CloseBracketToken));  // Added check
     }

     consume(CloseBracketToken, ']');

     return ListExpression(
       location: token.location,
       value: elements,
     );
   }
   ```

2. **Modify `map()` in `lib/compiler/syntactic/expression_parser.dart`:**

   ```dart
   Expression map(Token token) {
     final Map<Expression, Expression> pairs = {};

     if (!check(CloseBracesToken)) {
       do {
         final Expression key = expression();
         consume(ColonToken, ':');
         final Expression value = expression();
         pairs[key] = value;
       } while (match([CommaToken]) && !check(CloseBracesToken));  // Added check
     }

     consume(CloseBracesToken, '}');

     return MapExpression(
       location: token.location,
       value: pairs,
     );
   }
   ```

3. **Modify `finishCall()` for consistency (function arguments):**

   ```dart
   Expression finishCall(Expression callee) {
     final List<Expression> arguments = [];

     if (!check(CloseParenthesisToken)) {
       do {
         arguments.add(expression());
       } while (match([CommaToken]) && !check(CloseParenthesisToken));  // Added check
     }

     consume(CloseParenthesisToken, ')');

     return CallExpression(callee: callee, arguments: arguments);
   }
   ```

### Result

These expressions now parse correctly:
- `[1, 2, 3,]` - list with trailing comma
- `{a: 1, b: 2,}` - map with trailing comma
- `f(x, y,)` - function call with trailing comma

Update the file `docs/compiler/syntactic.md` if necessary.

---

## Issue 7: Expression as Map Keys (Design Smell)

### Problem Description

`MapExpression` in `expression.dart` uses `Map<Expression, Expression>`:

```dart
class MapExpression extends LiteralExpression<Map<Expression, Expression>> {
  // ...
}
```

And in `map()` parsing:

```dart
final Map<Expression, Expression> pairs = {};
// ...
pairs[key] = value;  // Expression as key
```

The problem is that `Expression` (and its subclasses) don't implement `==` and `hashCode`. Dart's default object equality is identity-based, so:

```
{1: "a", 1: "b"}
```

would create **two separate entries** instead of detecting a duplicate key, because the two `NumberExpression(1)` instances are different objects.

### Solution

There are two approaches:

**Option A: Use a List of pairs instead of a Map**

This avoids the equality problem entirely and preserves insertion order. Duplicate detection can be done at a later compilation phase (semantic analysis).

**Option B: Implement equality on Expression classes**

Add `==` and `hashCode` to all `Expression` subclasses based on their values.

### Recommended Approach: Option A

Using a list of pairs is simpler and defers duplicate key detection to semantic analysis, which is the appropriate phase for such validation.

### Implementation (Option A)

1. **Create a `MapEntry` class or use a record** in `lib/compiler/syntactic/expression.dart`:

   ```dart
   class MapEntryExpression {
     final Expression key;
     final Expression value;

     const MapEntryExpression({required this.key, required this.value});
   }
   ```

2. **Modify `MapExpression`:**

   ```dart
   class MapExpression extends LiteralExpression<List<MapEntryExpression>> {
     const MapExpression({
       required super.location,
       required super.value,
     });

     @override
     Node toNode() {
       final Map<Node, Node> nodeMap = {};
       for (final entry in value) {
         nodeMap[entry.key.toNode()] = entry.value.toNode();
       }
       return MapNode(nodeMap);
     }
   }
   ```

3. **Modify `map()` in `expression_parser.dart`:**

   ```dart
   Expression map(Token token) {
     final List<MapEntryExpression> pairs = [];

     if (!check(CloseBracesToken)) {
       do {
         final Expression key = expression();
         consume(ColonToken, ':');
         final Expression value = expression();
         pairs.add(MapEntryExpression(key: key, value: value));
       } while (match([CommaToken]) && !check(CloseBracesToken));
     }

     consume(CloseBracesToken, '}');

     return MapExpression(
       location: token.location,
       value: pairs,
     );
   }
   ```

### Result

- Map literals preserve order and can have duplicate keys at parse time
- Duplicate key detection moves to semantic analysis (where it belongs)
- No need to implement equality on all Expression classes

Update the file `docs/compiler/syntactic.md` if necessary.

---

## Summary: Implementation Order

I recommend implementing these fixes in the following order:

1. **Issue 5** (zero-param functions) - Simple, isolated change
2. **Issue 6** (trailing commas) - Simple, isolated changes
3. **Issue 3 & 4** (call/index chaining) - Rewrite `call()` function
4. **Issue 1 & 2** (operator precedence) - Reorder and split precedence functions
5. **Issue 7** (map keys) - Requires changes to data structures

### Files to Modify

| File | Issues |
|------|--------|
| `lib/compiler/syntactic/syntactic_analyzer.dart` | Issue 5 |
| `lib/compiler/syntactic/expression_parser.dart` | Issues 1, 2, 3, 4, 6, 7 |
| `lib/compiler/syntactic/expression.dart` | Issue 7 |

### Testing Considerations

After implementing these fixes, add or update tests for:

1. Operator precedence: `a > b & c`, `a | b & c`, `a == b > c`
2. Chained operations: `a[0][1]`, `f()()`, `f()[0]`, `a[0]()`
3. Zero-param functions: `f() = 1`
4. Trailing commas: `[1,]`, `{a: 1,}`, `f(x,)`
5. Map literals with duplicate keys (if semantic analysis is added)

---

## Documentation Update

After implementing these changes, update `docs/compiler/syntactic.md` to reflect:

1. Corrected precedence table
2. Split of `logic` into `logicOr` and `logicAnd`
3. Support for zero-parameter function syntax
4. Support for trailing commas
5. Changed internal representation of map literals (if Option A is chosen)
