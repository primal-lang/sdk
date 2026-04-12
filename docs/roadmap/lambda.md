# Lambda Functions

## Overview

Lambda functions are anonymous inline function expressions. They allow defining functions at the expression level without top-level declarations, primarily benefiting higher-order functions like `list.map`, `list.filter`, and `list.reduce`.

```primal
// Before: requires a separate named function
double(x) = x * 2
main() = list.map([1, 2, 3], double)  // [2, 4, 6]

// After: inline lambda
main() = list.map([1, 2, 3], (x) -> x * 2)  // [2, 4, 6]
```

## Pros

1. Reduces boilerplate: Eliminates the need to define single-use helper functions at the top level.
2. Improves locality: The transformation logic appears at the point of use, making code easier to read.
3. Enables closures: Lambdas can capture variables from their enclosing scope, enabling powerful patterns like partial application and function factories.
4. Aligns with functional style: A natural fit for expression-oriented, higher-order programming.
5. Educational value: Demonstrates lambda calculus concepts that are foundational to functional programming.

## Grammar

```
expression        → lambdaExpression
lambdaExpression  → "(" parameters? ")" "->" expression
                  / letExpression
parameters        → IDENTIFIER ( "," IDENTIFIER )*
```

Note: The `/` denotes prioritized choice (PEG-style), not BNF alternation. The parser uses lookahead to check if the token sequence matches `"(" (IDENTIFIER ("," IDENTIFIER)*)? ")" "->"`. If so, it parses a lambda; otherwise, it falls through to `letExpression`. This is not backtracking—the lookahead examines tokens without consuming them.

The `parameters?` makes the parameter list optional, allowing zero-parameter lambdas like `() -> 5`. When present, `parameters` requires at least one identifier. Single-parameter lambdas require parentheses: `(x) -> x + 1`, not `x -> x + 1`. Note that `()` alone (without `->`) is **not** a valid expression—the lookahead finds no `->` after `)`, so it falls through to `letExpression()` → ... → `primary()` where `()` fails as an empty grouped expression.

**Parser integration**: The grammar change inserts `lambdaExpression` at the top of the expression hierarchy. This works correctly with the existing parser because `expression()` is the universal entry point for all expression contexts:

```
BEFORE:  expression() → ifExpression() → equality() → ... → primary()
AFTER:   expression() → lambdaExpression() → letExpression() → ifExpression() → ... → primary()
```

When parsing sub-expressions (function arguments, list elements, map values, etc.), the parser always calls `expression()`. For example, in `finishCall()`:

```dart
do {
  arguments.add(expression());  // Calls expression() for each argument
} while (matchSingle(_isComma));
```

This means `list.map([1, 2, 3], (x) -> x * 2)` parses correctly:

1. Parse `list.map` as identifier
2. See `(`, enter `finishCall()`
3. Parse first argument `[1, 2, 3]`: `expression()` → ... → `primary()` → list
4. See `,`, continue
5. Parse second argument `(x) -> x * 2`: `expression()` → `lambdaExpression()` → **lambda detected!**

The lookahead in `lambdaExpression()` (via `_checkLambdaStart()`) determines whether to parse a lambda or fall through. Since `(` followed by identifiers and `->` is unambiguous, there is no conflict with grouped expressions in `primary()`—the lookahead resolves the ambiguity before any tokens are consumed.

**Precedence**: Lambda has the lowest precedence, binding more loosely than all other operators including `let` and `if`. This means `(x) -> x + 1` parses as `(x) -> (x + 1)`, and `(x) -> if (x > 0) x else 0` parses as `(x) -> (if (x > 0) x else 0)`.

**Associativity**: Right-associative. Nested lambdas parse naturally: `(x) -> (y) -> x + y` parses as `(x) -> ((y) -> (x + y))`.

**Position**: Lambda expressions can appear in any expression context:

- Function body (top-level expression after `=`)
- Within parentheses: `((x) -> x + 1)`
- As a list element: `[(x) -> x, (x) -> x + 1]`
- As a map value: `{"double": (x) -> x * 2}`
- As a function argument: `list.map([1, 2, 3], (x) -> x * 2)`
- In either branch of an `if` expression: `if (c) (x) -> x else (x) -> x + 1`
- In a `let` binding or body: `let f = (x) -> x * 2 in f(5)`
- As the callee of an immediate invocation: `((x) -> x + 1)(5)`

**Why immediate invocation needs double parentheses**: Because lambda has the lowest precedence and its body extends to the end of the expression, `(x) -> x + 1(5)` parses as `(x) -> (x + 1(5))`—the `(5)` becomes part of the lambda body, calling `1` as a function. The outer parentheses in `((x) -> x + 1)(5)` group the entire lambda as a single expression, then `(5)` calls that expression.

It cannot appear as an operand to binary operators without parentheses (e.g., `5 + (x) -> x` is a parse error). Note: `5 + ((x) -> x)` is syntactically valid but fails at runtime with `InvalidArgumentTypesError` because `+` does not accept `FunctionType` operands.

**Disambiguation**: After `(`, the parser must determine whether the content is a lambda parameter list or a grouped expression. The parser uses **multi-token lookahead** (not backtracking) to make this determination before consuming any tokens.

**Key insight**: Lambda parameter lists have a restricted form—zero or more comma-separated identifiers followed by `)` then `->`. A grouped expression can contain arbitrary expressions. We can distinguish these by scanning ahead without consuming.

**ListIterator extension**: Add a `peekAt()` method to `lib/utils/list_iterator.dart`:

```dart
/// Peeks at the token [offset] positions ahead without consuming.
/// Returns null if the offset is beyond the end of the list.
T? peekAt(int offset) {
  final int targetIndex = _index + offset;
  if (targetIndex < _list.length) {
    return _list[targetIndex];
  }
  return null;
}
```

**Parser predicates**: Add these static predicates to `ExpressionParser` (following the existing pattern at lines 12-43):

```dart
static bool _isArrow(Token token) => token is ArrowToken;
```

**Disambiguation helper**: Add this method to `ExpressionParser`:

```dart
/// Checks if the current position starts a lambda expression.
/// Uses lookahead only—does not consume any tokens.
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
    // Saw '(' ')' — check for '->'
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
      // End of parameter list — check for '->'
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

**Parsing strategy** (no backtracking required):

1. At `lambdaExpression()`, call `_checkLambdaStart()`
2. If it returns >= 0, we have a lambda—consume `(`, parameters, `)`, `->`, then parse body
3. If it returns -1, fall through to `letExpression()` (which eventually reaches `primary()` for grouped expressions)

The lookahead scan in `_checkLambdaStart()` examines tokens without consuming them. Only after the scan confirms a lambda pattern do we commit to parsing it. This is **not backtracking** because:

- We never consume tokens during the check phase
- We never need to "undo" any parsing state
- The iterator position remains unchanged until we commit

**Lambda parsing method**:

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

**Whitespace**: Not significant. Indentation in examples is purely for readability. These are equivalent:

```primal
// Multi-line (formatted for readability)
transform() = (x, y) ->
    let
        sum = x + y
    in
        sum * 2

