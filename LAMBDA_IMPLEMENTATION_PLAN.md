# Lambda Functions Implementation Plan

This document provides a step-by-step implementation plan for adding lambda functions to Primal. Each phase builds on the previous one, with explicit dependencies noted.

**Specification**: `docs/roadmap/lambda.md`
**Complexity**: High
**Estimated Phases**: 7

---

## Phase 1: Lexical Analysis

**Dependencies**: None
**Files to modify**:

- `lib/compiler/lexical/token.dart`
- `lib/compiler/lexical/lexical_analyzer.dart`

### Step 1.1: Add ArrowToken class

**File**: `lib/compiler/lexical/token.dart`

Add after existing token classes (around line 90):

```dart
class ArrowToken extends Token<String> {
  ArrowToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}
```

### Step 1.2: Modify MinusState to recognize `->`

**File**: `lib/compiler/lexical/lexical_analyzer.dart`
**Location**: `MinusState` class (lines 559-571)

**Current implementation**:

```dart
class MinusState extends State<Character, Lexeme> {
  const MinusState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, MinusToken(output));
    } else {
      throw InvalidCharacterError(input);
    }
  }
}
```

**New implementation**:

```dart
class MinusState extends State<Character, Lexeme> {
  const MinusState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value == '>') {
      // Consume '>' and emit ArrowToken for '->'
      return ResultState(
        iterator,
        ArrowToken(output.add(input.value)),
      );
    } else if (input.value.isOperatorDelimiter) {
      iterator.back();
      return ResultState(iterator, MinusToken(output));
    } else {
      throw InvalidCharacterError(input);
    }
  }
}
```

### Step 1.3: Add lexer tests

**File**: `test/compiler/lexical_analyzer_test.dart`

Add test group for arrow token:

| Test                        | Input | Expected                        |
| --------------------------- | ----- | ------------------------------- |
| Arrow token recognized      | `->`  | `ArrowToken` with value `->`    |
| Minus still works           | `- `  | `MinusToken` with value `-`     |
| Arrow after identifier      | `x->` | `IdentifierToken`, `ArrowToken` |
| Negative number still works | `-5`  | `MinusToken`, `NumberToken`     |

---

## Phase 2: Parser Infrastructure

**Dependencies**: Phase 1 complete
**Files to modify**:

- `lib/utils/list_iterator.dart`
- `lib/compiler/syntactic/expression_parser.dart`
- `lib/compiler/syntactic/expression.dart`

### Step 2.1: Add `peekAt()` method to ListIterator

**File**: `lib/utils/list_iterator.dart`

Add this method to the `ListIterator` class:

```dart
/// Peeks at the element [offset] positions ahead without consuming.
/// Returns null if the offset is beyond the end of the list.
///
/// Unlike [peek] which only sees the current position, this method
/// enables multi-token lookahead for disambiguation (e.g., lambda vs
/// grouped expression).
T? peekAt(int offset) {
  final int targetIndex = _index + offset;
  if (targetIndex < _list.length) {
    return _list[targetIndex];
  }
  return null;
}
```

### Step 2.2: Add `_isArrow` predicate to ExpressionParser

**File**: `lib/compiler/syntactic/expression_parser.dart`
**Location**: After existing predicates (around line 43)

```dart
static bool _isArrow(Token token) => token is ArrowToken;
```

### Step 2.3: Create LambdaExpression AST node

**File**: `lib/compiler/syntactic/expression.dart`

Add new expression class:

```dart
class LambdaExpression extends Expression {
  final List<String> parameters;
  final Expression body;

  const LambdaExpression({
    required super.location,
    required this.parameters,
    required this.body,
  });

  @override
  String toString() =>
      '(${parameters.join(', ')}) -> $body';
}
```

### Step 2.4: Add ListIterator tests

**File**: `test/utils/list_iterator_test.dart`

