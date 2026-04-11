# Let Expression

## Overview

The `let` expression introduces local variable bindings within an expression body. This allows intermediate values to be named and reused, reducing duplication and improving readability.

```primal
distance(x1, y1, x2, y2) =
    let
        dx = x2 - x1,
        dy = y2 - y1
    in
        num.sqrt(dx * dx + dy * dy)
```

## Pros

1. Reduces duplication: Avoids repeating complex subexpressions, improving both readability and efficiency.
2. Aligns with functional style: A natural fit for expression-oriented, immutable languages.
3. Sequencing dependent computations: Multi-binding let expressions naturally express data dependencies.
4. Educational value: Teaches binding and scope concepts without introducing full lambda syntax.

## Grammar

```
expression     → letExpression
letExpression  → "let" bindings "in" expression | ifExpression
bindings       → binding ("," binding)*
binding        → IDENTIFIER "=" expression
```

Note: The `bindings` rule requires at least one binding. `let in x` is a parse error, not a valid empty binding list.

**Precedence**: `let` has the lowest precedence, binding more loosely than all other operators including `if`. This means `let x = 1 in x + 2` parses as `let x = 1 in (x + 2)`, and `let x = 1 in if (x > 0) x else 0` parses as `let x = 1 in (if (x > 0) x else 0)`.

**Associativity**: Right-associative. Chained `let` expressions nest naturally.

**Position**: `let` can appear at the start of any expression context:

- Function body (top-level expression after `=`)
- Within parentheses: `(let x = 1 in x)`
- As a list element: `[let x = 1 in x, 2]`
- As a map key or value: `{(let k = "a" in k): let v = 1 in v}`
- As a function argument: `foo(let x = 1 in x)`
- In either branch of an `if` expression: `if (c) let x = 1 in x else 0`
- In another `let` binding or body: `let x = let y = 1 in y in x`

It cannot appear as an operand to binary operators without parentheses (e.g., `1 + let x = 2 in x` is invalid; use `1 + (let x = 2 in x)`).

When `let` appears in an invalid position (e.g., as a binary operand), the parser's `primary()` method encounters a `LetToken` where it expects a literal, identifier, or grouping. This throws `InvalidTokenError`. For a more helpful error message, `primary()` can be extended to check for `LetToken` and throw a descriptive error:

```dart
// In primary(), before the final throw:
if (matchSingle(_isLet)) {
  throw ExpectedTokenError(
    previous,
    'parenthesized let expression',
  );
}
```

This produces: `Invalid token "let". Expected: parenthesized let expression`—consistent with existing error formatting. This is optional—`InvalidTokenError` is technically correct, but a specific message improves the developer experience.

**Whitespace**: Not significant. Indentation in examples is purely for readability. These are equivalent:

```primal
// Multi-line (formatted for readability)
foo(a, b) =
    let
        x = a + 1,
        y = b + 2
    in
        x + y

// Single-line (compact)
foo(a, b) = let x = a + 1, y = b + 2 in x + y
```

**Binding Separator**: Commas separate multiple bindings, consistent with Primal's syntax for function parameters, list elements, and map entries. No trailing comma after the last binding.

**Interaction with `if`**: Both binding values and the body are full expressions, so `if` expressions can appear in either position without parentheses:

```primal
// if in binding value: parses as let x = (if (...) ... else ...) in x
let x = if (n < 0) -n else n in x

// if in body: parses as let x = 1 in (if (...) ... else ...)
let x = 1 in if (x > 0) x else 0

// Both: if in binding AND body
let abs_n = if (n < 0) -n else n in if (abs_n > 100) "large" else "small"
```

The `in` keyword unambiguously separates the bindings from the body. Despite `in if` appearing adjacent in the token stream, there is no syntactic ambiguity.

## Semantics

### Binding Scope

Each binding is visible to all subsequent bindings and the body:

```primal
// Valid: y sees x
foo(a, b) =
    let
        x = a + 1,
        y = x * 2
    in
        x + y
```

### No Self-Reference

A binding cannot reference itself. This is not a recursive binding construct:

```primal
// ERROR: x references itself (no outer x exists)
bad(n) = let x = x + 1 in x
// → UndefinedIdentifierError: Undefined identifier "x"

// ERROR: shadowing is checked before the value expression
bad(x) = let x = x + 1 in x
// → ShadowedLetBindingError: Shadowed let binding "x"
// (the value expression x + 1 is never analyzed)
```

### No Duplicate Bindings

Multiple bindings with the same name in a single `let` are an error:

```primal
// ERROR: x bound twice
bad(n) = let x = 1, x = 2 in x
// → DuplicatedLetBindingError: Duplicated let binding "x"
```

### No Shadowing

Bindings cannot shadow function parameters or outer `let` bindings. This simplifies implementation and avoids confusion about which binding is referenced:

```primal
// ERROR: x shadows parameter
bad(x) = let x = 10 in x
// → ShadowedLetBindingError: Shadowed let binding "x"

// ERROR: inner x shadows outer x
bad(n) = let x = 1 in let x = 2 in x
// → ShadowedLetBindingError: Shadowed let binding "x"
```

### Evaluation Order

Bindings are evaluated sequentially in declaration order (call-by-value). Each binding is fully evaluated before the next:

```primal
foo(a) =
    let
        x = a + 1,      // evaluated first
        y = x * 2       // evaluated second, uses x
    in
        x + y           // evaluated last
```

### Error Propagation

Errors during binding evaluation propagate immediately:

```primal
// Error propagates from binding evaluation
let x = error.throw(0, "fail") in x  // throws CustomError("fail")

// Errors can be caught with try
try(let x = error.throw(0, "fail") in x, 0)  // returns 0
```

## Lexical Changes

Two new keywords: `let` and `in`.

### Implementation

**1. Add string extensions** in `lib/extensions/string_extensions.dart`:

```dart
bool get isLet => this == 'let';

bool get isIn => this == 'in';
```

**2. Add token classes** in `lib/compiler/lexical/token.dart`:

```dart
class LetToken extends Token<String> {
  LetToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class InToken extends Token<String> {
  InToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}
```

**3. Update keyword recognition** in `lib/compiler/lexical/lexical_analyzer.dart`:

```dart
Token _identifierOrKeywordToken(Lexeme lexeme) {
  if (lexeme.value.isBoolean) {
    return BooleanToken(lexeme);
  }
  if (lexeme.value.isIf) {
    return IfToken(lexeme);
  }
  if (lexeme.value.isElse) {
    return ElseToken(lexeme);
  }
  if (lexeme.value.isLet) {      // NEW
    return LetToken(lexeme);
  }
  if (lexeme.value.isIn) {       // NEW
    return InToken(lexeme);
  }
  // ... existing and/or/not handling ...
  return IdentifierToken(lexeme);
}
```

**Breaking change**: Existing identifiers named `let` or `in` become reserved keywords.

## Error Conditions

| Error                       | Condition                                      | Phase    | Priority |
| --------------------------- | ---------------------------------------------- | -------- | -------- |
| `ExpectedTokenError`        | No bindings provided (`let in x`)              | Parsing  | —        |
| `ExpectedTokenError(',')`   | Comma missing between bindings                 | Parsing  | —        |
| `ExpectedTokenError('in')`  | `in` keyword missing after bindings            | Parsing  | —        |
| `DuplicatedLetBindingError` | Same variable bound twice in one `let`         | Semantic | 1        |
| `ShadowedLetBindingError`   | Binding shadows a parameter or outer binding   | Semantic | 2        |
| `UndefinedIdentifierError`  | Binding references itself or an undefined name | Semantic | 3        |

**Error Priority**: For semantic errors, when multiple errors could apply to the same binding, the error with the lowest priority number is thrown first. Duplicate detection is checked before shadowing (to correctly identify intra-let duplicates), and both are checked before the value expression is analyzed. Parsing errors (`ExpectedTokenError`) are detected before semantic analysis runs.

**New Error Types**: The following error types must be added to `lib/compiler/errors/semantic_error.dart`:

```dart
class ShadowedLetBindingError extends SemanticError {
  const ShadowedLetBindingError({
    required String binding,
    String? inFunction,
  }) : super(
         inFunction != null
             ? 'Shadowed let binding "$binding" in function "$inFunction"'
             : 'Shadowed let binding "$binding"',
       );
}

class DuplicatedLetBindingError extends SemanticError {
  const DuplicatedLetBindingError({
    required String binding,
    String? inFunction,
  }) : super(
         inFunction != null
             ? 'Duplicated let binding "$binding" in function "$inFunction"'
             : 'Duplicated let binding "$binding"',
       );
}
```

**Note on error message format**: These error messages intentionally omit the function's parameter list, unlike `DuplicatedParameterError` which includes it (e.g., `'Duplicated parameter "x" in function "foo(x, x)"'`). The difference is intentional:

- `DuplicatedParameterError` shows the parameter list because the error _is about_ the function signature—seeing the duplicated parameters in context helps.
- Let binding errors are about bindings _inside_ the function body, not the signature. The parameter list would add noise without aiding diagnosis.

## Examples

### Valid

```primal
// Basic binding
double(n) = let x = n * 2 in x

// Multiple bindings with dependencies
sum_of_squares(a, b) =
    let
        a2 = a * a,
        b2 = b * b
    in
        a2 + b2

// Multiple bindings (single-line)
sum_of_squares(a, b) = let a2 = a * a, b2 = b * b in a2 + b2

// Nested let expressions
nested(n) =
    let
        x = n + 1
    in
        let
            y = x * 2
        in
            y + x

// let with if in body
classify(n) =
    let
        abs_n = if (n < 0) -n else n
    in
        if (abs_n > 100) "large" else "small"

// let in if branches
bounded(n, lo, hi) =
    if (n < lo)
        lo
    else
        let clamped = if (n > hi) hi else n in clamped

// let in list elements
pair(n) = [let x = n * 2 in x, let y = n * 3 in y]

// let as function argument
result(n) = num.abs(let x = n - 10 in x)

// let as operand (requires parentheses)
offset(a, b) = 1 + (let x = a * b in x)

// Chained single-binding lets (equivalent to nested)
chain(a, b) = let x = a + b in let y = x * 2 in y
```

### Invalid