// Single-line (compact)
transform() = (x, y) -> let sum = x + y in sum * 2
```

**Interaction with `if` and `let`**: The lambda body is a full expression, so `if` and `let` can appear without parentheses:

```primal
// if in body: parses as (x) -> (if (...) ... else ...)
(x) -> if (x > 0) x else -x

// let in body: parses as (x) -> (let ... in ...)
(x) -> let y = x * 2 in y + 1

// Both: let with if in body
(x) -> let abs = if (x < 0) -x else x in abs * 2
```

The `->` unambiguously marks the start of the body. Despite `-> if` or `-> let` appearing adjacent in the token stream, there is no syntactic ambiguity.

## Semantics

### Parameter Scope

Lambda parameters are visible only within the lambda body:

```primal
// x is only in scope within the lambda body
((x) -> x + 1)(5)  // 6
```

### No Self-Reference

Lambdas are anonymous and cannot reference themselves. Use named functions for recursion:

```primal
// ERROR: No way to refer to the lambda itself
bad() = (n) -> if (n == 0) 1 else n * ???(n - 1)

// Use a named function instead
factorial(n) = if (n == 0) 1 else n * factorial(n - 1)
```

### No Duplicate Parameters

Multiple parameters with the same name are an error:

```primal
// ERROR: x appears twice
bad() = (x, x) -> x
// → DuplicatedLambdaParameterError: Duplicated lambda parameter "x"
```

### No Shadowing

Lambda parameters cannot shadow function parameters, let bindings, or outer lambda parameters. This simplifies implementation and avoids confusion about which binding is referenced:

```primal
// ERROR: x shadows function parameter
bad(x) = (x) -> x + 1
// → ShadowedLambdaParameterError: Shadowed lambda parameter "x"

// ERROR: x shadows let binding
bad(n) = let x = 1 in (x) -> x + 1
// → ShadowedLambdaParameterError: Shadowed lambda parameter "x"

// ERROR: inner x shadows outer lambda parameter
bad() = (x) -> (x) -> x
// → ShadowedLambdaParameterError: Shadowed lambda parameter "x"
```

### Function Name Shadowing (Allowed)

Lambda parameters MAY shadow function names (both custom and standard library). This is consistent with existing parameter and let binding behavior:

```primal
// Valid: double shadows a user-defined function
double(x) = x * 2
((double) -> double + 1)(5)  // 6

// Valid: list.map shadows the standard library function
((list.map) -> list.map + 1)(5)  // 6
```

Note: Identifiers in Primal may contain dots (regex `[a-zA-Z][\w\.]*`), so `list.map` is a single identifier token, not method call syntax. When used as a lambda parameter, it shadows the standard library function of the same name. While technically valid, using dotted names as parameters is discouraged for readability.

### Closures

Lambdas capture **bound variables** (function parameters, let bindings, outer lambda parameters) by value at creation time:

```primal
multiplier(n) = (x) -> x * n
multiplier(2)(5)  // 10
multiplier(3)(5)  // 15
```

When `multiplier(2)` is called:

1. The lambda `(x) -> x * n` is evaluated in a scope where `n = 2`
2. The captured variable `n` is substituted with `2`
3. The resulting closure `(x) -> x * 2` is returned

Captured bound variables are resolved at lambda creation time, not call time:

```primal
// Captures happen when the lambda is created
maker(n) = (x) -> x + n
maker(10)(5)  // 15
// Even if there were a way to change n, the closure would still use 10
```

### Function References in Lambdas

**Function references are late-bound**, not captured by value. When a lambda body references a named function (custom or standard library), it lowers to a `FunctionReferenceTerm` that resolves through the shared `functions` map at reduce-time:

```primal
// In REPL:
double(x) = x * 2
f() = (x) -> double(x)        // double is a FunctionReferenceTerm, not captured
myLambda = f()

double(x) = x * 3             // Redefine double
myLambda()(5)                 // 15 (uses new definition, not 10)
```

This late-binding is **intentional** to support:

- Forward references (function A calls B before B is defined)
- Mutual recursion (A calls B, B calls A)
- REPL redefinition semantics

**Consequence**: Lambdas referencing named functions observe rename/delete/redefinition of those functions. This differs from the creation-time capture of bound variables.

### Evaluation Order

Lambda parameters are evaluated left-to-right when the lambda is called (call-by-value):

```primal
// Arguments evaluated: 10 then 3. Result: 7
((a, b) -> a - b)(10, 3)
```

### Higher-Order Behavior

Lambdas are first-class values and can be used anywhere a function is expected:

```primal
// Lambda as argument to higher-order function
list.map([1, 2, 3], (x) -> x * 2)  // [2, 4, 6]
list.filter([1, 2, 3, 4], (x) -> x > 2)  // [3, 4]
list.reduce([1, 2, 3], 0, (acc, x) -> acc + x)  // 6

// Lambda returning lambda (parameterized compose function)
compose(f, g) = (x) -> f(g(x))
compose((x) -> x + 1, (x) -> x * 2)(5)  // 11

// Lambda stored in collection (access via index)
list.map([5], [(x) -> x + 1, (x) -> x * 2][0])  // [6]

// Lambda in map (access via key)
{"double": (x) -> x * 2}["double"](5)  // 10

// Immediately invoked lambda
((x) -> x + 1)(5)  // 6

// Lambda returned from parameterized function
makeAdder(n) = (x) -> x + n
makeAdder(5)(10)  // 15
```

### Error Propagation

Errors during lambda invocation propagate immediately:

```primal
// Error propagates from lambda body
((x) -> x / 0)(5)  // → DivisionByZeroError

// Errors can be caught with try
try(((x) -> x / 0)(5), 0)  // returns 0
```

## Lexical Changes

One new token: `->` (arrow).

### Implementation

**1. Add token class** in `lib/compiler/lexical/token.dart`:

```dart
class ArrowToken extends Token<String> {
  ArrowToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}
