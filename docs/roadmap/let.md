# Let Expression

## Overview

The `let` expression introduces local variable bindings within an expression body. This allows intermediate values to be named and reused, reducing duplication and improving readability.

```primal
distance(x1, y1, x2, y2) =
    let
        dx = x2 - x1
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
bindings       → binding+
binding        → IDENTIFIER "=" expression
```

**Precedence**: `let` has the lowest precedence (below `if`), so `let x = 1 in x + 2` parses as `let x = 1 in (x + 2)`.

**Associativity**: Right-associative. Chained `let` expressions nest naturally.

**Position**: `let` can appear at the start of an expression context, the same positions where `if` is valid today. It cannot appear as an operand to binary operators without parentheses (e.g., `1 + let x = 2 in x` is invalid; use `1 + (let x = 2 in x)`).

**Whitespace**: Not significant. Indentation in examples is purely for readability. These are equivalent:

```primal
// Multi-line (formatted for readability)
foo(a, b) =
    let
        x = a + 1
        y = b + 2
    in
        x + y

// Single-line (compact)
foo(a, b) = let x = a + 1 y = b + 2 in x + y
```

## Semantics

### Binding Scope

Each binding is visible to all subsequent bindings and the body:

```primal
// Valid: y sees x
foo(a, b) =
    let
        x = a + 1
        y = x * 2
    in
        x + y
```

### No Self-Reference

A binding cannot reference itself. This is not a recursive binding construct:

```primal
// ERROR: x references itself (no outer x exists)
bad(n) = let x = x + 1 in x
// → UndefinedIdentifierError: 'x' is not defined

// ERROR: shadowing is checked before the value expression
bad(x) = let x = x + 1 in x
// → ShadowedBindingError: 'x' is already bound
// (the value expression x + 1 is never analyzed)
```

### No Duplicate Bindings

Multiple bindings with the same name in a single `let` are an error:

```primal
// ERROR: x bound twice
bad(n) = let x = 1 x = 2 in x
// → DuplicatedLetBindingError: 'x' is already bound in this let expression
```

### No Shadowing

Bindings cannot shadow function parameters or outer `let` bindings. This simplifies implementation and avoids confusion about which binding is referenced:

```primal
// ERROR: x shadows parameter
bad(x) = let x = 10 in x
// → ShadowedBindingError: 'x' is already bound

// ERROR: inner x shadows outer x
bad(n) = let x = 1 in let x = 2 in x
// → ShadowedBindingError: 'x' is already bound
```

### Evaluation Order

Bindings are evaluated sequentially in declaration order (call-by-value). Each binding is fully evaluated before the next:

```primal
foo(a) =
    let
        x = a + 1       // evaluated first
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

| Error                       | Condition                                      |
| --------------------------- | ---------------------------------------------- |
| `EmptyLetBindingsError`     | No bindings provided between `let` and `in`    |
| `DuplicatedLetBindingError` | Same variable bound twice in one `let`         |
| `ShadowedBindingError`      | Binding shadows a parameter or outer binding   |
| `UndefinedIdentifierError`  | Binding references itself or an undefined name |
| `ExpectedTokenError('in')`  | `in` keyword missing after bindings            |

## Examples

### Valid

```primal
// Basic binding
double(n) = let x = n * 2 in x

// Multiple bindings with dependencies
sum_of_squares(a, b) =
    let
        a2 = a * a
        b2 = b * b
    in
        a2 + b2

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

// let as operand (requires parentheses)
offset(a, b) = 1 + (let x = a * b in x)

// Chained single-binding lets (equivalent to nested)
chain(a, b) = let x = a + b in let y = x * 2 in y
```

### Invalid

```primal
// ERROR: Empty bindings
bad0(n) = let in n
// → EmptyLetBindingsError: let expression requires at least one binding

// ERROR: Duplicate binding
bad1(n) = let x = 1 x = 2 in x
// → DuplicatedLetBindingError: 'x' is already bound in this let expression

// ERROR: Self-reference
bad2(n) = let x = x + 1 in x
// → UndefinedIdentifierError: 'x' is not defined

// ERROR: Forward reference within same let
bad3(n) = let y = x x = 1 in y
// → UndefinedIdentifierError: 'x' is not defined

