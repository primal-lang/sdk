---
title: Syntactic Analysis
tags: [compiler, parser]
sources: [lib/compiler/syntactic/]
---

# Syntactic Analysis

**TLDR**: The parser uses a state machine for function definitions and recursive descent for expressions, producing an AST where operators and control flow are desugared into uniform function calls.

**Files**: `lib/compiler/syntactic/syntactic_analyzer.dart`, `lib/compiler/syntactic/function_definition.dart`, `lib/compiler/syntactic/expression_parser.dart`, `lib/compiler/syntactic/expression.dart`

The syntactic analyzer (parser) converts the token list into a list of `FunctionDefinition` objects, each containing a name, parameter list, and an expression tree.

## Grammar

### Program Structure

```
program            → functionDefinition*
functionDefinition → IDENTIFIER "(" parameters? ")" "=" expression
parameters         → IDENTIFIER ( "," IDENTIFIER )*
```

### Expressions

```
expression         → lambdaExpression
lambdaExpression   → "(" parameters? ")" "->" expression | letExpression
letExpression      → "let" bindings "in" expression | ifExpression
bindings           → binding ( "," binding )*
binding            → IDENTIFIER "=" expression
ifExpression       → "if" "(" expression ")" expression "else" expression | equality
equality           → logicOr ( ( "!=" | "==" ) logicOr )*
logicOr            → logicAnd ( ( "|" | "||" ) logicAnd )*
logicAnd           → comparison ( ( "&" | "&&" ) comparison )*
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
identifier() = expression               -- nullary function
identifier(p1, p2, ...) = expression    -- parameterized function
```

A `FunctionDefinitionBuilder` accumulates the function name and parameters as the state machine progresses. When the expression body is parsed, it produces the final `FunctionDefinition`.

States:

1. `InitState` - expects an identifier (the function name); creates a `FunctionDefinitionBuilder`.
2. `FunctionNameState` - expects `(` (all functions require parentheses).
3. `FunctionWithParametersState` / `FunctionWithNewParametersState` / `FunctionWithNextParametersState` - parse the comma-separated parameter list, calling `withParameter` on each identifier.
4. `FunctionParametrizedState` - expects `=` after closing `)`.
5. `ResultState` - expression parsing is complete; the builder produces one `FunctionDefinition`.

## Expression Parser

The expression parser is a **recursive descent parser** with the following precedence levels (lowest to highest):

| Precedence | Rule               | Operators / Forms                                                        |
| ---------- | ------------------ | ------------------------------------------------------------------------ |
| 1          | `lambdaExpression` | `(params) -> expr`                                                       |
| 2          | `letExpression`    | `let x = expr in expr`                                                   |
| 3          | `ifExpression`     | `if (cond) expr else expr`                                               |
| 4          | `equality`         | `==`, `!=`                                                               |
| 5          | `logicOr`          | `\|`, `\|\|` (or)                                                        |
| 6          | `logicAnd`         | `&`, `&&` (and)                                                          |
| 7          | `comparison`       | `>`, `>=`, `<`, `<=`                                                     |
| 8          | `term`             | `+`, `-`                                                                 |
| 9          | `factor`           | `*`, `/`, `%`                                                            |
| 10         | `index`            | `@` (element access)                                                     |
| 11         | `unary`            | `!`, `-` (negation)                                                      |
| 12         | `call`             | function application `f(args)`, chained calls `f(x)(y)`, indexing `a[i]` |
| 13         | `primary`          | literals, identifiers, `(expr)`, `[list]`, `{map}`                       |

## Expression Tree

All expressions extend `Expression` (which has a `Location`):

- `LiteralExpression<T>` - base for all literal values
  - `BooleanExpression`, `NumberExpression`, `StringExpression`
  - `ListExpression` (contains `List<Expression>`)
  - `MapExpression` (contains `List<MapEntryExpression>`)
    - `MapEntryExpression` extends `Located` (not `Expression`, as map entries only appear within map literals)
- `IdentifierExpression` (extends `LiteralExpression<String>`) - a named reference (variable or function)
- `CallExpression` - function application (callee expression + argument list)
  - Also used to represent binary and unary operators via factory constructors (`fromBinaryOperation`, `fromUnaryOperation`, `fromIf`)
- `LambdaExpression` - anonymous function with parameter list and body expression
- `LetExpression` - local binding expression with bindings and body
  - `LetBindingExpression` extends `Located` (not `Expression`, as let bindings only appear within let expressions)

Operators and `if` expressions are desugared into `CallExpression` nodes at parse time, unifying all computation as function application.

## Desugaring

The parser desugars several syntactic forms into `CallExpression` nodes:

| Syntax            | Desugared Form |
| ----------------- | -------------- |
| `a + b`           | `+(a, b)`      |
| `a == b`          | `==(a, b)`     |
| `a \|\| b`        | `\|(a, b)`     |
| `a && b`          | `&(a, b)`      |
| `!x`              | `!(x)`         |
| `-x`              | `-(0, x)`      |
| `a @ i`           | `@(a, i)`      |
| `a[i]`            | `@(a, i)`      |
| `if (c) t else f` | `if(c, t, f)`  |

Note: Unary negation is converted to binary subtraction from zero. The synthetic `0` uses the same source location as the `-` operator, since it represents the implicit zero at that position.

## Bridge to Semantic Analysis

The semantic analyzer converts expressions directly to semantic IR nodes, preserving source locations:

| Expression             | Semantic Node                                           |
| ---------------------- | ------------------------------------------------------- |
| `BooleanExpression`    | `SemanticBooleanNode`                                   |
| `NumberExpression`     | `SemanticNumberNode`                                    |
| `StringExpression`     | `SemanticStringNode`                                    |
| `ListExpression`       | `SemanticListNode`                                      |
| `MapExpression`        | `SemanticMapNode`                                       |
| `IdentifierExpression` | `SemanticIdentifierNode` or `SemanticBoundVariableNode` |
| `CallExpression`       | `SemanticCallNode`                                      |
| `LambdaExpression`     | `SemanticLambdaNode`                                    |
| `LetExpression`        | `SemanticLetNode`                                       |

The semantic IR is then lowered to runtime terms (`BooleanTerm`, `NumberTerm`, etc.) for evaluation. See [semantic.md](semantic.md) for details.