| Test                    | Setup                  | Call                    | Expected      |
| ----------------------- | ---------------------- | ----------------------- | ------------- |
| peekAt(0) same as peek  | `[a, b, c]` at index 0 | `peekAt(0)`             | `a`           |
| peekAt(1) looks ahead   | `[a, b, c]` at index 0 | `peekAt(1)`             | `b`           |
| peekAt(2) looks further | `[a, b, c]` at index 0 | `peekAt(2)`             | `c`           |
| peekAt beyond end       | `[a, b, c]` at index 0 | `peekAt(3)`             | `null`        |
| peekAt from middle      | `[a, b, c]` at index 1 | `peekAt(1)`             | `c`           |
| peekAt doesn't consume  | `[a, b, c]` at index 0 | `peekAt(1)` then `peek` | `b`, then `a` |

---

## Phase 3: Parser Implementation

**Dependencies**: Phase 2 complete
**Files to modify**:

- `lib/compiler/syntactic/expression_parser.dart`

### Step 3.1: Add `_checkLambdaStart()` disambiguation method

**File**: `lib/compiler/syntactic/expression_parser.dart`

Add this method:

```dart
/// Checks if the current position starts a lambda expression.
/// Uses lookahead only - does not consume any tokens.
///
/// Returns the number of parameters if this is a lambda, or -1 if not.
/// This allows the caller to know how many identifiers to consume.
int _checkLambdaStart() {
  // Must start with '('
  if (!check(_isOpenParen)) {
    return -1;
  }

  int offset = 1; // Skip past '('
  int parameterCount = 0;

  // Check for zero-parameter lambda: () ->
  Token? token = iterator.peekAt(offset);
  if (token != null && _isCloseParen(token)) {
    // Saw '(' ')' - check for '->'
    Token? arrow = iterator.peekAt(offset + 1);
    if (arrow != null && _isArrow(arrow)) {
      return 0; // Zero-parameter lambda
    }
    return -1; // Just '()' without '->', not a lambda
  }

  // Check for one or more parameters: (id, id, ...) ->
  while (true) {
    token = iterator.peekAt(offset);
    if (token == null) {
      return -1; // Unexpected end
    }

    // Expect identifier
    if (!_isIdentifier(token)) {
      return -1; // Not an identifier, so not a lambda parameter list
    }
    parameterCount++;
    offset++;

    // After identifier, expect ',' or ')'
    token = iterator.peekAt(offset);
    if (token == null) {
      return -1;
    }

    if (_isCloseParen(token)) {
      // End of parameter list - check for '->'
      Token? arrow = iterator.peekAt(offset + 1);
      if (arrow != null && _isArrow(arrow)) {
        return parameterCount;
      }
      return -1; // ')' not followed by '->', not a lambda
    } else if (_isComma(token)) {
      offset++; // Skip comma, continue to next parameter
    } else {
      return -1; // Unexpected token in parameter list
    }
  }
}
```

### Step 3.2: Add `lambdaExpression()` parsing method

**File**: `lib/compiler/syntactic/expression_parser.dart`

Add this method:

```dart
Expression lambdaExpression() {
  final int parameterCount = _checkLambdaStart();

  if (parameterCount >= 0) {
    final Token openParen = advance(); // Consume '('
    final List<String> parameters = [];

    if (parameterCount > 0) {
      // Consume comma-separated identifiers
      do {
        final Token identifier = consume(_isIdentifier, 'identifier');
        parameters.add(identifier.value as String);
      } while (matchSingle(_isComma));
    }

    consume(_isCloseParen, ')');
    consume(_isArrow, '->');
    final Expression body = expression(); // Recursive: lambda body can contain lambdas

    return LambdaExpression(
      location: openParen.location,
      parameters: parameters,
      body: body,
    );
  } else {
    return letExpression();
  }
}
```

### Step 3.3: Update `expression()` to call `lambdaExpression()`

**File**: `lib/compiler/syntactic/expression_parser.dart`
**Location**: `expression()` method (around line 78)

**Current**:

```dart
Expression expression() => letExpression();
```

**New**:

```dart
Expression expression() => lambdaExpression();
```

### Step 3.4: Add parser tests

**File**: `test/compiler/expression_parser_test.dart`