```

**2. Update `MinusState`** in `lib/compiler/lexical/lexical_analyzer.dart`:

The existing `MinusState` handles the `-` character. Currently, after seeing `-`, it checks if the next character is an operator delimiter (`isOperatorDelimiter` in `string_extensions.dart`). The `>` character is **not** in the delimiter set—it's a binary operator character—so the current implementation throws `InvalidCharacterError` when encountering `->`.

Extend `MinusState` to check for `>` **before** the delimiter check, producing `ArrowToken` for the two-character sequence:

```dart
class MinusState extends State<Character, Lexeme> {
  const MinusState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value == '>') {
      // Consume '>' and emit ArrowToken
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

**Token table update**:

| State        | If next is | Token produced |
| ------------ | ---------- | -------------- |
| `MinusState` | `>`        | `ArrowToken`   |
| `MinusState` | delimiter  | `MinusToken`   |

## Error Conditions

**Notation convention**: This section uses exception class names (e.g., `DuplicatedLambdaParameterError`) for implementation reference. The actual user-visible messages include an `Error:` prefix (or `Warning:` for warnings). Lambda semantic errors follow the same pattern as existing semantic errors—no source location is attached. For example:

| Exception Class                                                 | User-Visible Message                                   |
| --------------------------------------------------------------- | ------------------------------------------------------ |
| `DuplicatedLambdaParameterError(parameter: 'x')`                | `Error: Duplicated lambda parameter "x"`               |
| `ShadowedLambdaParameterError(parameter: 'x', inFunction: 'f')` | `Error: Shadowed lambda parameter "x" in function "f"` |
| `UndefinedIdentifierError(identifier: 'y')`                     | `Error: Undefined identifier "y"`                      |
| `UnusedLambdaParameterWarning(parameter: 'x', inFunction: 'f')` | `Warning: Unused lambda parameter "x" in function "f"` |

**Parser entry point note**: `Compiler.expression()` calls `ExpressionParser.expression()` then checks for leftover tokens—if any remain, it throws `UnexpectedTokenError`. Invalid lambda-like syntax (e.g., `x -> x + 1`, `(x) x`, `5 + (x) -> x`) parses partially as a valid expression, leaving tokens unconsumed. The lookahead in `_checkLambdaStart()` returns -1 for non-lambda patterns, so they fall through to grouped expression or identifier parsing without consuming `->`. This means these cases produce `UnexpectedTokenError`, not `ExpectedTokenError` or `InvalidTokenError`.

| Error/Warning                    | Condition                                     | Phase    | Priority |
| -------------------------------- | --------------------------------------------- | -------- | -------- |
| `UnexpectedTokenError`           | Leftover tokens after expression (see above)  | Parsing  | —        |
| `DuplicatedLambdaParameterError` | Same parameter name appears twice in lambda   | Semantic | 1        |
| `ShadowedLambdaParameterError`   | Parameter shadows outer variable or parameter | Semantic | 2        |
| `UndefinedIdentifierError`       | Free variable in lambda body not in scope     | Semantic | 3        |
| `UnusedLambdaParameterWarning`   | Lambda parameter not used in body             | Semantic | —        |
| `InvalidArgumentCountError`      | Lambda called with wrong number of arguments  | Runtime  | —        |
| `InvalidArgumentTypesError`      | Type mismatch in lambda body during execution | Runtime  | —        |

**Error Priority**: For semantic errors on the same parameter, the error with the lowest priority number is thrown first. Duplicate detection is checked before shadowing.

**New Error Types**: The following error types must be added to `lib/compiler/errors/semantic_error.dart`:

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

**New Warning Type**: Add to `lib/compiler/warnings/semantic_warning.dart`:

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

**Why warn for lambda parameters but not let bindings?** Lambda parameters, like function parameters, are part of a callable's interface. An unused parameter suggests the signature may be wrong. Let bindings are internal computations; unused bindings are wasteful but don't affect the interface. This matches the existing behavior where function parameters have unused warnings but let bindings do not.

## Examples

### Valid

```primal
// Zero-parameter lambda (immediately invoked)
(() -> 42)()  // 42

// Single-parameter lambda (immediately invoked)
((x) -> x + 1)(5)  // 6

// Multi-parameter lambda (immediately invoked)
((x, y) -> x + y)(2, 3)  // 5

// With higher-order functions
list.map([1, 2, 3], (x) -> x * 2)  // [2, 4, 6]
list.filter([1, 2, 3, 4], (x) -> x > 2)  // [3, 4]
list.reduce([1, 2, 3], 0, (acc, x) -> acc + x)  // 6
list.sort([3, 1, 2], (a, b) -> a - b)  // [1, 2, 3]

// Closure capturing outer variable (parameterized function returning lambda)
multiplier(n) = (x) -> x * n
multiplier(2)(5)  // 10
multiplier(3)(5)  // 15

// Nested lambdas (parameterized compose function)
compose(f, g) = (x) -> f(g(x))
compose((x) -> x + 1, (x) -> x * 2)(5)  // 11 (5 * 2 + 1)

// Lambda in collection (inline, index returns lambda)
[(x) -> x + 1, (x) -> x * 2][0](5)  // 6

// Lambda in map (inline, key lookup returns lambda)
{"double": (x) -> x * 2}["double"](5)  // 10

// Immediately invoked lambda
((x) -> x + 1)(5)  // 6

// Lambda returning lambda
((x) -> (y) -> x + y)(3)(4)  // 7

// Lambda in conditional (parameterized function)
chooser(b) = if (b) (x) -> x + 1 else (x) -> x * 2
chooser(true)(5)  // 6
chooser(false)(5)  // 10

// Lambda with let in body (immediately invoked)
((x) -> let y = x * 2 in y + 1)(5)  // 11

// Lambda with if in body (immediately invoked)
((x) -> if (x < 0) -x else x)(-5)  // 5

// Multiple levels of capture (parameterized function)
outer(a) = (b) -> (c) -> a + b + c
outer(1)(2)(3)  // 6
```

### Invalid

Error annotations below show exception class names. Actual CLI/REPL output includes `Error:` prefix. Syntactic errors (e.g., `UnexpectedTokenError`) include token locations via `Token.toString()`. Semantic errors (e.g., `DuplicatedLambdaParameterError`) do not include source locations.

```primal
// ERROR: Missing parentheses around parameter
x -> x + 1
// → UnexpectedTokenError on '->'
// Parser sees 'x' as an identifier expression, then Compiler.expression()
// detects leftover tokens and throws UnexpectedTokenError. The arrow token is
// only recognized as part of lambda syntax immediately after ')' in '(params) ->'.

// ERROR: Duplicate parameter
(x, x) -> x + 1
// → DuplicatedLambdaParameterError

// ERROR: Shadows function parameter
bad(x) = (x) -> x + 1
// → ShadowedLambdaParameterError

// ERROR: Shadows let binding
bad(n) = let x = 1 in (x) -> x + 1
// → ShadowedLambdaParameterError

// ERROR: Shadows outer lambda parameter
bad() = (x) -> (x) -> x
// → ShadowedLambdaParameterError

// ERROR: Undefined variable in lambda body
(x) -> x + y
// → UndefinedIdentifierError

// ERROR: Wrong arity when calling lambda
((x, y) -> x + y)(1)
// → InvalidArgumentCountError: expected 2 arguments, got 1

// ERROR: Lambda as binary operand without parentheses
5 + (x) -> x
// → UnexpectedTokenError on '->'
// Parser sees '5 + (x)' as a complete expression (where (x) is a grouped
// identifier, not a lambda—no '->' follows ')' during lookahead). Then
// Compiler.expression() detects leftover '-> x' tokens and throws.
// Note: 5 + ((x) -> x) parses but fails at runtime (InvalidArgumentTypesError)
```

## Implementation Notes

### Runtime

The lambda is implemented via a `LambdaTerm` that extends `FunctionTerm`:

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
  Term reduce() => this;  // Lambdas are values; they don't reduce further

  // Why we override apply() instead of using FunctionTerm.apply():
  //
  // FunctionTerm.apply() uses: substitute(bindings).reduce()
  // CustomFunctionTerm.substitute() returns: term.substitute(bindings) [unwrapped body]
  // LambdaTerm.substitute() returns: LambdaTerm(..., body.substitute(bindings)) [preserves wrapper]
  //
  // If we used the base class pattern:
  //   1. substitute(bindings) → returns a LambdaTerm (wrapper preserved)
  //   2. reduce() on LambdaTerm → returns this (lambdas are values)
  //   3. Result: a LambdaTerm, NOT the evaluated body!
  //
  // So we must substitute directly into the body and reduce that result.
  // This is analogous to CustomFunctionTerm.apply() which also overrides
  // to add call-by-value argument evaluation.
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
          arguments.map((arg) => arg.reduce()).toList();

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
  // Lambda parameters are always untyped in source, so showing ": any" is noise.
  // Named functions print "f(x: Number)" but lambdas print "<lambda@1:1>(x)".
  @override
  String toString() =>
      '$name(${parameters.map((p) => p.name).join(', ')})';
}
```

**Printing format**: Lambdas print parameter names without types: `<lambda@1:1>(x, y)`. This differs from named functions which print `name(param: Type, ...)` because lambda parameters are always untyped in source—showing `: any` would be noise. The lambda name encodes source location for debugging.

````

### Lambda Bound Variable Term

Like `LetBoundVariableTerm`, lambda parameters need partial substitution semantics:

```dart
/// A reference to a lambda parameter within a lambda body.
///
/// Unlike [BoundVariableTerm] (for function parameters), this term supports
/// partial substitution—it returns itself when the name is not found in
/// bindings, allowing outer scope substitution to pass through without
/// affecting lambda parameter references.
class LambdaBoundVariableTerm extends Term {
  final String name;

