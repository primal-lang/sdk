# Syntactic Analysis

**Files**: `lib/compiler/syntactic/syntactic_analyzer.dart`, `lib/compiler/syntactic/function_definition.dart`, `lib/compiler/syntactic/expression_parser.dart`, `lib/compiler/syntactic/expression.dart`

The syntactic analyzer (parser) converts the token list into a list of `FunctionDefinition` objects, each containing a name, parameter list, and an expression tree.

## Function Definition Parsing

A state machine parses top-level function definitions:

```
identifier = expression               -- nullary function
identifier(p1, p2, ...) = expression  -- parameterized function
```

States:

1. `InitState` - expects an identifier (the function name).
2. `FunctionNameState` - expects either `=` (nullary) or `(` (parameterized).
3. `FunctionWithParametersState` / `FunctionWithNewParametersState` / `FunctionWithNextParametersState` - parse the comma-separated parameter list.
4. `FunctionParametrizedState` - expects `=` after closing `)`.
5. `ResultState` - expression parsing is complete; one `FunctionDefinition` is emitted.

## Expression Parser

The expression parser is a **recursive descent parser** with the following precedence levels (lowest to highest):

| Precedence | Rule           | Operators / Forms                                  |
| ---------- | -------------- | -------------------------------------------------- |
| 1          | `ifExpression` | `if (cond) expr else expr`                         |
| 2          | `equality`     | `==`, `!=`                                         |
| 3          | `comparison`   | `>`, `>=`, `<`, `<=`                               |
| 4          | `logic`        | `\|` (or), `&` (and)                               |
| 5          | `term`         | `+`, `-`                                           |
| 6          | `factor`       | `*`, `/`, `%`                                      |
| 7          | `unary`        | `!`, `-` (negation)                                |
| 8          | `call`         | function application `f(args)`, indexing `a[i]`    |
| 9          | `primary`      | literals, identifiers, `(expr)`, `[list]`, `{map}` |

## Expression Tree

All expressions extend `Expression` (which has a `Location`):

- `LiteralExpression<T>` - base for all literal values
  - `BooleanExpression`, `NumberExpression`, `StringExpression`
  - `ListExpression` (contains `List<Expression>`)
  - `MapExpression` (contains `Map<Expression, Expression>`)
- `IdentifierExpression` - a named reference (variable or function)
- `CallExpression` - function application (callee expression + argument list)
  - Also used to represent binary and unary operators via factory constructors (`fromBinaryOperation`, `fromUnaryOperation`, `fromIf`)

Operators and `if` expressions are desugared into `CallExpression` nodes at parse time, unifying all computation as function application.