```primal
// ERROR: Empty bindings (parser expects identifier after 'let')
bad0(n) = let in n
// → ExpectedTokenError: expected identifier

// ERROR: Duplicate binding
bad1(n) = let x = 1, x = 2 in x
// → DuplicatedLetBindingError: Duplicated let binding "x"

// ERROR: Self-reference
bad2(n) = let x = x + 1 in x
// → UndefinedIdentifierError: Undefined identifier "x"

// ERROR: Forward reference within same let
bad3(n) = let y = x, x = 1 in y
// → UndefinedIdentifierError: Undefined identifier "x"

// ERROR: Missing comma between bindings
bad4(n) = let x = 1 y = 2 in x + y
// → ExpectedTokenError: expected ','

// ERROR: Missing 'in'
bad5(n) = let x = 1, y = 2 x + y
// → ExpectedTokenError: expected 'in'

// ERROR: Shadows parameter
bad6(x) = let x = 1 in x
// → ShadowedLetBindingError: Shadowed let binding "x"

// ERROR: Shadows outer let binding
bad7(n) = let x = 1 in let x = 2 in x
// → ShadowedLetBindingError: Shadowed let binding "x"

// ERROR: Inner let binding not visible in outer scope
bad8(n) = let x = (let y = 1 in y) in y
// → UndefinedIdentifierError: Undefined identifier "y"
// (y is only in scope within the inner let body, not the outer let body)

// ERROR: Shadows earlier binding in same let
bad9(n) = let x = 1, y = 2, x = 3 in x
// → DuplicatedLetBindingError: Duplicated let binding "x"

// ERROR: let as binary operand (requires parentheses)
bad10(n) = 1 + let x = 2 in x
// → InvalidTokenError (or descriptive error if enhanced)
// Use: 1 + (let x = 2 in x)
```

## Implementation Notes

### Runtime

The `let` expression is implemented via a `LetTerm` in the runtime that performs sequential binding and substitution:

1. Evaluate each binding value in declaration order
2. After each evaluation, add the binding to the substitution map
3. Each subsequent binding's term is substituted with all previous bindings before evaluation
4. Finally, substitute all bindings into the body and reduce

```dart
class LetTerm extends Term {
  final List<(String, Term)> bindings;
  final Term body;

  const LetTerm({
    required this.bindings,
    required this.body,
  });

  @override
  Type get type => const AnyType();

  @override
  Term substitute(Bindings bindings) {
    // Since shadowing is disallowed, no let binding name can conflict with
    // incoming bindings. Simply propagate substitutions through.
    return LetTerm(
      bindings: this.bindings.map((b) => (b.$1, b.$2.substitute(bindings))).toList(),
      body: body.substitute(bindings),
    );
  }

  @override
  Term reduce() {
    // Build binding map incrementally. We use Bindings(map) directly instead
    // of Bindings.from() because:
    // 1. Bindings.from() takes List<Parameter> + List<Term> for function calls
    // 2. Here we build the map incrementally as each binding is evaluated
    // 3. Each binding must see only previously evaluated bindings, not all
    Map<String, Term> bindingMap = {};
    for (final (name, term) in bindings) {
      // Create a snapshot of current bindings for substitution.
      // This ensures each binding only sees previously evaluated bindings.
      final Term substituted = term.substitute(Bindings(Map.of(bindingMap)));
      final Term value = substituted.reduce();
      bindingMap[name] = value;
    }
    return body.substitute(Bindings(bindingMap)).reduce();
  }

  @override
  dynamic native() => reduce().native();

  @override
  String toString() {
    final String bindingStr = bindings.map((b) => '${b.$1} = ${b.$2}').join(', ');
    return 'let $bindingStr in $body';
  }
}
```

Since shadowing is disallowed at the semantic level, the `substitute()` method does not need capture-avoiding logic—no let binding name can ever conflict with an incoming substitution.

This is semantically equivalent to nested immediately-applied functions, but implemented directly without synthesizing intermediate function terms.

### Partial Substitution Requirement

The existing `BoundVariableTerm.substitute()` throws `NotFoundInScopeError` if the variable name is not in the bindings map. This works for function parameters (which are always fully substituted during function application), but causes a problem with let bindings.

Consider `foo(y) = let x = 1 in x + y`. When `foo(5)` is called:

1. `CustomFunctionTerm.apply([5])` creates bindings `{y: 5}`
2. Calls `substitute({y: 5})` on the LetTerm body
3. `LetTerm.substitute()` propagates into body: `x + y`
4. `BoundVariableTerm("x").substitute({y: 5})` — **throws** because `x` is not in `{y: 5}`

The problem: function parameter substitution traverses the entire body, including references to let bindings that should NOT be substituted yet.

**Solution**: Introduce `LetBoundVariableTerm` with partial substitution semantics:

```dart
/// A reference to a let-bound variable within a let expression body.
///
/// Unlike [BoundVariableTerm] (for function parameters), this term supports
/// partial substitution—it returns itself when the name is not found in
/// bindings, allowing function parameter substitution to pass through
/// without affecting let binding references.
class LetBoundVariableTerm extends Term {
  final String name;

  const LetBoundVariableTerm(this.name);

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
      throw StateError('LetBoundVariableTerm "$name" was not substituted');
}
```

This preserves the strict behavior of `BoundVariableTerm` for function parameters (catching bugs early) while allowing let binding references to survive function parameter substitution until `LetTerm.reduce()` processes them.

### Semantic Analysis Algorithm

When processing a `LetExpression`:

1. Save the original `availableParameters` for shadowing checks (before any names from this `let` are added)
2. Create a local set `localLetBindings` to track names bound in this `let` (for duplicate detection)
3. For each binding in order:
   - If the name is in `localLetBindings`, throw `DuplicatedLetBindingError`
   - If the name is in the _original_ `availableParameters`, throw `ShadowedLetBindingError`
   - Check the binding's value expression against the current `availableParameters`
   - Add the name to `localLetBindings`
   - Add the name to `availableParameters` (for subsequent bindings and the body)
   - Add the name to `letBindingNames` (for `isLetBinding` tracking)
4. Check the body expression against the extended `availableParameters`
5. Return a `SemanticLetNode` with the checked bindings and body

Note: The parser guarantees at least one binding exists (grammar: `bindings → binding ("," binding)*`), so the semantic analyzer does not need to check for empty bindings.

**Error Priority**: Duplicate detection is checked before shadowing. This ensures `let x = 1, x = 2 in x` correctly throws `DuplicatedLetBindingError` (not `ShadowedLetBindingError`). Shadowing is only checked against the _original_ outer scope—names added by earlier bindings in the same `let` are not considered shadowing targets. Both checks occur before the value expression is analyzed, so if a binding name is a duplicate AND the value references itself, the duplicate error is thrown first.

**usedParameters Tracking**: The existing `usedParameters` set tracks which function parameters are referenced. Let bindings are added to `availableParameters` but are NOT function parameters and should NOT be added to `usedParameters`.

To distinguish parameters from let bindings, add a new `letBindingNames` parameter to `checkExpression()`:

```dart
SemanticNode checkExpression({
  required Expression expression,
  required String? currentFunction,
  required Set<String> availableParameters,
  required Set<String> usedParameters,
  required Set<String> letBindingNames,  // NEW: tracks let binding names in scope
  required Map<String, FunctionSignature> allSignatures,
})
```

**Cascading signature changes**: All helper methods that call `checkExpression()` must also accept and propagate `letBindingNames`. Update the following methods to add the parameter and pass it through:

```dart
// _checkListExpression: propagate through element checks
SemanticNode _checkListExpression({
  required ListExpression expression,
  required String? currentFunction,
  required Set<String> availableParameters,
  required Set<String> usedParameters,
  required Set<String> letBindingNames,  // NEW
  required Map<String, FunctionSignature> allSignatures,
}) {
  final List<SemanticNode> elements = expression.value
      .map(
        (e) => checkExpression(
          expression: e,
          currentFunction: currentFunction,
          availableParameters: availableParameters,
          usedParameters: usedParameters,
          letBindingNames: letBindingNames,  // PROPAGATE
          allSignatures: allSignatures,
        ),
      )
      .toList();
  // ... rest unchanged
}

// _checkMapExpression: propagate through key and value checks
SemanticNode _checkMapExpression({
  required MapExpression expression,
  required String? currentFunction,
  required Set<String> availableParameters,
  required Set<String> usedParameters,
  required Set<String> letBindingNames,  // NEW
  required Map<String, FunctionSignature> allSignatures,
}) {
  final List<SemanticMapEntryNode> entries = expression.value
      .map(
        (e) => SemanticMapEntryNode(
          key: checkExpression(
            expression: e.key,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            letBindingNames: letBindingNames,  // PROPAGATE
            allSignatures: allSignatures,
          ),
          value: checkExpression(
            expression: e.value,
            currentFunction: currentFunction,
            availableParameters: availableParameters,
            usedParameters: usedParameters,
            letBindingNames: letBindingNames,  // PROPAGATE
            allSignatures: allSignatures,
          ),
        ),
      )
      .toList();
  // ... rest unchanged
}

// _checkCallExpression: propagate through argument and callee checks
SemanticNode _checkCallExpression({
  required CallExpression expression,
  required String? currentFunction,
  required Set<String> availableParameters,
  required Set<String> usedParameters,
  required Set<String> letBindingNames,  // NEW
  required Map<String, FunctionSignature> allSignatures,
}) {
  final List<SemanticNode> checkedArguments = expression.arguments
      .map(
        (argument) => checkExpression(
          expression: argument,
          currentFunction: currentFunction,
          availableParameters: availableParameters,
          usedParameters: usedParameters,
          letBindingNames: letBindingNames,  // PROPAGATE
          allSignatures: allSignatures,
        ),
      )
      .toList();

  // ... non-callable and non-indexable checks unchanged ...

  SemanticNode callee;
  if (expression.callee is IdentifierExpression) {
    callee = _checkCalleeIdentifier(
      expression: expression,
      callee: expression.callee as IdentifierExpression,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      letBindingNames: letBindingNames,  // PROPAGATE
      allSignatures: allSignatures,
    );
  } else {
    callee = checkExpression(
      expression: expression.callee,
      currentFunction: currentFunction,
      availableParameters: availableParameters,
      usedParameters: usedParameters,
      letBindingNames: letBindingNames,  // PROPAGATE
      allSignatures: allSignatures,
    );
  }
  // ... rest unchanged
}

// _checkCalleeIdentifier: propagate for higher-order function support
SemanticNode _checkCalleeIdentifier({
  required CallExpression expression,
  required IdentifierExpression callee,
  required String? currentFunction,
  required Set<String> availableParameters,
  required Set<String> usedParameters,
  required Set<String> letBindingNames,  // NEW
  required Map<String, FunctionSignature> allSignatures,
}) {
  final String functionName = callee.value;

  if (availableParameters.contains(functionName)) {
    final bool isLetBinding = letBindingNames.contains(functionName);  // CHECK
    if (!isLetBinding) {
      usedParameters.add(functionName);
    }
    return SemanticBoundVariableNode(
      location: callee.location,
      name: functionName,
      isLetBinding: isLetBinding,  // SET
    );
  }
  // ... rest unchanged
}
```