  const LambdaBoundVariableTerm(this.name);

  @override
  Term substitute(Bindings bindings) =>
      bindings.data.containsKey(name) ? bindings.data[name]! : this;

  @override
  Term reduce() => this;  // Cannot reduce further; must be substituted first

  @override
  Type get type => const AnyType();

  @override
  String toString() => name;

  @override
  dynamic native() =>
      throw StateError('LambdaBoundVariableTerm "$name" was not substituted');
}
````

### Why Partial Substitution is Needed

Consider `multiplier(n) = (x) -> x * n`. When `multiplier(2)` is called:

1. `CustomFunctionTerm.apply([2])` creates bindings `{n: 2}`
2. Calls `substitute({n: 2})` on the `LambdaTerm` body
3. Inside the lambda body `x * n`:
   - `LambdaBoundVariableTerm("x").substitute({n: 2})` returns itself (partial)
   - `BoundVariableTerm("n").substitute({n: 2})` returns `2`
4. Result: `LambdaTerm` with body `x * 2`
5. When later called as `double(5)`:
   - `LambdaTerm.apply([5])` creates bindings `{x: 5}`
   - `substitute({x: 5})` on body `x * 2`
   - `LambdaBoundVariableTerm("x")` gets replaced with `5`
   - Result: `5 * 2` = `10`

**Why `LambdaTerm.apply()` substitutes into body directly**: Step 4 shows that `LambdaTerm.substitute()` preserves the lambda wrapper—this is essential for closures to work. But this means `LambdaTerm` cannot use the base `FunctionTerm.apply()` pattern of `substitute(bindings).reduce()`, because `reduce()` on a `LambdaTerm` returns itself (lambdas are values). Instead, `apply()` must substitute directly into the body and reduce that result.

### Semantic Analysis Algorithm

When processing a `LambdaExpression`:

1. Create a local set `lambdaParameters` to track parameter names (for duplicate detection)
2. For each parameter in order:
   - If the name is in `lambdaParameters`, throw `DuplicatedLambdaParameterError`
   - If the name is in `availableParameters` (outer scope), throw `ShadowedLambdaParameterError`
   - Add the name to `lambdaParameters`
