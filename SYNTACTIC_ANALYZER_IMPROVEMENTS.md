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