Modify `_checkIdentifierExpression()` to track usage and set `isLetBinding`:

```dart
SemanticNode _checkIdentifierExpression({
  required IdentifierExpression expression,
  required String? currentFunction,
  required Set<String> availableParameters,
  required Set<String> usedParameters,
  required Set<String> letBindingNames,  // NEW
  required Map<String, FunctionSignature> allSignatures,
}) {
  final String name = expression.value;

  if (availableParameters.contains(name)) {
    final bool isLetBinding = letBindingNames.contains(name);

    // Only track usage for function parameters, not let bindings
    if (!isLetBinding) {
      usedParameters.add(name);
    }

    return SemanticBoundVariableNode(
      location: expression.location,
      name: name,
      isLetBinding: isLetBinding,  // NEW: used by lowerer to choose term type
    );
  } else if (allSignatures.containsKey(name)) {
    // ... existing function reference handling
  } else {
    throw UndefinedIdentifierError(...);
  }
}
```

**Add new case to `checkExpression()` switch**: Handle `LetExpression` by delegating to a new `_checkLetExpression()` method:

```dart
SemanticNode checkExpression({...}) => switch (expression) {
  BooleanExpression() => SemanticBooleanNode(...),
  NumberExpression() => SemanticNumberNode(...),
  StringExpression() => SemanticStringNode(...),
  ListExpression() => _checkListExpression(..., letBindingNames: letBindingNames),
  MapExpression() => _checkMapExpression(..., letBindingNames: letBindingNames),
  IdentifierExpression() => _checkIdentifierExpression(..., letBindingNames: letBindingNames),
  CallExpression() => _checkCallExpression(..., letBindingNames: letBindingNames),
  LetExpression() => _checkLetExpression(  // NEW CASE
    expression: expression,
    currentFunction: currentFunction,
    availableParameters: availableParameters,
    usedParameters: usedParameters,
    letBindingNames: letBindingNames,
    allSignatures: allSignatures,
  ),
  _ => throw StateError(...),
};
```

**Add `_checkLetExpression()` method**: This implements the semantic analysis algorithm for let expressions:

```dart
SemanticNode _checkLetExpression({
  required LetExpression expression,
  required String? currentFunction,
  required Set<String> availableParameters,
  required Set<String> usedParameters,
  required Set<String> letBindingNames,
  required Map<String, FunctionSignature> allSignatures,
}) {
  // Save the original outer scope for shadowing checks. This is the scope
  // BEFORE any names from this let are added. This ensures that
  // `let x = 1, x = 2 in x` correctly throws DuplicatedLetBindingError
  // (not ShadowedLetBindingError).
  final Set<String> originalOuterScope = Set.of(availableParameters);

  // Create working copies to avoid polluting outer scope when we return.
  // This ensures `let x = 1 in (let y = 2 in y) + y` correctly errors on
  // the final `y` (which is outside the inner let's scope).
  // Note: usedParameters is NOT copied because parameter usage tracking
  // must persist across all scopes within a function.
  final Set<String> scopedAvailableParameters = Set.of(availableParameters);
  final Set<String> scopedLetBindingNames = Set.of(letBindingNames);

  // Create local tracking set for this let's bindings (duplicate detection)
  final Set<String> localLetBindings = {};

  // Process each binding
  final List<SemanticLetBindingNode> checkedBindings = [];
  for (final LetBindingExpression binding in expression.bindings) {
    final String name = binding.name;

    // Check for duplicate within this let FIRST
    // This ensures `let x = 1, x = 2 in x` throws DuplicatedLetBindingError
    if (localLetBindings.contains(name)) {
      throw DuplicatedLetBindingError(
        binding: name,
        inFunction: currentFunction,
      );
    }

    // Check for shadowing against the ORIGINAL outer scope (not including
    // names added by earlier bindings in this let)
    if (originalOuterScope.contains(name)) {
      throw ShadowedLetBindingError(
        binding: name,
        inFunction: currentFunction,
      );
    }

    // Check the binding's value expression (before adding name to scope)
    final SemanticNode checkedValue = checkExpression(
      expression: binding.value,
      currentFunction: currentFunction,
      availableParameters: scopedAvailableParameters,
      usedParameters: usedParameters,
      letBindingNames: scopedLetBindingNames,
      allSignatures: allSignatures,
    );

    // Add to tracking sets for subsequent bindings
    localLetBindings.add(name);
    scopedAvailableParameters.add(name);
    scopedLetBindingNames.add(name);

    checkedBindings.add(SemanticLetBindingNode(
      name: name,
      value: checkedValue,
      location: binding.location,
    ));
  }

  // Check the body with extended scope
  final SemanticNode checkedBody = checkExpression(
    expression: expression.body,
    currentFunction: currentFunction,
    availableParameters: scopedAvailableParameters,
    usedParameters: usedParameters,
    letBindingNames: scopedLetBindingNames,
    allSignatures: allSignatures,
  );

  // When this method returns, the scoped sets are discarded, so the outer
  // scope's availableParameters and letBindingNames remain unchanged.

  return SemanticLetNode(
    bindings: checkedBindings,
    body: checkedBody,
    location: expression.location,
  );
}
```

