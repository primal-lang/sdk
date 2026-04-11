# Lambda Functions

## Overview

Lambda functions are anonymous inline function expressions. They allow defining functions at the expression level without top-level declarations, primarily benefiting higher-order functions like `list.map`, `list.filter`, and `list.reduce`.

## Syntax

```
lambdaExpression → "(" parameters? ")" "->" expression
parameters       → IDENTIFIER ( "," IDENTIFIER )*
```

Examples:

```primal
() -> 5                    // zero parameters
(x) -> x + 1               // one parameter
(x, y) -> x + y            // two parameters
(a, b, c) -> a + b + c     // three parameters
```

Parentheses are always required around parameters, even for single-parameter lambdas.

## Lexical Changes

Add `ArrowToken` (`->`) as a two-character token.

In `MinusState`, if the next character is `>`, emit `ArrowToken`. Otherwise, proceed with existing `MinusToken` logic.

| State        | If next is | Token produced |
| ------------ | ---------- | -------------- |
| `MinusState` | `>`        | `ArrowToken`   |

## Syntactic Changes

Extend the `primary` rule:

```
primary → BOOLEAN
        | NUMBER
        | STRING
        | IDENTIFIER
        | "(" expression ")"
        | "(" parameters? ")" "->" expression
        | "[" elements? "]"
        | "{" pairs? "}"
```

### Disambiguation

After `(`, if content is comma-separated identifiers followed by `) ->`, parse as lambda. Otherwise, parse as grouped expression.

Parsing strategy:

1. See `(`
2. Attempt to parse as comma-separated identifiers
3. If `)` followed by `->`, commit to lambda and parse body
4. Otherwise, backtrack and parse as grouped expression

## Semantic Rules

1. Lambda creates an anonymous function with a generated name (e.g., `<lambda@1:5>` indicating line:column)
2. Parameters become `SemanticBoundVariableNode` within the lambda body
3. Free variables in the lambda body that reference outer scope parameters are captured at lambda construction time
4. Duplicate parameter names raise `DuplicatedParameterError`
5. Undefined free variables raise `UndefinedIdentifierError`

### Closures

Lambdas capture variables from enclosing scope by value at construction time:

```primal
multiplier(n) = (x) -> x * n
double = multiplier(2)
double(5)  // 10
```

When `multiplier(2)` is called, the lambda `(x) -> x * n` captures `n = 2`. The returned closure remembers this binding.

## Runtime Representation

Lambdas lower to `CustomFunctionTerm`:

- `name`: Generated anonymous name (for error messages)
- `parameters`: List of `Parameter.any(name)` for each parameter
- `term`: Body with parameters as `BoundVariableTerm`, captured variables already substituted

### String Representation

When converted to string (e.g., via `to.string`), lambdas display as:

```
<lambda(x, y)>
```

## Precedence

`->` is part of lambda syntax, not a binary operator. The lambda body extends as far right as possible (greedy):

```primal
(x) -> x + 1           // body is (x + 1)
(x) -> (y) -> x + y    // body is ((y) -> (x + y))
```

To limit the body, use parentheses:

```primal
((x) -> x) + 1         // lambda is (x) -> x, then error: cannot add function
```

## Error Conditions

| Error                       | Condition                                    |
| --------------------------- | -------------------------------------------- |
| `DuplicatedParameterError`  | Repeated parameter name in lambda            |
| `UndefinedIdentifierError`  | Free variable not in scope                   |
| `InvalidArgumentCountError` | Lambda called with wrong number of arguments |
| `InvalidArgumentTypesError` | Lambda passed where incompatible type needed |

## Recursion

Lambdas cannot be recursive because they are anonymous. Use named functions for recursive algorithms.

## Examples

### Valid

```primal
// With higher-order functions
list.map([1, 2, 3], (x) -> x * 2)              // [2, 4, 6]
list.filter([1, 2, 3, 4], (x) -> x > 2)        // [3, 4]
list.reduce([1, 2, 3], 0, (acc, x) -> acc + x) // 6

// Zero-parameter lambda
constant = () -> 42
constant()  // 42

// Closure
multiplier(n) = (x) -> x * n
double = multiplier(2)
double(5)  // 10

// Nested lambdas
compose(f, g) = (x) -> f(g(x))

// Lambda in collection
transformers = [(x) -> x + 1, (x) -> x * 2]
list.map([5], transformers[0])  // [6]

// Immediately invoked
((x) -> x + 1)(5)  // 6

// Lambda returning lambda
((x) -> (y) -> x + y)(3)(4)  // 7

// As function body
add = (x, y) -> x + y
add(2, 3)  // 5

// Lambda in map value
handlers = {"double": (x) -> x * 2}
handlers["double"](5)  // 10

// Lambda in conditional
chooser(b) = if (b) (x) -> x + 1 else (x) -> x * 2
chooser(true)(5)  // 6
```

### Invalid

```primal
// Missing parentheses around parameter
x -> x + 1
// Error: InvalidTokenError at `->`

// Duplicate parameters
(x, x) -> x + 1
// Error: DuplicatedParameterError

// Undefined variable
(x) -> x + y
// Error: UndefinedIdentifierError - 'y' is not defined

// Wrong arity
((x, y) -> x + y)(1)
// Error: InvalidArgumentCountError - expected 2 arguments, got 1
```

## Post-Implementation

### Documentation Updates

- Add `docs/reference/lambda.md`
- Update `docs/primal.md` Syntax section
- Update `docs/compiler/lexical.md` with `ArrowToken`
- Update `docs/compiler/syntactic.md` grammar
- Update `docs/compiler/semantic.md` with lambda handling
- Update `docs/compiler/runtime.md` if needed

### Tests

- Lexical: `->` token recognition
- Syntactic: lambda parsing, disambiguation from grouped expressions
- Semantic: parameter binding, closure capture, duplicate detection, undefined variables
- Runtime: invocation, closures, arity errors, type errors
- Integration: with `list.map`, `list.filter`, `list.reduce`, `list.sort`, etc.

## Implementation Complexity

**Medium**

- Lexical: Minor (one new token)
- Syntactic: Medium (speculative parsing for disambiguation)
- Semantic: Medium (closure capture logic)
- Runtime: Minor (reuses `CustomFunctionTerm`)
