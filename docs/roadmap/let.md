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

**Precedence**: `let` has the lowest precedence, binding more loosely than all other operators including `if`. This means `let x = 1 in x + 2` parses as `let x = 1 in (x + 2)`, and `let x = 1 in if (x > 0) x else 0` parses as `let x = 1 in (if (x > 0) x else 0)`.

**Associativity**: Right-associative. Chained `let` expressions nest naturally.

**Position**: `let` can appear at the start of an expression context, the same positions where `if` is valid today. It cannot appear as an operand to binary operators without parentheses (e.g., `1 + let x = 2 in x` is invalid; use `1 + (let x = 2 in x)`).

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

**Breaking change**: Existing identifiers named `let` or `in` become reserved keywords.

## Error Conditions

| Error                       | Condition                                      | Priority |
| --------------------------- | ---------------------------------------------- | -------- |
| `EmptyLetBindingsError`     | No bindings provided between `let` and `in`    | 1        |
| `ShadowedLetBindingError`   | Binding shadows a parameter or outer binding   | 2        |
| `DuplicatedLetBindingError` | Same variable bound twice in one `let`         | 3        |
| `UndefinedIdentifierError`  | Binding references itself or an undefined name | 4        |
| `ExpectedTokenError(',')`   | Comma missing between bindings                 | —        |
| `ExpectedTokenError('in')`  | `in` keyword missing after bindings            | —        |

**Error Priority**: When multiple errors could apply to the same binding, the error with the lowest priority number is thrown first. Shadowing is checked before duplicate detection, and both are checked before the value expression is analyzed. `ExpectedTokenError` is a syntactic error and is detected during parsing, before semantic analysis.

**New Error Types**: The following error types must be added to `lib/compiler/errors/semantic_error.dart`:

```dart
class EmptyLetBindingsError extends SemanticError {
  const EmptyLetBindingsError({
    String? inFunction,
  }) : super(
         inFunction != null
             ? 'Empty let expression in function "$inFunction"'
             : 'Empty let expression',
       );
}

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
// ERROR: Empty bindings
bad0(n) = let in n
// → EmptyLetBindingsError: Empty let expression

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

// ERROR: Shadows earlier binding in same let
bad8(n) = let x = 1, y = 2, x = 3 in x
// → DuplicatedLetBindingError: Duplicated let binding "x"
```

## Implementation Notes

### Runtime

The `let` expression is implemented via a `LetTerm` in the runtime that performs sequential binding and substitution:

1. Evaluate each binding value in declaration order
2. After each evaluation, add the binding to the substitution map
3. Each subsequent binding's term is substituted with all previous bindings before evaluation
4. Finally, substitute all bindings into the body and reduce

```dart
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

1. If bindings list is empty, throw `EmptyLetBindingsError`
2. Create a local set `letBindingNames` to track names bound in this `let`
3. For each binding in order:
   - If the name is in `availableParameters`, throw `ShadowedLetBindingError`
   - If the name is in `letBindingNames`, throw `DuplicatedLetBindingError`
   - Check the binding's value expression against the current `availableParameters`
   - Add the name to `letBindingNames`
   - Add the name to `availableParameters` (for subsequent bindings and the body)
4. Check the body expression against the extended `availableParameters`
5. Return a `SemanticLetNode` with the checked bindings and body

**Error Priority**: Shadowing is checked before duplicate detection. Both are checked before the value expression is analyzed. This means if a binding name shadows a parameter AND the value references itself, the shadowing error is thrown first.

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

Modify `_checkIdentifierExpression()` to track usage and set `isLetBinding`:

```dart
SemanticNode _checkIdentifierExpression({...}) {
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

**Design Decision**: Unused let bindings do NOT produce warnings. This is intentional—let bindings are local to an expression and their "unused" status is often a transitional state during development. Future versions may add an optional lint for unused let bindings.

### Compiler Pipeline Impact

| Stage     | Changes                                                                                                                      |
| --------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Lexical   | Add `LetToken` and `InToken` keywords                                                                                        |
| Syntactic | Add `LetExpression` and `LetBindingExpression` AST nodes; parse comma-separated bindings                                     |
| Semantic  | Extend scope with bindings; check for empty, duplicates, shadowing, and self-reference; add `isLetBinding` field; new errors |
| Lowering  | Convert `SemanticLetNode` to `LetTerm`; map `SemanticBoundVariableNode` to `LetBoundVariableTerm` or `BoundVariableTerm`     |
| Runtime   | Add `LetTerm` with sequential binding evaluation; add `LetBoundVariableTerm` with partial substitution semantics             |

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

```
SemanticBoundVariableNode
  name: String
  isLetBinding: bool    // NEW: true for let bindings, false for function parameters
  location: Location
```

**Runtime (Terms)**:

```
LetTerm
  bindings: List<(String, Term)>
  body: Term

LetBoundVariableTerm    // NEW: for let binding references
  name: String
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

  // ... existing default case ...
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

#### Semantic Tests

| Test                              | Input                                | Expected                                                    |
| --------------------------------- | ------------------------------------ | ----------------------------------------------------------- |
| Valid single binding              | `f(n) = let x = n in x`              | No errors, no warnings                                      |
| Valid multiple bindings           | `f(n) = let x = n, y = x in y`       | No errors                                                   |
| Empty bindings                    | `f(n) = let in n`                    | `EmptyLetBindingsError`                                     |
| Shadows parameter                 | `f(x) = let x = 1 in x`              | `ShadowedLetBindingError`                                   |
| Shadows outer let                 | `f(n) = let x = 1 in let x = 2 in x` | `ShadowedLetBindingError`                                   |
| Duplicate in same let             | `f(n) = let x = 1, x = 2 in x`       | `DuplicatedLetBindingError`                                 |
| Self-reference                    | `f(n) = let x = x in x`              | `UndefinedIdentifierError`                                  |
| Forward reference                 | `f(n) = let y = x, x = 1 in y`       | `UndefinedIdentifierError`                                  |
| Error priority: shadow before dup | `f(x) = let x = 1, x = 2 in x`       | `ShadowedLetBindingError` (not Duplicated)                  |
| `isLetBinding` set correctly      | `f(n) = let x = 1 in x`              | Body's `SemanticBoundVariableNode` has `isLetBinding: true` |
| Parameter `isLetBinding` false    | `f(n) = n`                           | `SemanticBoundVariableNode` has `isLetBinding: false`       |
| `usedParameters` excludes let     | `f(n) = let x = 1 in x`              | Warning: unused parameter `n`                               |

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
| Native throws if unsubstituted   | `LetBoundVariableTerm("x").native()`           | `StateError`               |

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