When processing a `LetExpression`, the `letBindingNames` set is extended with each binding name before recursing into subsequent bindings and the body. The initial call from `analyze()` passes an empty set:

```dart
final SemanticNode body = checkExpression(
  expression: function.expression,
  currentFunction: function.name,
  availableParameters: availableParameters,
  usedParameters: usedParameters,
  letBindingNames: {},  // Empty at function level
  allSignatures: allSignatures,
);
```

**External callers**: `RuntimeFacade` also calls `checkExpression()` directly in two places and must be updated to pass `letBindingNames: {}`:

```dart
// In RuntimeFacade.evaluateToTerm() (lib/compiler/lowering/runtime_facade.dart)
final SemanticNode semanticNode = analyzer.checkExpression(
  expression: expression,
  currentFunction: null,
  availableParameters: {},
  usedParameters: {},
  letBindingNames: {},  // NEW: empty set for top-level expressions
  allSignatures: _allSignatures,
);

// In RuntimeFacade.defineFunction() (lib/compiler/lowering/runtime_facade.dart)
body = analyzer.checkExpression(
  expression: definition.expression,
  currentFunction: name,
  availableParameters: definition.parameters.toSet(),
  usedParameters: usedParameters,
  letBindingNames: {},  // NEW: empty set at function level
  allSignatures: _allSignatures,
);
```

**Design Decision**: Unused let bindings do NOT produce warnings. This is intentional—let bindings are local to an expression and their "unused" status is often a transitional state during development. Future versions may add an optional lint for unused let bindings.

### Compiler Pipeline Impact

| Stage     | Changes                                                                                                                  |
| --------- | ------------------------------------------------------------------------------------------------------------------------ |
| Lexical   | Add `LetToken` and `InToken` keywords                                                                                    |
| Syntactic | Add `LetExpression` and `LetBindingExpression` AST nodes; parse comma-separated bindings; require at least one binding   |
| Semantic  | Extend scope with bindings; check for duplicates, shadowing, and self-reference; add `isLetBinding` field; new errors    |
| Lowering  | Convert `SemanticLetNode` to `LetTerm`; map `SemanticBoundVariableNode` to `LetBoundVariableTerm` or `BoundVariableTerm` |
| Runtime   | Add `LetTerm` with sequential binding evaluation; add `LetBoundVariableTerm` with partial substitution semantics         |

### New Node Types

**Syntactic (AST)**:

```
LetExpression
  bindings: List<LetBindingExpression>
  body: Expression
  location: Location    // location of 'let' token

LetBindingExpression
  name: String
  value: Expression
  location: Location    // location of identifier token (follows MapEntryExpression pattern)
```

**Design note: Why `let` gets a dedicated AST node while `if` is desugared**

The `if` expression is desugared to `CallExpression.fromIf()` because it's semantically a ternary function: it takes a condition and two branches, evaluates the condition, and returns one branch. This fits naturally into the call expression model.

In contrast, `let` introduces **named bindings with scope**. The binding names must be tracked through semantic analysis for shadowing checks, duplicate detection, and scope extension. A `CallExpression` cannot capture this structure—there's no callee, and the "arguments" are name-value pairs, not positional values.

Additionally, `let` requires a dedicated `SemanticLetNode` so the semantic analyzer can:

1. Extract binding names for scope tracking
2. Distinguish let-bound variables from function parameters (`isLetBinding` field)
3. Process bindings sequentially (each binding sees previous bindings)

This is similar to how `MapExpression` has dedicated `MapEntryExpression` nodes rather than desugaring to calls.

**Semantic (IR)**:

```
SemanticLetNode
  bindings: List<SemanticLetBindingNode>
  body: SemanticNode
  location: Location    // propagated from LetExpression

SemanticLetBindingNode
  name: String
  value: SemanticNode
  location: Location    // propagated from LetBindingExpression
```

**Modified existing node** (add field to `lib/compiler/semantic/semantic_node.dart`):

```dart
/// A reference to a bound variable (parameter or let binding) within a function body.
///
/// Created during semantic analysis when an identifier matches a parameter name
/// or a let binding name.
class SemanticBoundVariableNode extends SemanticNode {
  final String name;
  final bool isLetBinding;  // NEW: true for let bindings, false for function parameters

  const SemanticBoundVariableNode({
    required super.location,
    required this.name,
    this.isLetBinding = false,  // Default false for backwards compatibility
  });

  @override
  String toString() => name;
}
```

Note: The default `isLetBinding = false` ensures existing code that creates `SemanticBoundVariableNode` for function parameters continues to work without modification.

**Runtime (Terms)**:

```
LetTerm
  bindings: List<(String, Term)>
  body: Term
  // Methods: substitute(), reduce(), type (AnyType), native(), toString()

LetBoundVariableTerm    // NEW: for let binding references
  name: String
  // Methods: substitute() (partial), reduce() (returns this), type (AnyType),
  //          native() (throws StateError), toString()
```