| Test                            | Input                         | Expected                                        |
| ------------------------------- | ----------------------------- | ----------------------------------------------- |
| Zero-param lambda               | `() -> 5`                     | `LambdaExpression` with 0 params                |
| Single-param lambda             | `(x) -> x`                    | `LambdaExpression` with 1 param                 |
| Multi-param lambda              | `(x, y) -> x + y`             | `LambdaExpression` with 2 params                |
| Nested lambda (body)            | `(x) -> (y) -> x + y`         | Nested `LambdaExpression` in body               |
| Lambda with if body             | `(x) -> if (x > 0) x else -x` | `LambdaExpression` with `CallExpression` body   |
| Lambda with let body            | `(x) -> let y = x in y`       | `LambdaExpression` with `LetExpression` body    |
| Grouped expression (not lambda) | `(x + y)`                     | Binary `CallExpression`, NOT lambda             |
| Grouped identifier (not lambda) | `(x)`                         | `IdentifierExpression`, NOT lambda              |
| Immediately invoked             | `((x) -> x)(5)`               | `CallExpression` with `LambdaExpression` callee |

**Error tests** (use `Compiler.expression()` for leftover token detection):

| Test                | Input          | Expected Error                 |
| ------------------- | -------------- | ------------------------------ |
| Missing parentheses | `x -> x + 1`   | `UnexpectedTokenError` on `->` |
| Lambda as operand   | `1 + (x) -> x` | `UnexpectedTokenError` on `->` |
| Trailing comma      | `(x,) -> x`    | `ExpectedTokenError`           |

---

## Phase 4: Semantic Analysis

**Dependencies**: Phase 3 complete
**Files to modify**:

- `lib/compiler/errors/semantic_error.dart`
- `lib/compiler/warnings/semantic_warning.dart`
- `lib/compiler/semantic/semantic_node.dart`
- `lib/compiler/semantic/semantic_analyzer.dart`

### Step 4.1: Add new error classes

**File**: `lib/compiler/errors/semantic_error.dart`

```dart
class DuplicatedLambdaParameterError extends SemanticError {
  const DuplicatedLambdaParameterError({
    required String parameter,
    String? inFunction,
  }) : super(
         inFunction != null
             ? 'Duplicated lambda parameter "$parameter" in function "$inFunction"'
             : 'Duplicated lambda parameter "$parameter"',
       );
}

class ShadowedLambdaParameterError extends SemanticError {
  const ShadowedLambdaParameterError({
    required String parameter,
    String? inFunction,
  }) : super(
         inFunction != null
             ? 'Shadowed lambda parameter "$parameter" in function "$inFunction"'
             : 'Shadowed lambda parameter "$parameter"',
       );
}
```

### Step 4.2: Add new warning class

**File**: `lib/compiler/warnings/semantic_warning.dart`

```dart
class UnusedLambdaParameterWarning extends SemanticWarning {
  const UnusedLambdaParameterWarning({
    required String parameter,
    String? inFunction,
  }) : super(
         inFunction != null
             ? 'Unused lambda parameter "$parameter" in function "$inFunction"'
             : 'Unused lambda parameter "$parameter"',
       );
}
```

### Step 4.3: Add `isLambdaParameter` field to SemanticBoundVariableNode

**File**: `lib/compiler/semantic/semantic_node.dart`
**Location**: `SemanticBoundVariableNode` class (around line 108)

**Current**:

```dart
class SemanticBoundVariableNode extends SemanticNode {
  final String name;
  final bool isLetBinding;

  const SemanticBoundVariableNode({
    required super.location,
    required this.name,
    this.isLetBinding = false,
  });
```

**New**:

```dart
class SemanticBoundVariableNode extends SemanticNode {
  final String name;
  final bool isLetBinding;
  final bool isLambdaParameter;

  const SemanticBoundVariableNode({
    required super.location,
    required this.name,
    this.isLetBinding = false,
    this.isLambdaParameter = false,
  });
```

### Step 4.4: Add SemanticLambdaNode class

**File**: `lib/compiler/semantic/semantic_node.dart`

```dart
class SemanticLambdaNode extends SemanticNode {
  final List<String> parameters;
  final SemanticNode body;

  const SemanticLambdaNode({
    required super.location,
    required this.parameters,
    required this.body,
  });

  @override
  String toString() =>
      '(${parameters.join(', ')}) -> $body';
}
```

### Step 4.5: Refactor `checkExpression()` signature

**File**: `lib/compiler/semantic/semantic_analyzer.dart`

Update `checkExpression()` to add three new parameters:

```dart
SemanticNode checkExpression({
  required Expression expression,
  required String? currentFunction,
  required Set<String> availableParameters,
  required Set<String> usedParameters,
  required Set<String> letBindingNames,
  required Set<String> lambdaParameterNames,        // NEW
  required Set<String> usedLambdaParameters,        // NEW
  required List<SemanticWarning> warnings,          // NEW
  required Map<String, FunctionSignature> allSignatures,
})
```

### Step 4.6: Update all helper method signatures

Update signatures for ALL helper methods to include the three new parameters:

| Method                         | Location  |
| ------------------------------ | --------- |
| `_checkListExpression()`       | ~line 198 |
| `_checkMapExpression()`        | ~line 225 |
| `_checkIdentifierExpression()` | ~line 262 |
| `_checkCallExpression()`       | ~line 299 |
| `_checkCalleeIdentifier()`     | ~line 372 |
| `_checkLetExpression()`        | ~line 420 |

Each method must:

1. Accept the three new parameters
2. Propagate them to all nested `checkExpression()` calls

### Step 4.7: Modify `_checkIdentifierExpression()` for lambda parameters

**File**: `lib/compiler/semantic/semantic_analyzer.dart`

Update to track lambda parameter usage and set `isLambdaParameter` flag:

```dart
SemanticNode _checkIdentifierExpression({
  required IdentifierExpression expression,
  required String? currentFunction,
  required Set<String> availableParameters,
  required Set<String> usedParameters,
  required Set<String> letBindingNames,
  required Set<String> lambdaParameterNames,
  required Set<String> usedLambdaParameters,
  required Map<String, FunctionSignature> allSignatures,
}) {
  final String name = expression.value;

  if (availableParameters.contains(name)) {
    final bool isLetBinding = letBindingNames.contains(name);
    final bool isLambdaParameter = lambdaParameterNames.contains(name);

    // Track usage for function parameters and lambda parameters
    if (isLambdaParameter) {
      usedLambdaParameters.add(name);
    } else if (!isLetBinding) {
      usedParameters.add(name);
    }

    return SemanticBoundVariableNode(
      location: expression.location,
      name: name,
      isLetBinding: isLetBinding,
      isLambdaParameter: isLambdaParameter,
    );
  } else if (allSignatures.containsKey(name)) {
    // ... existing function reference handling
  } else {
    throw UndefinedIdentifierError(...);
  }
}
```

### Step 4.8: Add `_checkLambdaExpression()` method

**File**: `lib/compiler/semantic/semantic_analyzer.dart`

```dart
SemanticNode _checkLambdaExpression({
  required LambdaExpression expression,
  required String? currentFunction,
  required Set<String> availableParameters,
  required Set<String> usedParameters,
  required Set<String> letBindingNames,
  required Set<String> lambdaParameterNames,
  required Set<String> usedLambdaParameters,
  required List<SemanticWarning> warnings,
  required Map<String, FunctionSignature> allSignatures,
}) {
  // Track parameters for this lambda (duplicate detection)
  final Set<String> localLambdaParameters = {};

  // Check each parameter
  final List<String> checkedParameters = [];
  for (final String parameterName in expression.parameters) {
    // Check for duplicate within this lambda
    if (localLambdaParameters.contains(parameterName)) {
      throw DuplicatedLambdaParameterError(
        parameter: parameterName,
        inFunction: currentFunction,
      );
    }

    // Check for shadowing against outer scope
    if (availableParameters.contains(parameterName)) {
      throw ShadowedLambdaParameterError(
        parameter: parameterName,
        inFunction: currentFunction,
      );
    }

    localLambdaParameters.add(parameterName);
    checkedParameters.add(parameterName);
  }

  // Extend scope with lambda parameters
  final Set<String> extendedAvailableParameters = {
    ...availableParameters,
    ...localLambdaParameters,
  };
  final Set<String> extendedLambdaParameterNames = {
    ...lambdaParameterNames,
    ...localLambdaParameters,
  };

  // Check body with extended scope
  final SemanticNode checkedBody = checkExpression(
    expression: expression.body,
    currentFunction: currentFunction,
    availableParameters: extendedAvailableParameters,
    usedParameters: usedParameters,
    letBindingNames: letBindingNames,
    lambdaParameterNames: extendedLambdaParameterNames,
    usedLambdaParameters: usedLambdaParameters,
    warnings: warnings,
    allSignatures: allSignatures,
  );

  // Warn about unused lambda parameters
  for (final String parameterName in localLambdaParameters) {
    if (!usedLambdaParameters.contains(parameterName)) {
      warnings.add(
        UnusedLambdaParameterWarning(
          parameter: parameterName,
          inFunction: currentFunction,
        ),
      );
    }
  }

  return SemanticLambdaNode(
    parameters: checkedParameters,
    body: checkedBody,
    location: expression.location,
  );
}
```

