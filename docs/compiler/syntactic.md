# Syntactic Analysis

**Files**: `lib/compiler/syntactic/syntactic_analyzer.dart`, `lib/compiler/syntactic/function_definition.dart`, `lib/compiler/syntactic/expression_parser.dart`, `lib/compiler/syntactic/expression.dart`

The syntactic analyzer (parser) converts the token list into a list of `FunctionDefinition` objects, each containing a name, parameter list, and an expression tree.

## Grammar

### Program Structure

```
program            → functionDefinition*
functionDefinition → IDENTIFIER "=" expression | IDENTIFIER "(" parameters ")" "=" expression
parameters         → IDENTIFIER ( "," IDENTIFIER )*
```

### Expressions

```
expression         → ifExpression
ifExpression       → "if" "(" expression ")" expression "else" expression | equality
equality           → logicOr ( ( "!=" | "==" ) logicOr )*
logicOr            → logicAnd ( "|" logicAnd )*
logicAnd           → comparison ( "&" comparison )*
comparison         → term ( ( ">" | ">=" | "<" | "<=" ) term )*
term               → factor ( ( "-" | "+" ) factor )*
factor             → index ( ( "/" | "*" | "%" ) index )*
index              → unary ( "@" unary )*
unary              → ( "!" | "-" ) unary | call
call               → primary ( "(" arguments? ")" | "[" expression "]" )*
primary            → BOOLEAN | NUMBER | STRING | IDENTIFIER | "(" expression ")" | "[" elements? "]" | "{" pairs? "}"
arguments          → expression ( "," expression )*
elements           → expression ( "," expression )*
pairs              → pair ( "," pair )*
pair               → expression ":" expression
```

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

| Precedence | Rule           | Operators / Forms                                                        |
| ---------- | -------------- | ------------------------------------------------------------------------ |
| 1          | `ifExpression` | `if (cond) expr else expr`                                               |
| 2          | `equality`     | `==`, `!=`                                                               |
| 3          | `logicOr`      | `\|` (or)                                                                |
| 4          | `logicAnd`     | `&` (and)                                                                |
| 5          | `comparison`   | `>`, `>=`, `<`, `<=`                                                     |
| 6          | `term`         | `+`, `-`                                                                 |
| 7          | `factor`       | `*`, `/`, `%`                                                            |
| 8          | `index`        | `@` (element access)                                                     |
| 9          | `unary`        | `!`, `-` (negation)                                                      |
| 10         | `call`         | function application `f(args)`, chained calls `f(x)(y)`, indexing `a[i]` |
| 11         | `primary`      | literals, identifiers, `(expr)`, `[list]`, `{map}`                       |

## Expression Tree

All expressions extend `Expression` (which has a `Location`):

- `LiteralExpression<T>` - base for all literal values
  - `BooleanExpression`, `NumberExpression`, `StringExpression`
  - `ListExpression` (contains `List<Expression>`)
  - `MapExpression` (contains `List<MapEntryExpression>`)
    - `MapEntryExpression` extends `Localized` (not `Expression`, as map entries only appear within map literals)
- `IdentifierExpression` (extends `LiteralExpression<String>`) - a named reference (variable or function)
- `CallExpression` - function application (callee expression + argument list)
  - Also used to represent binary and unary operators via factory constructors (`fromBinaryOperation`, `fromUnaryOperation`, `fromIf`)

Operators and `if` expressions are desugared into `CallExpression` nodes at parse time, unifying all computation as function application.

## Desugaring

The parser desugars several syntactic forms into `CallExpression` nodes:

| Syntax            | Desugared Form     |
| ----------------- | ------------------ |
| `a + b`           | `+(a, b)`          |
| `a == b`          | `==(a, b)`         |
| `!x`              | `!(x)`             |
| `-x`              | `-(0, x)`          |
| `a @ i`           | `@(a, i)`          |
| `a[i]`            | `@(a, i)`          |
| `if (c) t else f` | `if(c, t, f)`      |

Note: Unary negation is converted to binary subtraction from zero. The synthetic `0` uses the same source location as the `-` operator, since it represents the implicit zero at that position.

## Bridge to Runtime

Each `Expression` subclass implements a `toNode()` method that converts the parse tree into runtime nodes:

| Expression             | Runtime Node       |
| ---------------------- | ------------------ |
| `BooleanExpression`    | `BooleanNode`      |
| `NumberExpression`     | `NumberNode`       |
| `StringExpression`     | `StringNode`       |
| `ListExpression`       | `ListNode`         |
| `MapExpression`        | `MapNode`          |
| `IdentifierExpression` | `FreeVariableNode` |
| `CallExpression`       | `CallNode`         |

This conversion happens during semantic analysis when building the runtime representation.