### Lowering Implementation

Modify the existing `SemanticBoundVariableNode` case and add the `SemanticLetNode` case in `lib/compiler/lowering/lowerer.dart`:

```dart
Term lowerTerm(SemanticNode semanticNode) => switch (semanticNode) {
  // ... existing cases ...

  // MODIFIED: distinguish let bindings from function parameters
  SemanticBoundVariableNode() => semanticNode.isLetBinding
      ? LetBoundVariableTerm(semanticNode.name)
      : BoundVariableTerm(semanticNode.name),

  // NEW: lower let expressions
  SemanticLetNode() => _lowerLet(semanticNode),

  // Keep existing default case for defensive programming.
  // SemanticNode is not a sealed class, so Dart does not enforce
  // exhaustiveness. The default case catches any future node types
  // that might be added without updating the lowerer.
  _ => throw StateError(
    'Unknown semantic node type: ${semanticNode.runtimeType}',
  ),
};

Term _lowerLet(SemanticLetNode semanticNode) {
  final List<(String, Term)> loweredBindings = semanticNode.bindings
      .map((binding) => (binding.name, lowerTerm(binding.value)))
      .toList();

  return LetTerm(
    bindings: loweredBindings,
    body: lowerTerm(semanticNode.body),
  );
}
```

### Implementation Complexity

**Medium**

| Component         | Effort                                                                          |
| ----------------- | ------------------------------------------------------------------------------- |
| Lexer             | Trivial - add two keywords (same pattern as `if`/`else`)                        |
| Parser            | Straightforward - new rule similar to `ifExpression`                            |
| AST               | Two new node types                                                              |
| Semantic analyzer | Moderate - scope extension, shadowing check, `isLetBinding` field on bound vars |
| Lowerer           | Simple - conditional term selection based on `isLetBinding`                     |
| Runtime           | Moderate - new `LetTerm` and `LetBoundVariableTerm` with partial substitution   |
| Tests             | Comprehensive coverage of scoping, substitution, and error conditions           |

### REPL Mode

The `let` expression works in REPL mode the same as in program mode:

```
> let x = 5 in x + 1
6
> let a = 2, b = 3 in a * b
6
```

The semantic analyzer's `currentFunction: null` case handles REPL expressions correctly since `let` bindings are added to `availableParameters` regardless of function context.

### Post-Implementation

After implementing the feature:

1. **Update documentation** in `docs/`:
   - Add `let` expression to `docs/reference/control.md`

2. **Implement tests** — see detailed test specification below

### Test Specification

#### Lexical Tests

| Test                       | Input    | Expected                    |
| -------------------------- | -------- | --------------------------- |
| `let` keyword recognized   | `let`    | `LetToken`                  |
| `in` keyword recognized    | `in`     | `InToken`                   |
| `let` prefix in identifier | `letter` | `IdentifierToken("letter")` |
| `in` prefix in identifier  | `inner`  | `IdentifierToken("inner")`  |

#### Syntactic Tests

| Test              | Input                         | Expected                                   |
| ----------------- | ----------------------------- | ------------------------------------------ |
| Single binding    | `let x = 1 in x`              | `LetExpression` with 1 binding             |
| Multiple bindings | `let x = 1, y = 2 in x`       | `LetExpression` with 2 bindings            |
| Nested let        | `let x = 1 in let y = 2 in y` | Nested `LetExpression`                     |
| Missing `in`      | `let x = 1 x`                 | `ExpectedTokenError('in')`                 |
| Missing comma     | `let x = 1 y = 2 in x`        | `ExpectedTokenError(',')`                  |
| Empty bindings    | `let in x`                    | `ExpectedTokenError` (identifier expected) |
| Trailing comma    | `let x = 1, in x`             | `ExpectedTokenError` (identifier expected) |
| Let as operand    | `1 + let x = 2 in x`          | `InvalidTokenError` or descriptive error   |
| Let in parens     | `1 + (let x = 2 in x)`        | Valid: binary `+` with parenthesized let   |

#### Semantic Tests

| Test                           | Input                                  | Expected                                                    |
| ------------------------------ | -------------------------------------- | ----------------------------------------------------------- |
| Valid single binding           | `f(n) = let x = n in x`                | No errors, no warnings                                      |
| Valid multiple bindings        | `f(n) = let x = n, y = x in y`         | No errors                                                   |
| Shadows parameter              | `f(x) = let x = 1 in x`                | `ShadowedLetBindingError`                                   |
| Shadows outer let              | `f(n) = let x = 1 in let x = 2 in x`   | `ShadowedLetBindingError`                                   |
| Duplicate in same let          | `f(n) = let x = 1, x = 2 in x`         | `DuplicatedLetBindingError`                                 |
| Duplicate non-adjacent         | `f(n) = let x = 1, y = 2, x = 3 in x`  | `DuplicatedLetBindingError`                                 |
| Self-reference                 | `f(n) = let x = x in x`                | `UndefinedIdentifierError`                                  |
| Forward reference              | `f(n) = let y = x, x = 1 in y`         | `UndefinedIdentifierError`                                  |
| Scope isolation                | `f(n) = let x = (let y = 1 in y) in y` | `UndefinedIdentifierError` (y not in outer scope)           |
| Shadow on first binding        | `f(x) = let x = 1, x = 2 in x`         | `ShadowedLetBindingError` (first `x` shadows param)         |
| `isLetBinding` set correctly   | `f(n) = let x = 1 in x`                | Body's `SemanticBoundVariableNode` has `isLetBinding: true` |
| Parameter `isLetBinding` false | `f(n) = n`                             | `SemanticBoundVariableNode` has `isLetBinding: false`       |
| `usedParameters` excludes let  | `f(n) = let x = 1 in x`                | Warning: unused parameter `n`                               |