// ERROR: Missing 'in'
bad4(n) = let x = 1 x + 2
// → ExpectedTokenError: expected 'in'

// ERROR: Shadows parameter
bad5(x) = let x = 1 in x
// → ShadowedBindingError: 'x' is already bound

// ERROR: Shadows outer let binding
bad6(n) = let x = 1 in let x = 2 in x
// → ShadowedBindingError: 'x' is already bound
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
    final Term value = term.substitute(Bindings(bindingMap)).reduce();
    bindingMap[name] = value;
  }
  return body.substitute(Bindings(bindingMap)).reduce();
}
```

Since shadowing is disallowed at the semantic level, the `substitute()` method does not need capture-avoiding logic—no let binding name can ever conflict with an incoming substitution.

This is semantically equivalent to nested immediately-applied functions, but implemented directly without synthesizing intermediate function terms.

### Semantic Analysis Algorithm

When processing a `LetExpression`:

1. For each binding in order:
   - If the name is already in `availableParameters`, throw `ShadowedBindingError`
   - Check the binding's value expression against the current `availableParameters`
   - Add the name to `availableParameters` (for subsequent bindings and the body)
2. Check the body expression against the extended `availableParameters`
3. Return a `SemanticLetNode` with the checked bindings and body

Since shadowing is disallowed, let binding names are guaranteed to be distinct from parameters. This means:

- The existing `availableParameters` set can be reused without modification
- No scoped symbol model is needed to distinguish parameters from let bindings
- The `usedParameters` tracking for `UnusedParameterWarning` works correctly

### Compiler Pipeline Impact

| Stage     | Changes                                                                         |
| --------- | ------------------------------------------------------------------------------- |
| Lexical   | Add `LetToken` and `InToken` keywords                                           |
| Syntactic | Add `LetExpression` and `LetBindingExpression` AST nodes                        |
| Semantic  | Extend scope with bindings, check for duplicates, shadowing, and self-reference |
| Lowering  | Convert `SemanticLetNode` to `LetTerm`                                          |
| Runtime   | Add `LetTerm` with sequential binding evaluation                                |

### New Node Types

**Syntactic (AST)**:

```
LetExpression
  bindings: List<LetBindingExpression>
  body: Expression
  location: Location

LetBindingExpression
  name: String
  value: Expression
  location: Location
```

**Semantic (IR)**:

```
SemanticLetNode
  bindings: List<SemanticLetBindingNode>
  body: SemanticNode
  location: Location

SemanticLetBindingNode
  name: String
  value: SemanticNode
  location: Location
```

**Runtime (Terms)**:

```
LetTerm
  bindings: List<(String, Term)>
  body: Term
```

### Implementation Complexity

**Medium**

| Component         | Effort                                                   |
| ----------------- | -------------------------------------------------------- |
| Lexer             | Trivial - add two keywords (same pattern as `if`/`else`) |
| Parser            | Straightforward - new rule similar to `ifExpression`     |
| AST               | Two new node types                                       |
| Semantic analyzer | Simple - scope extension and shadowing check             |
| Lowerer           | New term type and lowering logic                         |
| Runtime           | New `LetTerm` with substitution-based evaluation         |
| Tests             | Comprehensive coverage of scoping and error conditions   |

### Post-Implementation

After implementing the feature:

1. **Update documentation** in `docs/`:
   - Add `let` expression to `docs/reference/control.md`
   - Update `docs/compiler/lexical.md` with new keywords
   - Update `docs/compiler/syntactic.md` with new grammar rules and AST nodes
   - Update `docs/compiler/semantic.md` with new semantic nodes and analysis
   - Update `docs/compiler/runtime.md` with `LetTerm` behavior

2. **Implement tests** using the examples from this document:
   - Lexical: `let` and `in` token recognition
   - Syntactic: `LetExpression` parsing (single binding, multiple bindings, nested)
   - Semantic: scope extension, duplicate detection, shadowing errors, self-reference errors
   - Lowering: `SemanticLetNode` to `LetTerm` conversion
   - Runtime: sequential evaluation, substitution behavior
   - Integration: all valid and invalid examples from this specification