### Step 4.9: Add LambdaExpression case to `checkExpression()` switch

**File**: `lib/compiler/semantic/semantic_analyzer.dart`

Add to the switch expression in `checkExpression()`:

```dart
LambdaExpression() => _checkLambdaExpression(
  expression: expression,
  currentFunction: currentFunction,
  availableParameters: availableParameters,
  usedParameters: usedParameters,
  letBindingNames: letBindingNames,
  lambdaParameterNames: lambdaParameterNames,
  usedLambdaParameters: usedLambdaParameters,
  warnings: warnings,
  allSignatures: allSignatures,
),
```

### Step 4.10: Update `analyze()` method

**File**: `lib/compiler/semantic/semantic_analyzer.dart`

Modify `analyze()` to thread warnings through `checkExpression()` instead of populating post-hoc.

### Step 4.11: Add semantic analysis tests

**File**: `test/compiler/semantic_analyzer_test.dart`

| Test                              | Input                              | Expected                           |
| --------------------------------- | ---------------------------------- | ---------------------------------- |
| Valid zero-param                  | `f() = () -> 5`                    | No errors                          |
| Valid single-param                | `f() = (x) -> x + 1`               | No errors                          |
| Valid multi-param                 | `f() = (x, y) -> x + y`            | No errors                          |
| Duplicate parameter               | `f() = (x, x) -> x`                | `DuplicatedLambdaParameterError`   |
| Shadows function parameter        | `f(x) = (x) -> x`                  | `ShadowedLambdaParameterError`     |
| Shadows let binding               | `f(n) = let x = 1 in (x) -> x`     | `ShadowedLambdaParameterError`     |
| Shadows outer lambda parameter    | `f() = (x) -> (x) -> x`            | `ShadowedLambdaParameterError`     |
| Let in body shadows lambda param  | `f() = (x) -> let x = 5 in x`      | `ShadowedLetBindingError`          |
| Undefined variable in body        | `f() = (x) -> y`                   | `UndefinedIdentifierError`         |
| Captures function parameter       | `f(n) = (x) -> x + n`              | No errors                          |
| Captures let binding              | `f(n) = let m = 2 in (x) -> x * m` | No errors                          |
| isLambdaParameter set correctly   | `f() = (x) -> x`                   | Body has `isLambdaParameter: true` |
| Unused lambda parameter           | `f() = (x) -> 5`                   | `UnusedLambdaParameterWarning`     |
| Outer param used in nested lambda | `f() = (x) -> (y) -> x + y`        | No warnings                        |

---

## Phase 5: Lowering

**Dependencies**: Phase 4 complete
**Files to modify**:

- `lib/compiler/lowering/lowerer.dart`

### Step 5.1: Modify SemanticBoundVariableNode case

**File**: `lib/compiler/lowering/lowerer.dart`

**Current**:

```dart
SemanticBoundVariableNode() =>
  semanticNode.isLetBinding
      ? LetBoundVariableTerm(semanticNode.name)
      : BoundVariableTerm(semanticNode.name),
```

**New**:

```dart
SemanticBoundVariableNode() => semanticNode.isLambdaParameter
    ? LambdaBoundVariableTerm(semanticNode.name)
    : semanticNode.isLetBinding
        ? LetBoundVariableTerm(semanticNode.name)
        : BoundVariableTerm(semanticNode.name),
```

### Step 5.2: Add SemanticLambdaNode case

**File**: `lib/compiler/lowering/lowerer.dart`

Add to switch expression:

```dart
SemanticLambdaNode() => _lowerLambda(semanticNode),
```

Add helper method:

```dart
Term _lowerLambda(SemanticLambdaNode semanticNode) {
  return LambdaTerm(
    name: '<lambda@${semanticNode.location.row}:${semanticNode.location.column}>',
    parameters: semanticNode.parameters
        .map((name) => Parameter.any(name))
        .toList(),
    body: lowerTerm(semanticNode.body),
  );
}
```

### Step 5.3: Add lowering tests

**File**: `test/compiler/lowerer_test.dart`

| Test                                            | Input                      | Expected                                                    |
| ----------------------------------------------- | -------------------------- | ----------------------------------------------------------- |
| Lambda param produces LambdaBoundVariableTerm   | `(x) -> x`                 | Body contains `LambdaBoundVariableTerm("x")`                |
| Function param still produces BoundVariableTerm | `f(n) = n`                 | Body contains `BoundVariableTerm("n")`                      |
| Let binding still produces LetBoundVariableTerm | `let x = 1 in x`           | Body contains `LetBoundVariableTerm("x")`                   |
| Mixed lambda and capture                        | `f(n) = (x) -> x + n`      | `LambdaBoundVariableTerm("x")` and `BoundVariableTerm("n")` |
| Lambda name format                              | `(x) -> x` at row 1, col 1 | `LambdaTerm` with `name: '<lambda@1:1>'`                    |

---

## Phase 6: Runtime

**Dependencies**: Phase 5 complete
**Files to modify**:

- `lib/compiler/runtime/term.dart`

### Step 6.1: Add LambdaBoundVariableTerm class

**File**: `lib/compiler/runtime/term.dart`

```dart
/// A reference to a lambda parameter within a lambda body.
///
/// Unlike [BoundVariableTerm] (for function parameters), this term supports
/// partial substitution - it returns itself when the name is not found in
/// bindings, allowing outer scope substitution to pass through without
/// affecting lambda parameter references.
class LambdaBoundVariableTerm extends Term {
  final String name;

  const LambdaBoundVariableTerm(this.name);

  @override
  Term substitute(Bindings bindings) =>
      bindings.data.containsKey(name) ? bindings.data[name]! : this;

  @override
  Term reduce() => this; // Cannot reduce further; must be substituted first

  @override
  Type get type => const AnyType();

  @override
  String toString() => name;

  @override
  dynamic native() =>
      throw StateError('LambdaBoundVariableTerm "$name" was not substituted');
}
```

### Step 6.2: Add LambdaTerm class

**File**: `lib/compiler/runtime/term.dart`

```dart
class LambdaTerm extends FunctionTerm {
  final Term body;

  const LambdaTerm({
    required String name,
    required List<Parameter> parameters,
    required this.body,
  }) : super(name: name, parameters: parameters);

  @override
  Term substitute(Bindings bindings) {
    // Propagate substitution through the body.
    // LambdaBoundVariableTerm references survive (partial substitution).
    // Other bound variables (captured from outer scope) get substituted.
    return LambdaTerm(
      name: name,
      parameters: parameters,
      body: body.substitute(bindings),
    );
  }

  @override
  Term reduce() => this; // Lambdas are values; they don't reduce further

  @override
  Term apply(List<Term> arguments) {
    if (arguments.length != parameters.length) {
      throw InvalidArgumentCountError(
        function: name,
        expected: parameters.length,
        actual: arguments.length,
      );
    }
    FunctionTerm.incrementDepth();
    try {
      // Evaluate arguments (call-by-value)
      final List<Term> evaluatedArguments =
          arguments.map((argument) => argument.reduce()).toList();

      // Create bindings and substitute into body
      final Bindings bindings = Bindings.from(
        parameters: parameters,
        arguments: evaluatedArguments,
      );
      final Term substituted = body.substitute(bindings);
      return substituted.reduce();
    } finally {
      FunctionTerm.decrementDepth();
    }
  }

  @override
  dynamic native() => toString();

  // Override to print parameter names only (no types).
  @override
  String toString() =>
      '$name(${parameters.map((parameter) => parameter.name).join(', ')})';
}
```

### Step 6.3: Add runtime tests

**File**: `test/compiler/runtime/term_test.dart`