#### Lowering Tests

| Test                                 | Input                       | Expected                                                 |
| ------------------------------------ | --------------------------- | -------------------------------------------------------- |
| Let binding → `LetBoundVariableTerm` | `let x = 1 in x`            | Body contains `LetBoundVariableTerm("x")`                |
| Parameter → `BoundVariableTerm`      | `f(n) = n`                  | Body contains `BoundVariableTerm("n")`                   |
| Mixed                                | `f(n) = let x = 1 in x + n` | `LetBoundVariableTerm("x")` and `BoundVariableTerm("n")` |

#### Runtime Tests: LetBoundVariableTerm

| Test                             | Code                                           | Expected                   |
| -------------------------------- | ---------------------------------------------- | -------------------------- |
| Partial substitution (not found) | `LetBoundVariableTerm("x").substitute({y: 5})` | Returns `this` (unchanged) |
| Full substitution (found)        | `LetBoundVariableTerm("x").substitute({x: 5})` | Returns `NumberTerm(5)`    |
| Reduce returns this              | `LetBoundVariableTerm("x").reduce()`           | Returns `this` (unchanged) |
| Type is AnyType                  | `LetBoundVariableTerm("x").type`               | `AnyType`                  |
| Native throws if unsubstituted   | `LetBoundVariableTerm("x").native()`           | `StateError`               |
| toString returns name            | `LetBoundVariableTerm("x").toString()`         | `"x"`                      |

#### Runtime Tests: LetTerm (basic)

| Test             | Code                                              | Expected                    |
| ---------------- | ------------------------------------------------- | --------------------------- |
| Type is AnyType  | `LetTerm(bindings: [...], body: ...).type`        | `AnyType`                   |
| Native delegates | `LetTerm(bindings: [(x, 1)], body: x).native()`   | `1` (via reduce().native()) |
| toString format  | `LetTerm(bindings: [(x, 1)], body: x).toString()` | `"let x = 1 in x"`          |

#### Runtime Tests: LetTerm.substitute()

| Test                              | Setup                          | Expected                              |
| --------------------------------- | ------------------------------ | ------------------------------------- |
| Propagates through binding values | `let x = y in x` with `{y: 5}` | Binding becomes `(x, 5)`              |
| Propagates through body           | `let x = 1 in y` with `{y: 5}` | Body becomes `5`                      |
| Let binding refs unchanged        | `let x = 1 in x` with `{y: 5}` | `LetBoundVariableTerm("x")` unchanged |

#### Runtime Tests: LetTerm.reduce()

| Test                             | Input                             | Expected                   |
| -------------------------------- | --------------------------------- | -------------------------- |
| Single binding evaluation        | `let x = 1 + 1 in x`              | `2`                        |
| Sequential evaluation order      | `let x = 1, y = x + 1 in y`       | `2` (x evaluated before y) |
| All bindings substituted in body | `let x = 1, y = 2 in x + y`       | `3`                        |
| Nested let                       | `let x = 1 in let y = x + 1 in y` | `2`                        |

#### Runtime Tests: Error Propagation

| Test                        | Input                      | Expected              |
| --------------------------- | -------------------------- | --------------------- |
| Error in first binding      | `let x = 1/0 in x`         | `DivisionByZeroError` |
| Error in second binding     | `let x = 1, y = 1/0 in y`  | `DivisionByZeroError` |
| Error in body               | `let x = 1 in 1/0`         | `DivisionByZeroError` |
| `try` catches binding error | `try(let x = 1/0 in x, 0)` | `0`                   |
| `try` catches body error    | `try(let x = 1 in 1/0, 0)` | `0`                   |

#### Integration Tests

| Test                       | Input                                       | Expected        |
| -------------------------- | ------------------------------------------- | --------------- |
| `let` with function param  | `f(n) = let x = n * 2 in x` called with `5` | `10`            |
| `let` in `if` branch       | `f(n) = if (n > 0) let x = n in x else 0`   | Works correctly |
| `if` in `let` binding      | `f(n) = let x = if (n > 0) n else -n in x`  | Works correctly |
| `if` in `let` body         | `f(n) = let x = n in if (x > 0) x else -x`  | Works correctly |
| `let` in list element      | `f(n) = [let x = n in x]`                   | `[n]`           |
| `let` in function argument | `f(n) = num.abs(let x = n in x)`            | Works correctly |
| Deeply nested              | `let a = 1 in let b = a in let c = b in c`  | `1`             |

#### REPL Tests

| Test              | Input                       | Expected                                                    |
| ----------------- | --------------------------- | ----------------------------------------------------------- |
| Simple let        | `let x = 5 in x + 1`        | `6`                                                         |
| Multiple bindings | `let a = 2, b = 3 in a * b` | `6`                                                         |
| Error in REPL     | `let x = x in x`            | `UndefinedIdentifierError` (no function context in message) |