3. Create extended scope: combine `availableParameters` with `lambdaParameters`
4. Create extended `lambdaParameterNames` set: combine existing with this lambda's parameters
5. Check the body expression against the extended scope, passing through the shared `usedLambdaParameters` set (do NOT create a local copy—usage must propagate across nested lambdas)
6. Emit `UnusedLambdaParameterWarning` for any parameters in `lambdaParameters` not in `usedLambdaParameters`
7. Return a `SemanticLambdaNode` with the parameters and checked body

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

  // Note: Unlike _checkLetExpression(), we don't need to snapshot
  // `originalOuterScope` here. Let expressions need it because bindings are
  // added to scope incrementally (so `let x = 1, x = 2` must throw
  // DuplicatedLetBindingError, not ShadowedLetBindingError). Lambda parameters
  // are just names—they aren't added to `availableParameters` during this loop,
  // only to `localLambdaParameters`. The duplicate check uses
  // `localLambdaParameters`; the shadow check uses the unchanged
  // `availableParameters`.

  // Check each parameter
  final List<String> checkedParameters = [];
  for (final String paramName in expression.parameters) {
    // Check for duplicate within this lambda (against earlier params)
    if (localLambdaParameters.contains(paramName)) {
      throw DuplicatedLambdaParameterError(
        parameter: paramName,
        inFunction: currentFunction,
      );
    }

    // Check for shadowing against outer scope (unchanged during this loop)
    if (availableParameters.contains(paramName)) {
      throw ShadowedLambdaParameterError(
        parameter: paramName,
        inFunction: currentFunction,
      );
    }

    localLambdaParameters.add(paramName);
    checkedParameters.add(paramName);
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

  // Check body with extended scope.
  // Note: usedLambdaParameters is NOT copied because lambda parameter usage
  // tracking must persist across nested lambdas. This mirrors how usedParameters
  // works for function parameters (see _checkLetExpression comment).
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

  // Warn about unused lambda parameters (only THIS lambda's parameters).
  // The shared usedLambdaParameters set contains all used lambda params
  // from this and nested scopes, so outer params used in inner lambdas
  // are correctly marked as used.
  for (final String paramName in localLambdaParameters) {
    if (!usedLambdaParameters.contains(paramName)) {
      warnings.add(
        UnusedLambdaParameterWarning(
          parameter: paramName,
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

**Cascading signature changes**: All helper methods must accept and propagate `lambdaParameterNames`. This parallels the `letBindingNames` pattern from the `let` specification. The following methods require signature updates to add `required Set<String> lambdaParameterNames`:

| Method                         | Change Required                                                                                               |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------- |
| `checkExpression()`            | Add `lambdaParameterNames`, `usedLambdaParameters`, `warnings`; propagate to all                              |
| `_checkListExpression()`       | Add parameters, propagate to element `checkExpression` calls                                                  |
| `_checkMapExpression()`        | Add parameters, propagate to key/value `checkExpression` calls                                                |
| `_checkIdentifierExpression()` | Add parameters, set `isLambdaParameter` flag, track usage in `usedLambdaParameters`                           |
| `_checkCallExpression()`       | Add parameters, propagate to callee and argument checks                                                       |
| `_checkCalleeIdentifier()`     | Add parameters, propagate to recursive calls                                                                  |
| `_checkLetExpression()`        | Add parameters, propagate to binding and body checks                                                          |
| `_checkLambdaExpression()`     | Extend scope with lambda params, propagate shared `usedLambdaParameters`, emit warnings for unused parameters |

Modify `_checkIdentifierExpression()` to distinguish lambda parameters and track usage:

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

**External callers**: `RuntimeFacade` must be updated to pass the new parameters in both `evaluateToTerm()` and `defineFunction()`:

```dart
// In RuntimeFacade.evaluateToTerm()
final List<SemanticWarning> warnings = [];
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
```

```dart
// In RuntimeFacade.defineFunction(), within the try block:
final List<SemanticWarning> warnings = [];
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
// After successful lowering (before method returns), print warnings:
for (final SemanticWarning warning in warnings) {
  stderr.writeln('Warning: ${warning.message}');
}
```

```dart
// In SemanticAnalyzer.analyze(), within the function processing loop:
// (This is the batch compilation path for .prm files)
final Set<String> usedLambdaParameters = {};  // NEW
final SemanticNode body = checkExpression(
  expression: function.expression,
  currentFunction: function.name,
  availableParameters: availableParameters,
  usedParameters: usedParameters,
  letBindingNames: {},
  lambdaParameterNames: {},         // NEW
  usedLambdaParameters: usedLambdaParameters,  // NEW
  warnings: warnings,               // Already exists in analyze()
  allSignatures: allSignatures,
);
// Note: warnings list already exists in analyze() and is returned in
// IntermediateRepresentation. No additional stderr printing needed here—
// warnings are collected and returned to the caller (Compiler) which
// prints them before execution.
```

**REPL warning behavior**: Warnings collected during `evaluateToTerm()` and `defineFunction()` should be printed to stderr immediately after successful evaluation, before displaying the result. This matches batch compilation behavior where warnings appear but do not prevent execution.

```dart
// In RuntimeFacade.evaluateToTerm(), after successful evaluation:
for (final SemanticWarning warning in warnings) {
  stderr.writeln('Warning: ${warning.message}');
}
return lowered.reduce();
```

Example REPL session:

```
> f() = (x) -> 5
Warning: Unused lambda parameter "x" in function "f"
> f()(10)
5
```

Note: Warnings are emitted once at definition time, not on each invocation. The lambda body is analyzed when `f` is defined, so the unused parameter warning appears then. Calling `f()(10)` produces no new warnings.

### Compiler Pipeline Impact

| Stage     | Changes                                                                                                                                                                              |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Lexical   | Add `ArrowToken` (`->`) in `MinusState`                                                                                                                                              |
| Syntactic | Add `LambdaExpression` AST node; add `_isArrow` predicate; parse parameters and body with disambiguation                                                                             |
| Semantic  | Add `lambdaParameterNames`, `usedLambdaParameters`, `warnings` parameters; check for duplicates, shadowing, and unused; add `isLambdaParameter` field to `SemanticBoundVariableNode` |
| Lowering  | Convert `SemanticLambdaNode` to `LambdaTerm`; map `SemanticBoundVariableNode` with `isLambdaParameter` to `LambdaBoundVariableTerm`                                                  |
| Runtime   | Add `LambdaTerm` extending `FunctionTerm` with `apply()`; add `LambdaBoundVariableTerm` with partial substitution semantics                                                          |

### New Node Types

**Syntactic (AST)**:

```
LambdaExpression
  parameters: List<String>
  body: Expression
  location: Location    // location of opening '('
```

**Semantic (IR)**:

```
SemanticLambdaNode
  parameters: List<String>
  body: SemanticNode
  location: Location    // propagated from LambdaExpression
```

**Modified existing node** (add field to `lib/compiler/semantic/semantic_node.dart`):

```dart
class SemanticBoundVariableNode extends SemanticNode {
  final String name;
  final bool isLetBinding;
  final bool isLambdaParameter;  // NEW

  const SemanticBoundVariableNode({
    required super.location,
    required this.name,
    this.isLetBinding = false,
    this.isLambdaParameter = false,  // Default false for backwards compatibility
  });

  @override
  String toString() => name;
}
```

**Runtime (Terms)**:

```
LambdaTerm extends FunctionTerm
  body: Term
  // Methods: substitute(), reduce(), apply(), native(), toString()

LambdaBoundVariableTerm
  name: String
  // Methods: substitute() (partial), reduce() (returns this), type (AnyType),
  //          native() (throws StateError), toString()
```

### Lowering Implementation

Modify the existing `SemanticBoundVariableNode` case and add the `SemanticLambdaNode` case in `lib/compiler/lowering/lowerer.dart`:

```dart
Term lowerTerm(SemanticNode semanticNode) => switch (semanticNode) {
  // ... existing cases ...

  // MODIFIED: distinguish lambda parameters from let bindings and function parameters
  SemanticBoundVariableNode() => semanticNode.isLambdaParameter
      ? LambdaBoundVariableTerm(semanticNode.name)
      : semanticNode.isLetBinding
          ? LetBoundVariableTerm(semanticNode.name)
          : BoundVariableTerm(semanticNode.name),

  // NEW: lower lambda expressions
  SemanticLambdaNode() => _lowerLambda(semanticNode),

  _ => throw StateError(
    'Unknown semantic node type: ${semanticNode.runtimeType}',
  ),
};

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

### Implementation Complexity

**High**

| Component         | Effort                                                                              |
| ----------------- | ----------------------------------------------------------------------------------- |
| Lexer             | Trivial - extend `MinusState` for `->` token                                        |
| Parser            | Moderate - disambiguation logic for `(params) ->` vs `(expr)`                       |
| AST               | Simple - one new node type                                                          |
| Semantic analyzer | Moderate - scope extension, shadowing check, `isLambdaParameter` field              |
| Lowerer           | Simple - conditional term selection based on `isLambdaParameter`                    |
| Runtime           | Moderate - new `LambdaTerm` and `LambdaBoundVariableTerm` with partial substitution |
| Tests             | Comprehensive coverage of closures, scoping, and error conditions                   |

### REPL Mode

Lambda expressions work in REPL mode the same as in program mode:

```
> ((x) -> x + 1)(5)
6
> f() = (x) -> x * 2
> f()(5)
10
> multiplier(n) = (x) -> x * n
> double() = multiplier(2)
> double()(5)
10
```

**Why `f()(5)` instead of `f(5)`?** In Primal, `name() = expression` always defines a **zero-parameter function**—there is no separate concept of "value binding" at the top level. When you write `f() = (x) -> x * 2`, you create a function `f` with zero parameters whose body is the lambda. To use it:

1. `f()` — invoke the zero-param function, returning the lambda
2. `(5)` — invoke the returned lambda with argument 5

This is consistent with Primal's "everything is a function" philosophy. For direct invocation without the extra `()`, use an immediately invoked lambda: `((x) -> x * 2)(5)`, or define a parameterized function: `f(x) = x * 2`.

### Post-Implementation

After implementing the feature:

1. **Update documentation** in `docs/`:

   | File                         | Section                                 | Change Required                                                            |
   | ---------------------------- | --------------------------------------- | -------------------------------------------------------------------------- |
   | `docs/primal.md`             | Syntax → Body                           | Add lambda expressions to the expression list                              |
   | `docs/reference/lambda.md`   | (new file)                              | Full lambda documentation with syntax, semantics, and examples             |
   | `docs/compiler/lexical.md`   | Two-Character Operators                 | Add `ArrowToken` (`->`)                                                    |
   | `docs/compiler/syntactic.md` | Grammar                                 | Add `lambdaExpression` rule                                                |
   | `docs/compiler/semantic.md`  | Semantic Checks → Identifier resolution | Add lambda parameter resolution and `isLambdaParameter` field              |
   | `docs/compiler/semantic.md`  | (new section)                           | Document `SemanticLambdaNode`, scope handling, and duplicate/shadow checks |
   | `docs/compiler/runtime.md`   | Function Terms                          | Add `LambdaTerm` extending `FunctionTerm`                                  |
   | `docs/compiler/runtime.md`   | Reference Terms                         | Add `LambdaBoundVariableTerm` with partial substitution semantics          |

2. **Implement tests** — see detailed test specification below

### Existing Test Suite Updates

Adding `SemanticLambdaNode`, `LambdaTerm`, and `LambdaBoundVariableTerm` affects existing test suites:

#### Signature Changes (Compilation Errors)

Tests that call `checkExpression()` directly must add `lambdaParameterNames: {}`:

| File                                        | Tests Affected                            | Required Change                                   |
| ------------------------------------------- | ----------------------------------------- | ------------------------------------------------- |
| `test/compiler/runtime_facade_test.dart`    | All `defineFunction` tests                | RuntimeFacade signature updated; tests compile OK |
| `test/compiler/semantic_analyzer_test.dart` | Direct `checkExpression()` calls (if any) | Add `lambdaParameterNames: {}` parameter          |

#### Lowerer Tests (Behavioral Changes)

Tests in `test/compiler/lowerer_expression_test.dart`:

| Existing Test                     | Impact               | Notes                                                          |
| --------------------------------- | -------------------- | -------------------------------------------------------------- |
| `SemanticBoundVariableNode` group | **No change needed** | Default `isLambdaParameter: false` preserves existing behavior |

New tests required for `isLambdaParameter: true` producing `LambdaBoundVariableTerm`.

#### Term Tests (Potential Impact)

| File                                          | Potential Impact                                                       |
| --------------------------------------------- | ---------------------------------------------------------------------- |
| `test/runtime/core/term_test.dart`            | May need new test group for `LambdaTerm` and `LambdaBoundVariableTerm` |
| Tests using exhaustive `switch` on term types | Add cases for new term types                                           |

### Test Specification

#### Lexical Tests

| Test                        | Input | Expected                                  |
| --------------------------- | ----- | ----------------------------------------- |
| `->` recognized             | `->`  | `ArrowToken`                              |
| `-` alone                   | `- `  | `MinusToken`                              |
| `->` after identifier       | `x->` | `IdentifierToken`, `ArrowToken`           |
| Negative number still works | `-5`  | `MinusToken`, `NumberToken` (or combined) |

#### Syntactic Tests

| Test                        | Input                         | Expected                                         |
| --------------------------- | ----------------------------- | ------------------------------------------------ |
| Zero-param lambda           | `() -> 5`                     | `LambdaExpression` with 0 params                 |
| Single-param lambda         | `(x) -> x`                    | `LambdaExpression` with 1 param                  |
| Multi-param lambda          | `(x, y) -> x + y`             | `LambdaExpression` with 2 params                 |
| Nested lambda (body)        | `(x) -> (y) -> x + y`         | Nested `LambdaExpression` in body                |
| Lambda with if body         | `(x) -> if (x > 0) x else -x` | `LambdaExpression` with `CallExpression` body    |
| Lambda with let body        | `(x) -> let y = x in y`       | `LambdaExpression` with `LetExpression` body     |
| Grouped expression          | `(x + y)`                     | Binary `CallExpression`, NOT lambda              |
| Grouped identifier          | `(x)`                         | `IdentifierExpression`, NOT lambda               |
| Immediately invoked         | `((x) -> x)(5)`               | `CallExpression` with `LambdaExpression` callee  |
| Missing arrow               | `(x) x`                       | `UnexpectedTokenError` on `x` (see note)         |
| Lambda as operand           | `1 + (x) -> x`                | `UnexpectedTokenError` on `->` (see note)        |
| Lambda in parens as operand | `1 + ((x) -> x)`              | Parses OK (runtime fails: `+` rejects functions) |
| Trailing comma in params    | `(x,) -> x`                   | `ExpectedTokenError` on `)` (expects identifier) |

**Note on error tests**: Tests expecting `UnexpectedTokenError` must use `Compiler.expression()` (not raw `ExpressionParser`) because the leftover-token check happens in `Compiler`. For `(x) x`, the parser sees `(x)` as a grouped identifier (lookahead finds no `->` after `)`), then `Compiler.expression()` throws on the leftover `x`. For `1 + (x) -> x`, the parser completes `1 + (x)` successfully, then throws on leftover `->`.

#### Semantic Tests

| Test                                | Input                                               | Expected                                                         |
| ----------------------------------- | --------------------------------------------------- | ---------------------------------------------------------------- |
| Valid zero-param                    | `f() = () -> 5`                                     | No errors                                                        |
| Valid single-param                  | `f() = (x) -> x + 1`                                | No errors                                                        |
| Valid multi-param                   | `f() = (x, y) -> x + y`                             | No errors                                                        |
| Duplicate parameter                 | `f() = (x, x) -> x`                                 | `DuplicatedLambdaParameterError`                                 |
| Shadows function parameter          | `f(x) = (x) -> x`                                   | `ShadowedLambdaParameterError`                                   |
| Shadows let binding                 | `f(n) = let x = 1 in (x) -> x`                      | `ShadowedLambdaParameterError`                                   |
| Shadows outer lambda parameter      | `f() = (x) -> (x) -> x`                             | `ShadowedLambdaParameterError`                                   |
| Let in body shadows lambda param    | `f() = (x) -> let x = 5 in x`                       | `ShadowedLetBindingError`                                        |
| Undefined variable in body          | `f() = (x) -> y`                                    | `UndefinedIdentifierError`                                       |
| Captures function parameter         | `f(n) = (x) -> x + n`                               | No errors, `n` is captured                                       |
| Captures let binding                | `f(n) = let m = 2 in (x) -> x * m`                  | No errors, `m` is captured                                       |
| `isLambdaParameter` set correctly   | `f() = (x) -> x`                                    | Body's `SemanticBoundVariableNode` has `isLambdaParameter: true` |
| Parameter `isLambdaParameter` false | `f(n) = n`                                          | `SemanticBoundVariableNode` has `isLambdaParameter: false`       |
| Shadows stdlib function             | `f() = (list.map) -> list.map`                      | No error, `list.map` resolves to parameter                       |
| Shadows custom function             | `double(x) = x * 2` then `f() = (double) -> double` | No error, `double` resolves to parameter                         |
| Unused lambda parameter             | `f() = (x) -> 5`                                    | `UnusedLambdaParameterWarning` for `x`                           |
| Multiple unused lambda parameters   | `f() = (x, y) -> 5`                                 | `UnusedLambdaParameterWarning` for `x` and `y`                   |
| Partially unused lambda parameters  | `f() = (x, y) -> x`                                 | `UnusedLambdaParameterWarning` for `y` only                      |
| No warning when all params used     | `f() = (x, y) -> x + y`                             | No warnings                                                      |
| Outer param used in nested lambda   | `f() = (x) -> (y) -> x + y`                         | No warnings (x is used in inner body)                            |

#### Lowering Tests

| Test                                     | Input                      | Expected                                                    |
| ---------------------------------------- | -------------------------- | ----------------------------------------------------------- |
| Lambda param → `LambdaBoundVariableTerm` | `(x) -> x`                 | Body contains `LambdaBoundVariableTerm("x")`                |
| Function param → `BoundVariableTerm`     | `f(n) = n`                 | Body contains `BoundVariableTerm("n")`                      |
| Let binding → `LetBoundVariableTerm`     | `let x = 1 in x`           | Body contains `LetBoundVariableTerm("x")`                   |
| Mixed lambda and capture                 | `f(n) = (x) -> x + n`      | `LambdaBoundVariableTerm("x")` and `BoundVariableTerm("n")` |
| Lambda name format                       | `(x) -> x` at row 1, col 1 | `LambdaTerm` with `name: '<lambda@1:1>'`                    |

#### Runtime Tests: LambdaBoundVariableTerm

| Test                             | Code                                              | Expected                   |
| -------------------------------- | ------------------------------------------------- | -------------------------- |
| Partial substitution (not found) | `LambdaBoundVariableTerm("x").substitute({y: 5})` | Returns `this` (unchanged) |
| Full substitution (found)        | `LambdaBoundVariableTerm("x").substitute({x: 5})` | Returns `NumberTerm(5)`    |
| Reduce returns this              | `LambdaBoundVariableTerm("x").reduce()`           | Returns `this` (unchanged) |
| Type is AnyType                  | `LambdaBoundVariableTerm("x").type`               | `AnyType`                  |
| Native throws if unsubstituted   | `LambdaBoundVariableTerm("x").native()`           | `StateError`               |
| toString returns name            | `LambdaBoundVariableTerm("x").toString()`         | `"x"`                      |

#### Runtime Tests: LambdaTerm (basic)

| Test                  | Code                                               | Expected            |
| --------------------- | -------------------------------------------------- | ------------------- |
| Type is FunctionType  | `LambdaTerm(...).type`                             | `FunctionType`      |
| Reduce returns this   | `LambdaTerm(...).reduce()`                         | Returns `this`      |
| Native returns string | `LambdaTerm(name: '<lambda@1:1>', ...).native()`   | `"<lambda@1:1>(x)"` |
| toString format       | `LambdaTerm(name: '<lambda@1:1>', [x]).toString()` | `"<lambda@1:1>(x)"` |

#### Runtime Tests: LambdaTerm.substitute()

| Test                        | Setup                        | Expected                                 |
| --------------------------- | ---------------------------- | ---------------------------------------- |
| Propagates through body     | `(x) -> x * y` with `{y: 5}` | Body becomes `x * 5`                     |
| Lambda param refs unchanged | `(x) -> x` with `{y: 5}`     | `LambdaBoundVariableTerm("x")` unchanged |
| Captures outer variable     | `(x) -> x + n` with `{n: 2}` | Body becomes `x + 2`                     |

#### Runtime Tests: LambdaTerm.apply()

| Test                    | Input                             | Expected                        |
| ----------------------- | --------------------------------- | ------------------------------- |
| Zero-param invocation   | `(() -> 5).apply([])`             | `NumberTerm(5)`                 |
| Single-param invocation | `((x) -> x + 1).apply([5])`       | `NumberTerm(6)`                 |
| Multi-param invocation  | `((x, y) -> x + y).apply([2, 3])` | `NumberTerm(5)`                 |
| Wrong arity (too few)   | `((x, y) -> x).apply([1])`        | `InvalidArgumentCountError`     |
| Wrong arity (too many)  | `((x) -> x).apply([1, 2])`        | `InvalidArgumentCountError`     |
| Arguments evaluated     | `((x) -> x).apply([1 + 1])`       | `NumberTerm(2)` (arg evaluated) |

#### Runtime Tests: Closures

| Test                        | Input                                             | Expected |
| --------------------------- | ------------------------------------------------- | -------- |
| Captures function param     | `f(n) = (x) -> x * n` then `f(2)(5)`              | `10`     |
| Captures let binding        | `f(n) = let m = 2 in (x) -> x * m` then `f(0)(5)` | `10`     |
| Captures outer lambda param | `((a) -> (b) -> a + b)(1)(2)`                     | `3`      |
| Multiple captures           | `f(a, b) = (x) -> a + b + x` then `f(1, 2)(3)`    | `6`      |

#### Runtime Tests: Error Propagation

| Test                       | Input                       | Expected                                                 |
| -------------------------- | --------------------------- | -------------------------------------------------------- |
| Error in lambda body       | `((x) -> x / 0)(5)`         | `DivisionByZeroError`                                    |
| `try` catches lambda error | `try(((x) -> x / 0)(5), 0)` | `0`                                                      |
| Lambda name in arity error | `((x, y) -> x)(1)` at [1,1] | `InvalidArgumentCountError` with function `<lambda@1:1>` |

#### Integration Tests

| Test                      | Input                                                            | Expected                    |
| ------------------------- | ---------------------------------------------------------------- | --------------------------- |
| `list.map` with lambda    | `list.map([1, 2, 3], (x) -> x * 2)`                              | `[2, 4, 6]`                 |
| `list.filter` with lambda | `list.filter([1, 2, 3, 4], (x) -> x > 2)`                        | `[3, 4]`                    |
| `list.reduce` with lambda | `list.reduce([1, 2, 3], 0, (acc, x) -> acc + x)`                 | `6`                         |
| `list.sort` with lambda   | `list.sort([3, 1, 2], (a, b) -> a - b)`                          | `[1, 2, 3]`                 |
| Lambda in list            | `[(x) -> x + 1, (x) -> x * 2][0](5)`                             | `6`                         |
| Lambda in map             | `{"inc": (x) -> x + 1}["inc"](5)`                                | `6`                         |
| Immediately invoked       | `((x) -> x + 1)(5)`                                              | `6`                         |
| Nested invocation         | `((x) -> (y) -> x + y)(1)(2)`                                    | `3`                         |
| Closure with multiplier   | `mult(n) = (x) -> x * n` then `mult(3)(4)`                       | `12`                        |
| Compose pattern           | `comp(f, g) = (x) -> f(g(x))` then `comp((x)->x+1, (x)->x*2)(3)` | `7`                         |
| Lambda with if body       | `((x) -> if (x > 0) x else -x)(-5)`                              | `5`                         |
| Lambda with let body      | `((x) -> let y = x * 2 in y + 1)(5)`                             | `11`                        |
| Lambda as + operand       | `1 + ((x) -> x)`                                                 | `InvalidArgumentTypesError` |

#### Printing Tests

These tests verify lambda printing format. Note: lambdas print without types (`<lambda@1:1>(x)`) while named functions print with types (`f(x: any)`).

| Test                    | Input                                    | Expected                           |
| ----------------------- | ---------------------------------------- | ---------------------------------- |
| Lambda alone            | `f() = (x) -> x` then `f()`              | `"<lambda@1:7>(x)"`                |
| Lambda in list          | `main() = [(x) -> x]`                    | `["<lambda@1:10>(x)"]`             |
| Mixed lambdas and named | `f(a) = a` then `main() = [f, (x) -> x]` | `["f(a: any)", "<lambda@...>(x)"]` |
| Multi-param lambda      | `f() = (a, b) -> a + b` then `f()`       | `"<lambda@1:7>(a, b)"`             |
| Zero-param lambda       | `f() = () -> 5` then `f()`               | `"<lambda@1:7>()"`                 |

#### REPL Tests

**Expression evaluation** (via `evaluateToTerm`):

| Test                 | Input                                | Expected                   |
| -------------------- | ------------------------------------ | -------------------------- |
| Immediate invocation | `((x) -> x + 1)(5)`                  | `6`                        |
| Store and call       | `f() = (x) -> x * 2` then `f()(5)`   | `10`                       |
| Closure              | `m(n) = (x) -> x * n` then `m(2)(5)` | `10`                       |
| With list.map        | `list.map([1, 2], (x) -> x + 1)`     | `[2, 3]`                   |
| Error in lambda      | `((x) -> y)(5)`                      | `UndefinedIdentifierError` |

**Function definition** (via `defineFunction`):

| Test                      | Definition then call                                       | Expected |
| ------------------------- | ---------------------------------------------------------- | -------- |
| Function returning lambda | `makeInc(n) = (x) -> x + n` then `makeInc(1)(5)`           | `6`      |
| Lambda as function body   | `double() = (x) -> x * 2` then `double()(5)`               | `10`     |
| Nested lambdas            | `f() = (a) -> (b) -> (c) -> a + b + c` then `f()(1)(2)(3)` | `6`      |

**Late-binding of function references** (verifies `FunctionReferenceTerm` behavior):

| Test                              | Steps                                                                                          | Expected                              |
| --------------------------------- | ---------------------------------------------------------------------------------------------- | ------------------------------------- |
| Lambda sees redefined function    | `double(x) = x * 2`, `f() = (x) -> double(x)`, `lam() = f()`, `double(x) = x * 3`, `lam()(5)`  | `15` (uses new definition)            |
| Lambda errors on deleted function | `helper(x) = x`, `f() = (x) -> helper(x)`, `lam() = f()`, delete `helper`, `lam()(5)`          | `NotFoundInScopeError`                |
| Bound variable still captured     | `make(n) = (x) -> x * n`, `lam() = make(2)`, redefine `make(n) = (x) -> x + n`, `lam()(5)`     | `10` (bound var captured, not late)   |
| Mixed capture and late-binding    | `mult(x) = x * 2`, `f(n) = (x) -> mult(n + x)`, `lam() = f(10)`, `mult(x) = x * 3`, `lam()(5)` | `45` (n=10 captured, mult late-bound) |