**LambdaBoundVariableTerm tests**:

| Test                             | Code                                              | Expected                |
| -------------------------------- | ------------------------------------------------- | ----------------------- |
| Partial substitution (not found) | `LambdaBoundVariableTerm("x").substitute({y: 5})` | Returns `this`          |
| Full substitution (found)        | `LambdaBoundVariableTerm("x").substitute({x: 5})` | Returns `NumberTerm(5)` |
| Reduce returns this              | `LambdaBoundVariableTerm("x").reduce()`           | Returns `this`          |
| Type is AnyType                  | `LambdaBoundVariableTerm("x").type`               | `AnyType`               |
| Native throws if unsubstituted   | `LambdaBoundVariableTerm("x").native()`           | `StateError`            |

**LambdaTerm tests**:

| Test                    | Code                              | Expected                    |
| ----------------------- | --------------------------------- | --------------------------- |
| Type is FunctionType    | `LambdaTerm(...).type`            | `FunctionType`              |
| Reduce returns this     | `LambdaTerm(...).reduce()`        | Returns `this`              |
| Zero-param invocation   | `(() -> 5).apply([])`             | `NumberTerm(5)`             |
| Single-param invocation | `((x) -> x + 1).apply([5])`       | `NumberTerm(6)`             |
| Multi-param invocation  | `((x, y) -> x + y).apply([2, 3])` | `NumberTerm(5)`             |
| Wrong arity (too few)   | `((x, y) -> x).apply([1])`        | `InvalidArgumentCountError` |
| Wrong arity (too many)  | `((x) -> x).apply([1, 2])`        | `InvalidArgumentCountError` |

**Closure tests**:

| Test                        | Input                                             | Expected |
| --------------------------- | ------------------------------------------------- | -------- |
| Captures function param     | `f(n) = (x) -> x * n` then `f(2)(5)`              | `10`     |
| Captures let binding        | `f(n) = let m = 2 in (x) -> x * m` then `f(0)(5)` | `10`     |
| Captures outer lambda param | `((a) -> (b) -> a + b)(1)(2)`                     | `3`      |

---

## Phase 7: Integration

**Dependencies**: Phase 6 complete
**Files to modify**:

- `lib/compiler/lowering/runtime_facade.dart`

### Step 7.1: Update `evaluateToTerm()` for warning threading

**File**: `lib/compiler/lowering/runtime_facade.dart`

```dart
Term evaluateToTerm(Expression expression) {
  FunctionTerm.resetDepth();

  const SemanticAnalyzer analyzer = SemanticAnalyzer([]);
  final Lowerer lowerer = Lowerer(_runtimeInput.functions);

  final List<SemanticWarning> warnings = [];  // NEW

  final SemanticNode semanticNode = analyzer.checkExpression(
    expression: expression,
    currentFunction: null,
    availableParameters: {},
    usedParameters: {},
    letBindingNames: {},
    lambdaParameterNames: {},       // NEW
    usedLambdaParameters: {},       // NEW
    warnings: warnings,             // NEW
    allSignatures: _allSignatures,
  );

  final Term lowered = lowerer.lowerTerm(semanticNode);

  // Print warnings to stderr after successful analysis
  for (final SemanticWarning warning in warnings) {
    stderr.writeln('Warning: ${warning.message}');
  }

  return lowered.reduce();
}
```

### Step 7.2: Update `defineFunction()` for warning threading

**File**: `lib/compiler/lowering/runtime_facade.dart`

Update to pass new parameters and print warnings after success:

```dart
void defineFunction(FunctionDefinition definition) {
  // ... existing validation ...

  SemanticNode body;
  final List<SemanticWarning> warnings = [];  // NEW

  try {
    const SemanticAnalyzer analyzer = SemanticAnalyzer([]);
    final Set<String> usedParameters = {};
    body = analyzer.checkExpression(
      expression: definition.expression,
      currentFunction: name,
      availableParameters: definition.parameters.toSet(),
      usedParameters: usedParameters,
      letBindingNames: {},
      lambdaParameterNames: {},       // NEW
      usedLambdaParameters: {},       // NEW
      warnings: warnings,             // NEW
      allSignatures: _allSignatures,
    );
  } catch (error) {
    // ... existing error recovery ...
  }

  // ... existing lowering ...

  // Print warnings to stderr after successful lowering
  for (final SemanticWarning warning in warnings) {
    stderr.writeln('Warning: ${warning.message}');
  }
}
```

