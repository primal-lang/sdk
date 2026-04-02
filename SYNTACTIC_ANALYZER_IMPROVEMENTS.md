## Issue 2: Fragile Type Checking with `runtimeType`

**Severity**: Medium
**Files**: `lib/compiler/syntactic/expression_parser.dart`

### Problem

The `check()` method uses `runtimeType ==` which doesn't work with inheritance:

```dart
// Current code (line 307-313)
bool check(Type type) {
  if (iterator.isAtEnd) {
    return false;
  } else {
    return peek.runtimeType == type;
  }
}
```

If a token type is ever subclassed, `check()` will fail to match the subclass.

### Plan

1. Replace `runtimeType ==` with a type-safe approach
2. Options:
   - **Option A**: Use a switch/case on the type parameter (Dart 3 patterns)
   - **Option B**: Add a `TokenType` enum to tokens and compare that
   - **Option C**: Keep current approach but document the limitation

### Implementation (Option A - Recommended)

Since Dart doesn't allow `is` with a `Type` variable, and the current approach works for non-inherited tokens, the pragmatic fix is to document the limitation and ensure tokens are not subclassed.

Alternatively, refactor `match()` to use explicit type checks:

```dart
bool matchAny(List<bool Function(Token)> checks) {
  for (final check in checks) {
    if (!iterator.isAtEnd && check(peek)) {
      advance();
      return true;
    }
  }
  return false;
}

// Usage:
while (matchAny([(t) => t is NotEqualToken, (t) => t is EqualToken])) {
  ...
}
```

This is more verbose but type-safe. Evaluate trade-off before implementing.

---

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
} else if (match([OpenBracketToken])) {
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
    consume(CloseBracketToken, ']');
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

---

## Implementation Order

Recommended order based on severity and dependencies:

1. **Issue 1** (Bug) - Empty parameter lists - High priority, user-facing bug
2. **Issue 4** (UX) - Error messages - Improves debugging experience
3. **Issue 3** (Consistency) - Token type for `[]` - Simple fix, low risk
4. **Issue 2** (Robustness) - Type checking - Evaluate trade-offs first
5. **Issue 5** (Design) - Nullable expression - Optional, lower priority

---

## Testing Checklist

After implementing fixes, ensure these test cases pass:

- [ ] `foo() = 5` parses (empty parameter list with parens)
- [ ] `foo = 5` parses (nullary without parens)
- [ ] `foo(x, y, z) = x` parses (multiple parameters)
- [ ] `arr[0]` and `arr @ 0` produce identical AST structures
- [ ] Error messages are specific and helpful
- [ ] All existing tests still pass
