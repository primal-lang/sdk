## Issue 3: Inconsistent Token Creation for `[]` Indexing

**Severity**: Low
**Files**: `lib/compiler/syntactic/expression_parser.dart`

### Problem

Bracket indexing `arr[0]` creates an `IdentifierToken` with value `'@'`, but the `@` operator produces an `AtToken`:

```dart
// Current code (line 199-204)
final Token operator = IdentifierToken(
  Lexeme(value: '@', location: previous.location),
);
```

This inconsistency means:

- `arr @ 0` has operator type `AtToken`
- `arr[0]` has operator type `IdentifierToken` (with value `'@'`)

### Plan

1. Change `IdentifierToken` to `AtToken` in the bracket indexing branch
2. Verify no downstream code relies on the token being an `IdentifierToken`
3. Add test to verify `arr[0]` and `arr @ 0` produce identical ASTs

### Implementation

```dart
// In call() method, around line 199
} else if (match([(t) => t is OpenBracketToken])) {
  if ((exp is IdentifierExpression) ||
      (exp is CallExpression) ||
      (exp is StringExpression) ||
      (exp is ListExpression) ||
      (exp is MapExpression)) {
    final Token operator = AtToken(  // Changed from IdentifierToken
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
    throw InvalidTokenError(previous);
  }
}
```

---

## Issue 4: Vague Error Messages

**Severity**: Medium
**Files**: `lib/compiler/syntactic/syntactic_analyzer.dart`, `lib/compiler/syntactic/expression_parser.dart`

### Problem

Several error messages are vague or missing expected token information:

| Location                      | Current Message     | Problem                   |
| ----------------------------- | ------------------- | ------------------------- |
| `syntactic_analyzer.dart:79`  | `'parameters list'` | Should say `'identifier'` |
| `syntactic_analyzer.dart:110` | `'identifier'`      | OK                        |
| `expression_parser.dart:191`  | No expected value   | Missing context           |
| `expression_parser.dart:212`  | No expected value   | Missing context           |

### Plan

1. Audit all `InvalidTokenError` and `ExpectedTokenError` calls
2. Ensure each error specifies what was expected
3. Make messages context-aware where possible

### Implementation

**File: `syntactic_analyzer.dart`**

```dart
// Line 79 - FunctionWithParametersState
throw InvalidTokenError(input, 'identifier');  // Changed from 'parameters list'

// After fixing Issue 1, this becomes:
throw InvalidTokenError(input, "identifier or ')'");
```

**File: `expression_parser.dart`**

```dart
// Line 191 - in call() when expression is not callable
if (match([OpenParenthesisToken])) {
  if ((exp is IdentifierExpression) || (exp is CallExpression)) {
    exp = finishCall(exp);
  } else {
    throw InvalidTokenError(previous, 'callable expression before');
    // Or create a new error type: ExpressionNotCallableError(exp)
  }
}

// Line 212 - in call() when expression is not indexable
} else {
  throw InvalidTokenError(previous, 'indexable expression before');
  // Or create a new error type: ExpressionNotIndexableError(exp)
}
```

### Consider New Error Types

For better error messages, consider adding specific error classes:

```dart
class ExpressionNotCallableError extends SyntacticError {
  final Expression expression;
  ExpressionNotCallableError(this.expression);

  @override
  String get message =>
    'Cannot call ${expression.runtimeType} at ${expression.location}';
}

class ExpressionNotIndexableError extends SyntacticError {
  final Expression expression;
  ExpressionNotIndexableError(this.expression);

  @override
  String get message =>
    'Cannot index ${expression.runtimeType} at ${expression.location}';
}
```

---

## Issue 5: Nullable `expression` Field in `FunctionDefinition`

**Severity**: Low
**Files**: `lib/compiler/syntactic/function_definition.dart`, `lib/compiler/syntactic/syntactic_analyzer.dart`

### Problem

`FunctionDefinition.expression` is nullable but a valid function always has an expression. The nullability is only needed during incremental construction.

```dart
class FunctionDefinition {
  final String name;
  final List<String> parameters;
  final Expression? expression;  // Always set in practice
  ...
}
```

### Plan

Split into two types: one for building, one for the final result.

### Implementation

**Option A: Separate Builder Class**

```dart
// In function_definition.dart

/// Used during parsing to incrementally build a function definition.
class FunctionDefinitionBuilder {
  final String name;
  final List<String> parameters;

  const FunctionDefinitionBuilder({
    required this.name,
    this.parameters = const [],
  });

  FunctionDefinitionBuilder withParameter(String parameter) =>
      FunctionDefinitionBuilder(
        name: name,
        parameters: [...parameters, parameter],
      );

  FunctionDefinition build(Expression expression) => FunctionDefinition(
        name: name,
        parameters: parameters,
        expression: expression,
      );
}

/// A complete function definition with a guaranteed expression.
class FunctionDefinition {
  final String name;
  final List<String> parameters;
  final Expression expression;  // Non-nullable

  const FunctionDefinition({
    required this.name,
    this.parameters = const [],
    required this.expression,
  });
}
```

**Changes to `syntactic_analyzer.dart`**:

```dart
class InitState extends State<Token, void> {
  @override
  State process(Token input) {
    if (input is IdentifierToken) {
      return FunctionNameState(
        iterator,
        FunctionDefinitionBuilder(name: input.value),  // Use builder
      );
    } else {
      throw InvalidTokenError(input, 'identifier');
    }
  }
}

class FunctionNameState extends State<Token, FunctionDefinitionBuilder> {
  @override
  State process(Token input) {
    if (input is AssignToken) {
      final parser = ExpressionParser(iterator);
      return ResultState(
        iterator,
        output.build(parser.expression()),  // Build final definition
      );
    }
    // ... rest unchanged but uses builder
  }
}

// All intermediate states use FunctionDefinitionBuilder
// Only ResultState uses FunctionDefinition
```

**Option B: Keep Current Design (Document)**

If the refactor is too invasive, document the invariant:

```dart
class FunctionDefinition {
  final String name;
  final List<String> parameters;
  /// Always non-null after parsing is complete.
  /// Nullable only during incremental construction in the parser.
  final Expression? expression;
  ...
}
```