### Step 7.3: Add integration tests

**File**: `test/integration/lambda_test.dart`

| Test                       | Input                                                            | Expected                    |
| -------------------------- | ---------------------------------------------------------------- | --------------------------- |
| `list.map` with lambda     | `list.map([1, 2, 3], (x) -> x * 2)`                              | `[2, 4, 6]`                 |
| `list.filter` with lambda  | `list.filter([1, 2, 3, 4], (x) -> x > 2)`                        | `[3, 4]`                    |
| `list.reduce` with lambda  | `list.reduce([1, 2, 3], 0, (acc, x) -> acc + x)`                 | `6`                         |
| `list.sort` with lambda    | `list.sort([3, 1, 2], (a, b) -> a - b)`                          | `[1, 2, 3]`                 |
| Lambda in list             | `[(x) -> x + 1, (x) -> x * 2][0](5)`                             | `6`                         |
| Lambda in map              | `{"inc": (x) -> x + 1}["inc"](5)`                                | `6`                         |
| Immediately invoked        | `((x) -> x + 1)(5)`                                              | `6`                         |
| Nested invocation          | `((x) -> (y) -> x + y)(1)(2)`                                    | `3`                         |
| Closure with multiplier    | `mult(n) = (x) -> x * n` then `mult(3)(4)`                       | `12`                        |
| Compose pattern            | `comp(f, g) = (x) -> f(g(x))` then `comp((x)->x+1, (x)->x*2)(3)` | `7`                         |
| Lambda with if body        | `((x) -> if (x > 0) x else -x)(-5)`                              | `5`                         |
| Lambda with let body       | `((x) -> let y = x * 2 in y + 1)(5)`                             | `11`                        |
| Lambda as + operand        | `1 + ((x) -> x)`                                                 | `InvalidArgumentTypesError` |
| Error in lambda body       | `((x) -> x / 0)(5)`                                              | `DivisionByZeroError`       |
| `try` catches lambda error | `try(((x) -> x / 0)(5), 0)`                                      | `0`                         |

**REPL tests**:

| Test                          | Input                                | Expected |
| ----------------------------- | ------------------------------------ | -------- |
| Immediate invocation          | `((x) -> x + 1)(5)`                  | `6`      |
| Store and call                | `f() = (x) -> x * 2` then `f()(5)`   | `10`     |
| Closure                       | `m(n) = (x) -> x * n` then `m(2)(5)` | `10`     |
| Late-binding of function refs | See spec section 1459-1464           | Various  |

---

## Post-Implementation Checklist

After all phases complete:

1. [ ] Run full test suite: `dart test`
2. [ ] Run delta-review skill
3. [ ] Update documentation in `docs/`:
   - [ ] `docs/primal.md` - Add lambda to expression list
   - [ ] `docs/reference/lambda.md` - Create new reference page
   - [ ] `docs/compiler/lexical.md` - Add `ArrowToken`
   - [ ] `docs/compiler/syntactic.md` - Add `lambdaExpression` rule
   - [ ] `docs/compiler/semantic.md` - Add lambda analysis
   - [ ] `docs/compiler/runtime.md` - Add `LambdaTerm`, `LambdaBoundVariableTerm`
4. [ ] Remove or archive `docs/roadmap/lambda.md`
5. [ ] Verify REPL works with lambdas interactively
6. [ ] Verify batch compilation works with lambdas

---

## Summary

| Phase | Description           | Estimated Effort                       |
| ----- | --------------------- | -------------------------------------- |
| 1     | Lexical Analysis      | Low                                    |
| 2     | Parser Infrastructure | Low                                    |
| 3     | Parser Implementation | Medium                                 |
| 4     | Semantic Analysis     | **High** (cascading signature changes) |
| 5     | Lowering              | Low                                    |
| 6     | Runtime               | Medium                                 |
| 7     | Integration           | Low                                    |

**Total estimated effort**: High, primarily due to Phase 4's architectural refactoring.
