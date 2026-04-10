# Compilation Example

This document walks through the complete compilation and evaluation of a Primal program, showing the data transformations at each stage of the pipeline.

## Source Code

```primal
square(n) = n * n
max(a, b) = if (a >= b) a else b
main = max(square(3), square(4))
```

This program defines:

- `square(n)` — returns the square of a number
- `max(a, b)` — returns the larger of two numbers using a conditional
- `main` — computes `max(9, 16)` which evaluates to `16`

## Pipeline Overview

```
Source Code
    │
    ▼
 SourceReader ........ Characters with locations          → compiler/reader.md
    │
    ▼
 Lexical Analyzer .... Tokens (keywords, literals, ...)   → compiler/lexical.md
    │
    ▼
 Syntactic Analyzer .. Function definitions with ASTs     → compiler/syntactic.md
    │
    ▼
 Semantic Analyzer ... Semantic IR with FunctionSignature → compiler/semantic.md
    │
    ▼
 Lowerer ............. Runtime terms for evaluation       → compiler/semantic.md
    │
    ▼
 Runtime ............. Evaluation via node substitution   → compiler/runtime.md
```

---

## Stage 1: SourceReader

**File**: `lib/compiler/reader/source_reader.dart`

The SourceReader is the first stage of the pipeline. It converts a raw input string into a flat list of `Character` objects, each annotated with its source position (row and column).

### Transformation

**Input**: `String` (the raw source code)

**Output**: `List<Character>` (characters with locations)

### Step-by-Step Processing

#### Input String

```
square(n) = n * n
max(a, b) = if (a >= b) a else b
main = max(square(3), square(4))
```

#### Step 1: Normalize Line Endings

The input is scanned for `\r\n` (Windows) and `\r` (old Mac) line endings, which are converted to `\n` (Unix). Our input already uses `\n`, so no changes occur.

#### Step 2: Split into Rows

The normalized string is split by `\n`. If the last element is empty (from a trailing newline), it is removed to avoid generating a spurious empty row:

| Row Index | Content                            |
| --------- | ---------------------------------- |
| 0         | `square(n) = n * n`                |
| 1         | `max(a, b) = if (a >= b) a else b` |
| 2         | `main = max(square(3), square(4))` |

#### Step 3: Process Each Row

For each row, the reader:

1. Iterates through each grapheme cluster (handles multi-codepoint characters like emoji correctly)
2. Creates a `Character` with the value and a `Location(row: i+1, column: j+1)`
3. Appends a newline `Character` at the end of each row

### Complete Output

The `SourceReader` produces a `List<Character>` with **84 elements**:

#### Row 1: `square(n) = n * n`

| Index | Value | Location |
| ----- | ----- | -------- |
| 0     | `s`   | [1, 1]   |
| 1     | `q`   | [1, 2]   |
| 2     | `u`   | [1, 3]   |
| 3     | `a`   | [1, 4]   |
| 4     | `r`   | [1, 5]   |
| 5     | `e`   | [1, 6]   |
| 6     | `(`   | [1, 7]   |
| 7     | `n`   | [1, 8]   |
| 8     | `)`   | [1, 9]   |
| 9     | ` `   | [1, 10]  |
| 10    | `=`   | [1, 11]  |
| 11    | ` `   | [1, 12]  |
| 12    | `n`   | [1, 13]  |
| 13    | ` `   | [1, 14]  |
| 14    | `*`   | [1, 15]  |
| 15    | ` `   | [1, 16]  |
| 16    | `n`   | [1, 17]  |
| 17    | `\n`  | [1, 18]  |

#### Row 2: `max(a, b) = if (a >= b) a else b`

| Index | Value | Location |
| ----- | ----- | -------- |
| 18    | `m`   | [2, 1]   |
| 19    | `a`   | [2, 2]   |
| 20    | `x`   | [2, 3]   |
| 21    | `(`   | [2, 4]   |
| 22    | `a`   | [2, 5]   |
| 23    | `,`   | [2, 6]   |
| 24    | ` `   | [2, 7]   |
| 25    | `b`   | [2, 8]   |
| 26    | `)`   | [2, 9]   |
| 27    | ` `   | [2, 10]  |
| 28    | `=`   | [2, 11]  |
| 29    | ` `   | [2, 12]  |
| 30    | `i`   | [2, 13]  |
| 31    | `f`   | [2, 14]  |
| 32    | ` `   | [2, 15]  |
| 33    | `(`   | [2, 16]  |
| 34    | `a`   | [2, 17]  |
| 35    | ` `   | [2, 18]  |
| 36    | `>`   | [2, 19]  |
| 37    | `=`   | [2, 20]  |
| 38    | ` `   | [2, 21]  |
| 39    | `b`   | [2, 22]  |
| 40    | `)`   | [2, 23]  |
| 41    | ` `   | [2, 24]  |
| 42    | `a`   | [2, 25]  |
| 43    | ` `   | [2, 26]  |
| 44    | `e`   | [2, 27]  |
| 45    | `l`   | [2, 28]  |
| 46    | `s`   | [2, 29]  |
| 47    | `e`   | [2, 30]  |
| 48    | ` `   | [2, 31]  |
| 49    | `b`   | [2, 32]  |
| 50    | `\n`  | [2, 33]  |

#### Row 3: `main = max(square(3), square(4))`

| Index | Value | Location |
| ----- | ----- | -------- |
| 51    | `m`   | [3, 1]   |
| 52    | `a`   | [3, 2]   |
| 53    | `i`   | [3, 3]   |
| 54    | `n`   | [3, 4]   |
| 55    | ` `   | [3, 5]   |
| 56    | `=`   | [3, 6]   |
| 57    | ` `   | [3, 7]   |
| 58    | `m`   | [3, 8]   |
| 59    | `a`   | [3, 9]   |
| 60    | `x`   | [3, 10]  |
| 61    | `(`   | [3, 11]  |
| 62    | `s`   | [3, 12]  |
| 63    | `q`   | [3, 13]  |
| 64    | `u`   | [3, 14]  |
| 65    | `a`   | [3, 15]  |
| 66    | `r`   | [3, 16]  |
| 67    | `e`   | [3, 17]  |
| 68    | `(`   | [3, 18]  |
| 69    | `3`   | [3, 19]  |
| 70    | `)`   | [3, 20]  |
| 71    | `,`   | [3, 21]  |
| 72    | ` `   | [3, 22]  |
| 73    | `s`   | [3, 23]  |
| 74    | `q`   | [3, 24]  |
| 75    | `u`   | [3, 25]  |
| 76    | `a`   | [3, 26]  |
| 77    | `r`   | [3, 27]  |
| 78    | `e`   | [3, 28]  |
| 79    | `(`   | [3, 29]  |
| 80    | `4`   | [3, 30]  |
| 81    | `)`   | [3, 31]  |
| 82    | `)`   | [3, 32]  |
| 83    | `\n`  | [3, 33]  |

### Summary

| Property       | Value                  |
| -------------- | ---------------------- |
| Input type     | `String`               |
| Output type    | `List<Character>`      |
| Input length   | 84 characters (raw)    |
| Output length  | 84 `Character` objects |
| Rows processed | 3                      |

The output preserves every character from the source (including whitespace and newlines) with precise location information that will be used for error reporting in later stages.

### Key Observations

1. **1-based indexing**: Rows and columns start at 1, matching how text editors display positions.
2. **Newline injection**: A `\n` is appended after every row, ensuring consistent line boundaries.
3. **Whitespace preserved**: Spaces are kept as separate `Character` objects—they will be skipped by the lexer.
4. **Grapheme-aware**: The reader uses `package:characters` to handle multi-codepoint characters correctly (e.g., emoji would be treated as single characters).
5. **Shebang skipping**: If the first row starts with `#!`, it is skipped entirely. This allows Primal scripts to use Unix shebang lines (e.g., `#!/usr/bin/env primal`) without affecting compilation.

---

## Stage 2: Lexical Analyzer

**File**: `lib/compiler/lexical/lexical_analyzer.dart`

The lexical analyzer consumes the character list and produces a list of typed tokens. It is implemented as a **state machine** that recognizes keywords, identifiers, literals, operators, and delimiters.

### Transformation

**Input**: `List<Character>` (84 characters with locations)

**Output**: `List<Token>` (typed tokens with locations)

### Step-by-Step Processing

The analyzer wraps the input in a `ListIterator<Character>` and starts in `InitState`. Each iteration:

1. Calls `state.next`, which reads the next character and delegates to `process()`
2. Transitions to a new state based on the character
3. When a `ResultState` is reached, the token is collected and the machine resets to `InitState`

#### Processing Row 1: `square(n) = n * n`

| Character | State Transition                      | Action                                                      |
| --------- | ------------------------------------- | ----------------------------------------------------------- |
| `s`       | `InitState` → `IdentifierState`       | Start identifier, lexeme = `"s"`                            |
| `q`       | `IdentifierState` → `IdentifierState` | Accumulate, lexeme = `"sq"`                                 |
| `u`       | `IdentifierState` → `IdentifierState` | Accumulate, lexeme = `"squ"`                                |
| `a`       | `IdentifierState` → `IdentifierState` | Accumulate, lexeme = `"squa"`                               |
| `r`       | `IdentifierState` → `IdentifierState` | Accumulate, lexeme = `"squar"`                              |
| `e`       | `IdentifierState` → `IdentifierState` | Accumulate, lexeme = `"square"`                             |
| `(`       | `IdentifierState` → `ResultState`     | Delimiter found; `back()`, emit `IdentifierToken("square")` |
| `(`       | `InitState` → `ResultState`           | Emit `OpenParenthesisToken("(")` directly                   |
| `n`       | `InitState` → `IdentifierState`       | Start identifier                                            |
| `)`       | `IdentifierState` → `ResultState`     | Delimiter found; `back()`, emit `IdentifierToken("n")`      |
| `)`       | `InitState` → `ResultState`           | Emit `CloseParenthesisToken(")")` directly                  |
| ` `       | `InitState` → `InitState`             | Whitespace skipped                                          |
| `=`       | `InitState` → `EqualsState`           | Start potential `=` or `==`                                 |
| ` `       | `EqualsState` → `ResultState`         | Next char not `=`; `back()`, emit `AssignToken("=")`        |
| ` `       | `InitState` → `InitState`             | Whitespace skipped                                          |
| `n`       | `InitState` → `IdentifierState`       | Start identifier                                            |
| ` `       | `IdentifierState` → `ResultState`     | Delimiter found; `back()`, emit `IdentifierToken("n")`      |
| ` `       | `InitState` → `InitState`             | Whitespace skipped                                          |
| `*`       | `InitState` → `AsteriskState`         | Start operator                                              |
| ` `       | `AsteriskState` → `ResultState`       | Delimiter found; `back()`, emit `AsteriskToken("*")`        |
| ` `       | `InitState` → `InitState`             | Whitespace skipped                                          |
| `n`       | `InitState` → `IdentifierState`       | Start identifier                                            |
| `\n`      | `IdentifierState` → `ResultState`     | Delimiter found; `back()`, emit `IdentifierToken("n")`      |
| `\n`      | `InitState` → `InitState`             | Whitespace skipped                                          |

**Tokens from Row 1**: 8 tokens

#### Processing Row 2: `max(a, b) = if (a >= b) a else b`

Key observations:

- `max` → `IdentifierToken` (not a keyword)
- `if` → `IfToken` (keyword detected at boundary)
- `>=` → `GreaterOrEqualToken` (two-character operator)
- `else` → `ElseToken` (keyword detected at boundary)

The `>=` operator is recognized through lookahead:

| Character | State Transition               | Action                                             |
| --------- | ------------------------------ | -------------------------------------------------- |
| `>`       | `InitState` → `GreaterState`   | Start potential `>` or `>=`                        |
| `=`       | `GreaterState` → `ResultState` | Second `=` found; emit `GreaterOrEqualToken(">=")` |

**Tokens from Row 2**: 16 tokens

#### Processing Row 3: `main = max(square(3), square(4))`

Key observations:

- `3` and `4` → `NumberToken` with parsed `num` values
- Nested parentheses are tokenized independently

Number tokenization for `3`:

| Character | State Transition               | Action                                           |
| --------- | ------------------------------ | ------------------------------------------------ |
| `3`       | `InitState` → `IntegerState`   | Start number, lexeme = `"3"`                     |
| `)`       | `IntegerState` → `ResultState` | Delimiter found; `back()`, emit `NumberToken(3)` |

**Tokens from Row 3**: 14 tokens

### Complete Output

The `LexicalAnalyzer` produces a `List<Token>` with **38 tokens**:

#### Row 1 Tokens: `square(n) = n * n`

| Index | Token Type              | Value      | Location |
| ----- | ----------------------- | ---------- | -------- |
| 0     | `IdentifierToken`       | `"square"` | [1, 1]   |
| 1     | `OpenParenthesisToken`  | `"("`      | [1, 7]   |
| 2     | `IdentifierToken`       | `"n"`      | [1, 8]   |
| 3     | `CloseParenthesisToken` | `")"`      | [1, 9]   |
| 4     | `AssignToken`           | `"="`      | [1, 11]  |
| 5     | `IdentifierToken`       | `"n"`      | [1, 13]  |
| 6     | `AsteriskToken`         | `"*"`      | [1, 15]  |
| 7     | `IdentifierToken`       | `"n"`      | [1, 17]  |

#### Row 2 Tokens: `max(a, b) = if (a >= b) a else b`

| Index | Token Type              | Value    | Location |
| ----- | ----------------------- | -------- | -------- |
| 8     | `IdentifierToken`       | `"max"`  | [2, 1]   |
| 9     | `OpenParenthesisToken`  | `"("`    | [2, 4]   |
| 10    | `IdentifierToken`       | `"a"`    | [2, 5]   |
| 11    | `CommaToken`            | `","`    | [2, 6]   |
| 12    | `IdentifierToken`       | `"b"`    | [2, 8]   |
| 13    | `CloseParenthesisToken` | `")"`    | [2, 9]   |
| 14    | `AssignToken`           | `"="`    | [2, 11]  |
| 15    | `IfToken`               | `"if"`   | [2, 13]  |
| 16    | `OpenParenthesisToken`  | `"("`    | [2, 16]  |
| 17    | `IdentifierToken`       | `"a"`    | [2, 17]  |
| 18    | `GreaterOrEqualToken`   | `">="`   | [2, 19]  |
| 19    | `IdentifierToken`       | `"b"`    | [2, 22]  |
| 20    | `CloseParenthesisToken` | `")"`    | [2, 23]  |
| 21    | `IdentifierToken`       | `"a"`    | [2, 25]  |
| 22    | `ElseToken`             | `"else"` | [2, 27]  |
| 23    | `IdentifierToken`       | `"b"`    | [2, 32]  |

#### Row 3 Tokens: `main = max(square(3), square(4))`

| Index | Token Type              | Value      | Location |
| ----- | ----------------------- | ---------- | -------- |
| 24    | `IdentifierToken`       | `"main"`   | [3, 1]   |
| 25    | `AssignToken`           | `"="`      | [3, 6]   |
| 26    | `IdentifierToken`       | `"max"`    | [3, 8]   |
| 27    | `OpenParenthesisToken`  | `"("`      | [3, 11]  |
| 28    | `IdentifierToken`       | `"square"` | [3, 12]  |
| 29    | `OpenParenthesisToken`  | `"("`      | [3, 18]  |
| 30    | `NumberToken`           | `3`        | [3, 19]  |
| 31    | `CloseParenthesisToken` | `")"`      | [3, 20]  |
| 32    | `CommaToken`            | `","`      | [3, 21]  |
| 33    | `IdentifierToken`       | `"square"` | [3, 23]  |
| 34    | `OpenParenthesisToken`  | `"("`      | [3, 29]  |
| 35    | `NumberToken`           | `4`        | [3, 30]  |
| 36    | `CloseParenthesisToken` | `")"`      | [3, 31]  |
| 37    | `CloseParenthesisToken` | `")"`      | [3, 32]  |

### Summary

| Property              | Value                    |
| --------------------- | ------------------------ |
| Input type            | `List<Character>`        |
| Output type           | `List<Token>`            |
| Input length          | 84 characters            |
| Output length         | 38 tokens                |
| Whitespace characters | 19 (skipped)             |
| Identifiers           | 15                       |
| Keywords              | 2 (`if`, `else`)         |
| Numbers               | 2 (`3`, `4`)             |
| Operators             | 5 (`=` x3, `*`, `>=`)    |
| Delimiters            | 14 (parentheses, commas) |

### Key Observations

1. **Whitespace elimination**: All 19 whitespace characters (16 spaces and 3 newlines) are discarded—they served only to delimit tokens.

2. **Keyword detection at boundary**: `if` and `else` are recognized as keywords only when the complete lexeme is checked. The lexer accumulates characters in `IdentifierState` and calls `_identifierOrKeywordToken()` at the delimiter.

3. **Lookahead pattern**: Two-character operators like `>=` use lookahead. `GreaterState` peeks at the next character; if it's `=`, the compound token is emitted. Otherwise, `iterator.back()` un-consumes the character.

4. **Single-character delimiters**: Parentheses, commas, and brackets are emitted directly from `InitState` without entering an intermediate state.

5. **Typed token values**: `NumberToken` parses the lexeme to `num` at construction time. The tokens for `3` and `4` store the actual numeric values, not strings.

6. **Location preservation**: Each token retains the location of its first character, enabling precise error messages in later stages.

---

## Stage 3: Syntactic Analyzer

**Files**: `lib/compiler/syntactic/syntactic_analyzer.dart`, `lib/compiler/syntactic/expression_parser.dart`

The syntactic analyzer (parser) converts the token list into a list of `FunctionDefinition` objects. Each definition contains a name, parameter list, and an expression tree. The parser uses a **state machine** for function definitions and a **recursive descent parser** for expressions.

### Transformation

**Input**: `List<Token>` (38 tokens)

**Output**: `List<FunctionDefinition>` (3 function definitions with expression trees)

### Step-by-Step Processing

The analyzer uses two parsing mechanisms:

1. **State machine** — Parses the function signature (name and parameters)
2. **Recursive descent** — Parses the function body (expression tree)

#### Parsing Function 1: `square(n) = n * n`

**State Machine Trace:**

| Token                       | State Transition                                                 | Action                |
| --------------------------- | ---------------------------------------------------------------- | --------------------- |
| `IdentifierToken("square")` | `InitState` → `FunctionNameState`                                | Set name = `"square"` |
| `OpenParenthesisToken`      | `FunctionNameState` → `FunctionWithParametersState`              | Expect parameters     |
| `IdentifierToken("n")`      | `FunctionWithParametersState` → `FunctionWithNewParametersState` | Add parameter `"n"`   |
| `CloseParenthesisToken`     | `FunctionWithNewParametersState` → `FunctionParametrizedState`   | Parameters complete   |
| `AssignToken`               | `FunctionParametrizedState` → `ResultState`                      | Parse body expression |

**Expression Parsing for `n * n`:**

The expression parser uses recursive descent with operator precedence. For `n * n`:

```
expression()
  └─ ifExpression()
       └─ equality()
            └─ logicOr()
                 └─ logicAnd()
                      └─ comparison()
                           └─ term()
                                └─ factor()  ← multiplication handled here
```

| Step | Method                   | Token                  | Action                                     |
| ---- | ------------------------ | ---------------------- | ------------------------------------------ |
| 1    | `factor()` → `primary()` | `IdentifierToken("n")` | Return `IdentifierExpression("n")`         |
| 2    | `factor()`               | `AsteriskToken("*")`   | Match `*`, save as operator                |
| 3    | `factor()` → `primary()` | `IdentifierToken("n")` | Return `IdentifierExpression("n")`         |
| 4    | `factor()`               | —                      | Build `CallExpression.fromBinaryOperation` |

**Desugaring**: The binary `n * n` becomes `*(n, n)` — a call to the `*` function with two arguments.

**Result:**

```
FunctionDefinition(
  name: "square",
  parameters: ["n"],
  expression: CallExpression(
    callee: IdentifierExpression("*"),
    arguments: [
      IdentifierExpression("n"),
      IdentifierExpression("n")
    ]
  )
)
```

#### Parsing Function 2: `max(a, b) = if (a >= b) a else b`

**State Machine Trace:**

| Token                    | State Transition                                                     | Action                |
| ------------------------ | -------------------------------------------------------------------- | --------------------- |
| `IdentifierToken("max")` | `InitState` → `FunctionNameState`                                    | Set name = `"max"`    |
| `OpenParenthesisToken`   | `FunctionNameState` → `FunctionWithParametersState`                  | Expect parameters     |
| `IdentifierToken("a")`   | `FunctionWithParametersState` → `FunctionWithNewParametersState`     | Add parameter `"a"`   |
| `CommaToken`             | `FunctionWithNewParametersState` → `FunctionWithNextParametersState` | Expect next parameter |
| `IdentifierToken("b")`   | `FunctionWithNextParametersState` → `FunctionWithNewParametersState` | Add parameter `"b"`   |
| `CloseParenthesisToken`  | `FunctionWithNewParametersState` → `FunctionParametrizedState`       | Parameters complete   |
| `AssignToken`            | `FunctionParametrizedState` → `ResultState`                          | Parse body expression |

**Expression Parsing for `if (a >= b) a else b`:**

The `if` expression has the lowest precedence (level 1):

| Step | Method            | Token                   | Action                             |
| ---- | ----------------- | ----------------------- | ---------------------------------- |
| 1    | `ifExpression()`  | `IfToken("if")`         | Match `if`, start conditional      |
| 2    | `ifExpression()`  | `OpenParenthesisToken`  | Consume `(`                        |
| 3    | _parse condition_ | —                       | Recursively parse `a >= b`         |
| 4    | `ifExpression()`  | `CloseParenthesisToken` | Consume `)`                        |
| 5    | _parse ifTrue_    | `IdentifierToken("a")`  | Return `IdentifierExpression("a")` |
| 6    | `ifExpression()`  | `ElseToken("else")`     | Consume `else`                     |
| 7    | _parse ifFalse_   | `IdentifierToken("b")`  | Return `IdentifierExpression("b")` |

**Parsing the condition `a >= b`:**

| Step | Method                       | Token                       | Action                                     |
| ---- | ---------------------------- | --------------------------- | ------------------------------------------ |
| 1    | `comparison()` → `primary()` | `IdentifierToken("a")`      | Return `IdentifierExpression("a")`         |
| 2    | `comparison()`               | `GreaterOrEqualToken(">=")` | Match `>=`, save as operator               |
| 3    | `comparison()` → `primary()` | `IdentifierToken("b")`      | Return `IdentifierExpression("b")`         |
| 4    | `comparison()`               | —                           | Build `CallExpression.fromBinaryOperation` |

**Desugaring**: The `if` expression becomes `if(condition, ifTrue, ifFalse)` — a call to the `if` function with three arguments.

**Result:**

```
FunctionDefinition(
  name: "max",
  parameters: ["a", "b"],
  expression: CallExpression(
    callee: IdentifierExpression("if"),
    arguments: [
      CallExpression(                      // condition: a >= b
        callee: IdentifierExpression(">="),
        arguments: [
          IdentifierExpression("a"),
          IdentifierExpression("b")
        ]
      ),
      IdentifierExpression("a"),           // ifTrue
      IdentifierExpression("b")            // ifFalse
    ]
  )
)
```

#### Parsing Function 3: `main = max(square(3), square(4))`

**State Machine Trace (nullary function):**

| Token                     | State Transition                    | Action                    |
| ------------------------- | ----------------------------------- | ------------------------- |
| `IdentifierToken("main")` | `InitState` → `FunctionNameState`   | Set name = `"main"`       |
| `AssignToken`             | `FunctionNameState` → `ResultState` | No parameters; parse body |

**Expression Parsing for `max(square(3), square(4))`:**

Function calls are handled at the `call()` level (precedence 10):

| Step | Method                 | Token                    | Action                               |
| ---- | ---------------------- | ------------------------ | ------------------------------------ |
| 1    | `call()` → `primary()` | `IdentifierToken("max")` | Return `IdentifierExpression("max")` |
| 2    | `call()`               | `OpenParenthesisToken`   | Match `(`, start argument list       |
| 3    | `finishCall()`         | —                        | Parse first argument: `square(3)`    |
| 4    | `finishCall()`         | `CommaToken`             | Match `,`, continue arguments        |
| 5    | `finishCall()`         | —                        | Parse second argument: `square(4)`   |
| 6    | `finishCall()`         | `CloseParenthesisToken`  | Consume `)`, complete call           |

**Parsing `square(3)`:**

| Step | Method                       | Token                       | Action                                  |
| ---- | ---------------------------- | --------------------------- | --------------------------------------- |
| 1    | `call()` → `primary()`       | `IdentifierToken("square")` | Return `IdentifierExpression("square")` |
| 2    | `call()`                     | `OpenParenthesisToken`      | Match `(`                               |
| 3    | `finishCall()` → `primary()` | `NumberToken(3)`            | Return `NumberExpression(3)`            |
| 4    | `finishCall()`               | `CloseParenthesisToken`     | Consume `)`                             |

**Result:**

```
FunctionDefinition(
  name: "main",
  parameters: [],
  expression: CallExpression(
    callee: IdentifierExpression("max"),
    arguments: [
      CallExpression(
        callee: IdentifierExpression("square"),
        arguments: [NumberExpression(3)]
      ),
      CallExpression(
        callee: IdentifierExpression("square"),
        arguments: [NumberExpression(4)]
      )
    ]
  )
)
```

### Complete Output

The `SyntacticAnalyzer` produces a `List<FunctionDefinition>` with **3 definitions**:

| Index | Name     | Parameters   | Expression (desugared)      |
| ----- | -------- | ------------ | --------------------------- |
| 0     | `square` | `["n"]`      | `*(n, n)`                   |
| 1     | `max`    | `["a", "b"]` | `if(>=(a, b), a, b)`        |
| 2     | `main`   | `[]`         | `max(square(3), square(4))` |

### Expression Tree Visualization

Brackets `[row, col]` indicate the source location of each expression node.

```
square(n) = n * n
─────────────────
      CallExpression [1, 15]
      ├─ callee: IdentifierExpression("*")
      └─ arguments:
         ├─ IdentifierExpression("n") [1, 13]
         └─ IdentifierExpression("n") [1, 17]

max(a, b) = if (a >= b) a else b
────────────────────────────────
      CallExpression [2, 13]
      ├─ callee: IdentifierExpression("if")
      └─ arguments:
         ├─ CallExpression [2, 19]           ← condition
         │  ├─ callee: IdentifierExpression(">=")
         │  └─ arguments:
         │     ├─ IdentifierExpression("a") [2, 17]
         │     └─ IdentifierExpression("b") [2, 22]
         ├─ IdentifierExpression("a") [2, 25] ← ifTrue
         └─ IdentifierExpression("b") [2, 32] ← ifFalse

main = max(square(3), square(4))
────────────────────────────────
      CallExpression [3, 8]
      ├─ callee: IdentifierExpression("max")
      └─ arguments:
         ├─ CallExpression [3, 12]
         │  ├─ callee: IdentifierExpression("square")
         │  └─ arguments:
         │     └─ NumberExpression(3) [3, 19]
         └─ CallExpression [3, 23]
            ├─ callee: IdentifierExpression("square")
            └─ arguments:
               └─ NumberExpression(4) [3, 30]
```

### Summary

| Property                       | Value                      |
| ------------------------------ | -------------------------- |
| Input type                     | `List<Token>`              |
| Output type                    | `List<FunctionDefinition>` |
| Input length                   | 38 tokens                  |
| Output length                  | 3 function definitions     |
| Expression nodes created       | 15                         |
| Identifiers desugared to calls | 3 (`*`, `>=`, `if`)        |

### Key Observations

1. **Operator desugaring**: All operators (`*`, `>=`) and control flow (`if`) are converted to `CallExpression` nodes. This unifies computation as function application, simplifying later stages.

2. **Precedence via recursion**: The recursive descent parser encodes precedence through the call stack. `factor()` (multiplication) calls `index()` which calls `unary()`, ensuring `*` binds tighter than `+`.

3. **Two parsing modes**: The state machine handles the flat structure of function signatures, while recursive descent handles the nested structure of expressions.

4. **Location preservation**: Each expression node stores its source location from the originating token, enabling precise error messages in semantic analysis.

5. **Nullary vs parameterized**: `main` has no parameters and uses the shorter path (`FunctionNameState` → `ResultState`), while `square` and `max` go through the parameter-parsing states.

6. **Uniform call representation**: User-defined calls (`max(...)`, `square(...)`) and desugared operators (`*(n, n)`) use the same `CallExpression` structure.

---

## Stage 4: Semantic Analyzer

**File**: `lib/compiler/semantic/semantic_analyzer.dart`

The semantic analyzer validates function definitions and produces `IntermediateRepresentation` containing a **semantic IR** that preserves source locations and resolved references. This stage performs identifier resolution, arity checking, and duplicate detection.

### Transformation

**Input**: `List<FunctionDefinition>` (3 function definitions with expression trees)

**Output**: `IntermediateRepresentation` (semantic IR with resolved references)

### Two-Pass Analysis

The analyzer operates in two passes:

1. **First pass** — Extract function signatures, check for duplicates
2. **Second pass** — Build semantic IR, resolve identifiers, validate calls

#### First Pass: Signature Extraction

| Step | Action                           | Result                                                            |
| ---- | -------------------------------- | ----------------------------------------------------------------- |
| 1    | Load standard library signatures | 200+ built-in functions including `*`, `>=`, `if`, `+`, `-`, etc. |
| 2    | Extract `square` signature       | `FunctionSignature(name: "square", parameters: [n])`              |
| 3    | Extract `max` signature          | `FunctionSignature(name: "max", parameters: [a, b])`              |
| 4    | Extract `main` signature         | `FunctionSignature(name: "main", parameters: [])`                 |
| 5    | Check for duplicate functions    | None found (no conflicts with stdlib or each other)               |
| 6    | Check for duplicate parameters   | None found within any function                                    |

The combined signature map now contains all custom and standard library functions for identifier resolution.

#### Second Pass: Semantic IR Construction

For each function, the analyzer:

1. Tracks available parameters (the function's parameter names)
2. Recursively processes the expression tree
3. Resolves each identifier to either a bound variable or a function reference
4. Validates call arity for direct function calls
5. Tracks used parameters to detect unused ones

### Processing Function 1: `square(n) = n * n`

**Context:**

- Available parameters: `{"n"}`
- Used parameters: `{}` (initially empty)

**Expression Tree (from Stage 3):**

```
CallExpression
├─ callee: IdentifierExpression("*")
└─ arguments:
   ├─ IdentifierExpression("n")
   └─ IdentifierExpression("n")
```

**Semantic Analysis Trace:**

| Step | Expression                  | Check                             | Result                                      |
| ---- | --------------------------- | --------------------------------- | ------------------------------------------- |
| 1    | `CallExpression`            | Process arguments first           | —                                           |
| 2    | `IdentifierExpression("n")` | Is "n" a parameter? Yes           | `SemanticBoundVariableNode("n")`, mark used |
| 3    | `IdentifierExpression("n")` | Is "n" a parameter? Yes           | `SemanticBoundVariableNode("n")`            |
| 4    | `IdentifierExpression("*")` | Is "\*" a parameter? No           | Check functions                             |
| 5    | `IdentifierExpression("*")` | Is "\*" a function? Yes (stdlib)  | `SemanticIdentifierNode("*", signature)`    |
| 6    | `CallExpression`            | Arity check: `*` expects 2, got 2 | ✓ Valid                                     |
| 7    | —                           | Build `SemanticCallNode`          | Complete                                    |

**Unused Parameter Check:**

- Parameters: `["n"]`
- Used: `{"n"}`
- Result: No warnings

**Semantic IR Output:**

```
SemanticFunction(
  name: "square",
  parameters: [Parameter("n")],
  body: SemanticCallNode [1, 15]
    ├─ callee: SemanticIdentifierNode("*", signature=*(a, b))
    └─ arguments:
       ├─ SemanticBoundVariableNode("n") [1, 13]
       └─ SemanticBoundVariableNode("n") [1, 17]
)
```

### Processing Function 2: `max(a, b) = if (a >= b) a else b`

**Context:**

- Available parameters: `{"a", "b"}`
- Used parameters: `{}` (initially empty)

**Semantic Analysis Trace:**

| Step | Expression                         | Check                        | Result                           |
| ---- | ---------------------------------- | ---------------------------- | -------------------------------- |
| 1    | Outer `CallExpression`             | Process arguments            | —                                |
| 2    | Inner `CallExpression` (condition) | Process `>=(a, b)`           | —                                |
| 3    | `IdentifierExpression("a")`        | Parameter? Yes               | `SemanticBoundVariableNode("a")` |
| 4    | `IdentifierExpression("b")`        | Parameter? Yes               | `SemanticBoundVariableNode("b")` |
| 5    | `IdentifierExpression(">=")`       | Function? Yes (stdlib)       | `SemanticIdentifierNode(">=")`   |
| 6    | Inner call                         | Arity: `>=` expects 2, got 2 | ✓ Valid                          |
| 7    | `IdentifierExpression("a")`        | Parameter? Yes               | `SemanticBoundVariableNode("a")` |
| 8    | `IdentifierExpression("b")`        | Parameter? Yes               | `SemanticBoundVariableNode("b")` |
| 9    | `IdentifierExpression("if")`       | Function? Yes (stdlib)       | `SemanticIdentifierNode("if")`   |
| 10   | Outer call                         | Arity: `if` expects 3, got 3 | ✓ Valid                          |

**Unused Parameter Check:**

- Parameters: `["a", "b"]`
- Used: `{"a", "b"}`
- Result: No warnings

**Semantic IR Output:**

```
SemanticFunction(
  name: "max",
  parameters: [Parameter("a"), Parameter("b")],
  body: SemanticCallNode [2, 13]
    ├─ callee: SemanticIdentifierNode("if", signature=if(a, b, c))
    └─ arguments:
       ├─ SemanticCallNode [2, 19]
       │  ├─ callee: SemanticIdentifierNode(">=", signature=>=(a, b))
       │  └─ arguments:
       │     ├─ SemanticBoundVariableNode("a") [2, 17]
       │     └─ SemanticBoundVariableNode("b") [2, 22]
       ├─ SemanticBoundVariableNode("a") [2, 25]
       └─ SemanticBoundVariableNode("b") [2, 32]
)
```

### Processing Function 3: `main = max(square(3), square(4))`

**Context:**

- Available parameters: `{}` (nullary function)
- Used parameters: `{}` (initially empty)

**Semantic Analysis Trace:**

| Step | Expression                       | Check                            | Result                             |
| ---- | -------------------------------- | -------------------------------- | ---------------------------------- |
| 1    | Outer `CallExpression`           | Process arguments                | —                                  |
| 2    | Inner `CallExpression`           | Process `square(3)`              | —                                  |
| 3    | `NumberExpression(3)`            | Literal                          | `SemanticNumberNode(3)`            |
| 4    | `IdentifierExpression("square")` | Function? Yes (custom)           | `SemanticIdentifierNode("square")` |
| 5    | Inner call                       | Arity: `square` expects 1, got 1 | ✓ Valid                            |
| 6    | Inner `CallExpression`           | Process `square(4)`              | —                                  |
| 7    | `NumberExpression(4)`            | Literal                          | `SemanticNumberNode(4)`            |
| 8    | `IdentifierExpression("square")` | Function? Yes (custom)           | `SemanticIdentifierNode("square")` |
| 9    | Inner call                       | Arity: `square` expects 1, got 1 | ✓ Valid                            |
| 10   | `IdentifierExpression("max")`    | Function? Yes (custom)           | `SemanticIdentifierNode("max")`    |
| 11   | Outer call                       | Arity: `max` expects 2, got 2    | ✓ Valid                            |

**Semantic IR Output:**

```
SemanticFunction(
  name: "main",
  parameters: [],
  body: SemanticCallNode [3, 8]
    ├─ callee: SemanticIdentifierNode("max", signature=max(a, b))
    └─ arguments:
       ├─ SemanticCallNode [3, 12]
       │  ├─ callee: SemanticIdentifierNode("square", signature=square(n))
       │  └─ arguments:
       │     └─ SemanticNumberNode(3) [3, 19]
       └─ SemanticCallNode [3, 23]
          ├─ callee: SemanticIdentifierNode("square", signature=square(n))
          └─ arguments:
             └─ SemanticNumberNode(4) [3, 30]
)
```

### Complete Output

The `SemanticAnalyzer` produces an `IntermediateRepresentation` object:

```
IntermediateRepresentation(
  customFunctions: {
    "square": SemanticFunction(...),
    "max": SemanticFunction(...),
    "main": SemanticFunction(...)
  },
  standardLibrarySignatures: {
    "*": FunctionSignature(name: "*", arity: 2),
    ">=": FunctionSignature(name: ">=", arity: 2),
    "if": FunctionSignature(name: "if", arity: 3),
    ... (200+ more)
  },
  warnings: []
)
```

### Identifier Resolution Summary

| Expression      | Location         | Resolved To     | Type                        |
| --------------- | ---------------- | --------------- | --------------------------- |
| `n` (in square) | [1, 13], [1, 17] | Parameter "n"   | `SemanticBoundVariableNode` |
| `*`             | [1, 15]          | Stdlib function | `SemanticIdentifierNode`    |
| `a` (in max)    | [2, 17], [2, 25] | Parameter "a"   | `SemanticBoundVariableNode` |
| `b` (in max)    | [2, 22], [2, 32] | Parameter "b"   | `SemanticBoundVariableNode` |
| `>=`            | [2, 19]          | Stdlib function | `SemanticIdentifierNode`    |
| `if`            | [2, 13]          | Stdlib function | `SemanticIdentifierNode`    |
| `square`        | [3, 12], [3, 23] | Custom function | `SemanticIdentifierNode`    |
| `max`           | [3, 8]           | Custom function | `SemanticIdentifierNode`    |
| `3`             | [3, 19]          | Number literal  | `SemanticNumberNode`        |
| `4`             | [3, 30]          | Number literal  | `SemanticNumberNode`        |

### Summary

| Property                             | Value                        |
| ------------------------------------ | ---------------------------- |
| Input type                           | `List<FunctionDefinition>`   |
| Output type                          | `IntermediateRepresentation` |
| Custom functions analyzed            | 3                            |
| Standard library functions available | 200+                         |
| Identifiers resolved                 | 10                           |
| Bound variables created              | 6                            |
| Function references created          | 6                            |
| Arity checks performed               | 6                            |
| Warnings generated                   | 0                            |

### Key Observations

1. **Two-pass design**: The first pass collects all signatures before the second pass resolves identifiers. This allows forward references — `main` can call `square` even though `square` is defined earlier.

2. **Parameter vs function resolution**: Each identifier is first checked against available parameters, then against the combined function map. This shadowing rule means a parameter named `foo` would hide any function named `foo` (custom or stdlib).

3. **Arity validation**: Direct calls (where the callee is an identifier) have their argument count validated at compile time. Indirect calls (e.g., `f()(x)` where `f` returns a function) are deferred to runtime.

4. **Semantic nodes preserve locations**: Unlike the runtime terms produced later, semantic nodes retain source positions for error reporting and debugging.

5. **Bound variables vs identifiers**: Parameters become `SemanticBoundVariableNode` (a runtime substitution target), while functions become `SemanticIdentifierNode` (a reference to be resolved at runtime).

6. **No runtime dependencies**: The semantic IR uses `FunctionSignature` instead of `FunctionTerm`, keeping the semantic phase independent of the runtime system.

---

## Stage 5: Lowerer

**File**: `lib/compiler/lowering/lowerer.dart`

The lowerer converts the semantic IR to runtime terms for evaluation. This pass strips source locations and produces the minimal runtime representation needed for the substitution-based evaluation model.

### Transformation

**Input**: `IntermediateRepresentation` (semantic IR with resolved references)

**Output**: `Map<String, FunctionTerm>` (runtime functions for evaluation)

### Lowering Process

The lowerer operates in two phases:

1. **Function lowering** — Convert each `SemanticFunction` to a `CustomFunctionTerm`
2. **Term lowering** — Recursively convert each `SemanticNode` to its runtime `Term` equivalent

#### Term Type Mapping

| Semantic Term               | Runtime Term            | Description                                |
| --------------------------- | ----------------------- | ------------------------------------------ |
| `SemanticBooleanNode`       | `BooleanTerm`           | Boolean literal                            |
| `SemanticNumberNode`        | `NumberTerm`            | Numeric literal                            |
| `SemanticStringNode`        | `StringTerm`            | String literal                             |
| `SemanticListNode`          | `ListTerm`              | List literal with lowered elements         |
| `SemanticMapNode`           | `MapTerm`               | Map literal with lowered entries           |
| `SemanticIdentifierNode`    | `FunctionReferenceTerm` | Function reference with lookup map         |
| `SemanticBoundVariableNode` | `BoundVariableTerm`     | Parameter reference for substitution       |
| `SemanticCallNode`          | `CallTerm`              | Function call with lowered callee and args |

### Lowering Function 1: `square(n) = n * n`

**Input (Semantic IR):**

```
SemanticFunction(
  name: "square",
  parameters: [Parameter("n")],
  body: SemanticCallNode [1, 15]
    ├─ callee: SemanticIdentifierNode("*", signature=*(a, b))
    └─ arguments:
       ├─ SemanticBoundVariableNode("n") [1, 13]
       └─ SemanticBoundVariableNode("n") [1, 17]
)
```

**Lowering Trace:**

| Step | Semantic Term                    | Action                                         | Runtime Term                            |
| ---- | -------------------------------- | ---------------------------------------------- | --------------------------------------- |
| 1    | `SemanticFunction("square")`     | Create `CustomFunctionTerm`, lower body        | —                                       |
| 2    | `SemanticCallNode`               | Lower callee and arguments                     | —                                       |
| 3    | `SemanticIdentifierNode("*")`    | Create `FunctionReferenceTerm("*", functions)` | `FunctionReferenceTerm("*", functions)` |
| 4    | `SemanticBoundVariableNode("n")` | Create `BoundVariableTerm("n")`                | `BoundVariableTerm("n")`                |
| 5    | `SemanticBoundVariableNode("n")` | Create `BoundVariableTerm("n")`                | `BoundVariableTerm("n")`                |
| 6    | `SemanticCallNode`               | Assemble `CallTerm`                            | `CallTerm(callee, arguments)`           |
| 7    | `SemanticFunction("square")`     | Complete `CustomFunctionTerm`                  | `CustomFunctionTerm("square", ...)`     |

**Output (Runtime Term):**

```
CustomFunctionTerm(
  name: "square",
  parameters: [Parameter("n")],
  term: CallTerm(
    callee: FunctionReferenceTerm("*", functions),
    arguments: [
      BoundVariableTerm("n"),
      BoundVariableTerm("n")
    ]
  )
)
```

### Lowering Function 2: `max(a, b) = if (a >= b) a else b`

**Input (Semantic IR):**

```
SemanticFunction(
  name: "max",
  parameters: [Parameter("a"), Parameter("b")],
  body: SemanticCallNode [2, 13]
    ├─ callee: SemanticIdentifierNode("if", signature=if(a, b, c))
    └─ arguments:
       ├─ SemanticCallNode [2, 19]
       │  ├─ callee: SemanticIdentifierNode(">=", signature=>=(a, b))
       │  └─ arguments:
       │     ├─ SemanticBoundVariableNode("a") [2, 17]
       │     └─ SemanticBoundVariableNode("b") [2, 22]
       ├─ SemanticBoundVariableNode("a") [2, 25]
       └─ SemanticBoundVariableNode("b") [2, 32]
)
```

**Lowering Trace:**

| Step | Semantic Term                    | Action                         | Runtime Term                       |
| ---- | -------------------------------- | ------------------------------ | ---------------------------------- |
| 1    | `SemanticFunction("max")`        | Create `CustomFunctionTerm`    | —                                  |
| 2    | Outer `SemanticCallNode`         | Lower callee and arguments     | —                                  |
| 3    | `SemanticIdentifierNode("if")`   | Create `FunctionReferenceTerm` | `FunctionReferenceTerm("if", ...)` |
| 4    | Inner `SemanticCallNode`         | Lower condition call           | —                                  |
| 5    | `SemanticIdentifierNode(">=")`   | Create `FunctionReferenceTerm` | `FunctionReferenceTerm(">=", ...)` |
| 6    | `SemanticBoundVariableNode("a")` | Create `BoundVariableTerm`     | `BoundVariableTerm("a")`           |
| 7    | `SemanticBoundVariableNode("b")` | Create `BoundVariableTerm`     | `BoundVariableTerm("b")`           |
| 8    | Inner `SemanticCallNode`         | Assemble condition `CallTerm`  | `CallTerm(>=, [a, b])`             |
| 9    | `SemanticBoundVariableNode("a")` | Create `BoundVariableTerm`     | `BoundVariableTerm("a")`           |
| 10   | `SemanticBoundVariableNode("b")` | Create `BoundVariableTerm`     | `BoundVariableTerm("b")`           |
| 11   | Outer `SemanticCallNode`         | Assemble outer `CallTerm`      | `CallTerm(if, [cond, a, b])`       |
| 12   | `SemanticFunction("max")`        | Complete `CustomFunctionTerm`  | `CustomFunctionTerm("max", ...)`   |

**Output (Runtime Term):**

```
CustomFunctionTerm(
  name: "max",
  parameters: [Parameter("a"), Parameter("b")],
  term: CallTerm(
    callee: FunctionReferenceTerm("if", functions),
    arguments: [
      CallTerm(                              // condition
        callee: FunctionReferenceTerm(">=", functions),
        arguments: [
          BoundVariableTerm("a"),
          BoundVariableTerm("b")
        ]
      ),
      BoundVariableTerm("a"),                // ifTrue
      BoundVariableTerm("b")                 // ifFalse
    ]
  )
)
```

### Lowering Function 3: `main = max(square(3), square(4))`

**Input (Semantic IR):**

```
SemanticFunction(
  name: "main",
  parameters: [],
  body: SemanticCallNode [3, 8]
    ├─ callee: SemanticIdentifierNode("max", signature=max(a, b))
    └─ arguments:
       ├─ SemanticCallNode [3, 12]
       │  ├─ callee: SemanticIdentifierNode("square", signature=square(n))
       │  └─ arguments:
       │     └─ SemanticNumberNode(3) [3, 19]
       └─ SemanticCallNode [3, 23]
          ├─ callee: SemanticIdentifierNode("square", signature=square(n))
          └─ arguments:
             └─ SemanticNumberNode(4) [3, 30]
)
```

**Lowering Trace:**

| Step | Semantic Term                      | Action                         | Runtime Term                           |
| ---- | ---------------------------------- | ------------------------------ | -------------------------------------- |
| 1    | `SemanticFunction("main")`         | Create `CustomFunctionTerm`    | —                                      |
| 2    | Outer `SemanticCallNode`           | Lower callee and arguments     | —                                      |
| 3    | `SemanticIdentifierNode("max")`    | Create `FunctionReferenceTerm` | `FunctionReferenceTerm("max", ...)`    |
| 4    | First inner `SemanticCallNode`     | Lower `square(3)`              | —                                      |
| 5    | `SemanticIdentifierNode("square")` | Create `FunctionReferenceTerm` | `FunctionReferenceTerm("square", ...)` |
| 6    | `SemanticNumberNode(3)`            | Create `NumberTerm`            | `NumberTerm(3)`                        |
| 7    | First inner `SemanticCallNode`     | Assemble `CallTerm`            | `CallTerm(square, [3])`                |
| 8    | Second inner `SemanticCallNode`    | Lower `square(4)`              | —                                      |
| 9    | `SemanticIdentifierNode("square")` | Create `FunctionReferenceTerm` | `FunctionReferenceTerm("square", ...)` |
| 10   | `SemanticNumberNode(4)`            | Create `NumberTerm`            | `NumberTerm(4)`                        |
| 11   | Second inner `SemanticCallNode`    | Assemble `CallTerm`            | `CallTerm(square, [4])`                |
| 12   | Outer `SemanticCallNode`           | Assemble outer `CallTerm`      | `CallTerm(max, [sq(3), sq(4)])`        |
| 13   | `SemanticFunction("main")`         | Complete `CustomFunctionTerm`  | `CustomFunctionTerm("main", ...)`      |

**Output (Runtime Term):**

```
CustomFunctionTerm(
  name: "main",
  parameters: [],
  term: CallTerm(
    callee: FunctionReferenceTerm("max", functions),
    arguments: [
      CallTerm(
        callee: FunctionReferenceTerm("square", functions),
        arguments: [NumberTerm(3)]
      ),
      CallTerm(
        callee: FunctionReferenceTerm("square", functions),
        arguments: [NumberTerm(4)]
      )
    ]
  )
)
```

### Complete Output

The `Lowerer` produces a `Map<String, FunctionTerm>` combining custom and standard library functions:

```
{
  // Custom functions (lowered from semantic IR)
  "square": CustomFunctionTerm(
    name: "square",
    parameters: [Parameter("n")],
    term: CallTerm(FunctionReferenceTerm("*"), [BoundVariableTerm("n"), BoundVariableTerm("n")])
  ),
  "max": CustomFunctionTerm(
    name: "max",
    parameters: [Parameter("a"), Parameter("b")],
    term: CallTerm(FunctionReferenceTerm("if"), [CallTerm(...), BoundVariableTerm("a"), BoundVariableTerm("b")])
  ),
  "main": CustomFunctionTerm(
    name: "main",
    parameters: [],
    term: CallTerm(FunctionReferenceTerm("max"), [CallTerm(...), CallTerm(...)])
  ),

  // Standard library functions (from StandardLibrary.get())
  "*": NativeFunctionTerm(...),
  ">=": NativeFunctionTerm(...),
  "if": NativeFunctionTerm(...),
  ... (200+ more)
}
```

### Runtime Term Tree Visualization

Source locations are stripped; the tree shows only runtime structure.

```
square(n) = n * n
─────────────────
      CustomFunctionTerm("square")
      └─ term: CallTerm
         ├─ callee: FunctionReferenceTerm("*") → functions map
         └─ arguments:
            ├─ BoundVariableTerm("n")
            └─ BoundVariableTerm("n")

max(a, b) = if (a >= b) a else b
────────────────────────────────
      CustomFunctionTerm("max")
      └─ term: CallTerm
         ├─ callee: FunctionReferenceTerm("if") → functions map
         └─ arguments:
            ├─ CallTerm                    ← condition
            │  ├─ callee: FunctionReferenceTerm(">=") → functions map
            │  └─ arguments:
            │     ├─ BoundVariableTerm("a")
            │     └─ BoundVariableTerm("b")
            ├─ BoundVariableTerm("a")      ← ifTrue
            └─ BoundVariableTerm("b")      ← ifFalse

main = max(square(3), square(4))
────────────────────────────────
      CustomFunctionTerm("main")
      └─ term: CallTerm
         ├─ callee: FunctionReferenceTerm("max") → functions map
         └─ arguments:
            ├─ CallTerm
            │  ├─ callee: FunctionReferenceTerm("square") → functions map
            │  └─ arguments:
            │     └─ NumberTerm(3)
            └─ CallTerm
               ├─ callee: FunctionReferenceTerm("square") → functions map
               └─ arguments:
                  └─ NumberTerm(4)
```

### Summary

| Property                 | Value                        |
| ------------------------ | ---------------------------- |
| Input type               | `IntermediateRepresentation` |
| Output type              | `Map<String, FunctionTerm>`  |
| Custom functions lowered | 3                            |
| Stdlib functions added   | 200+                         |
| Semantic nodes lowered   | 15                           |
| Runtime terms created    | 15                           |
| Source locations         | Stripped                     |

### Key Observations

1. **Location stripping**: All source position information is discarded. Runtime terms contain only what is needed for evaluation. Error reporting with source locations must use the semantic IR before lowering.

2. **Deferred function resolution**: `FunctionReferenceTerm` stores a reference to the shared `functions` map rather than the resolved `FunctionTerm` directly. This enables forward references and mutual recursion — `main` can reference `square` even if `square` is added to the map after `main` is lowered.

3. **BoundVariableTerm for substitution**: Parameters become `BoundVariableTerm` instances that will be replaced during function application via the `substitute()` method.

4. **Unified function map**: Custom functions (`CustomFunctionTerm`) and standard library functions (`NativeFunctionTerm`) are stored in the same map, enabling uniform lookup during evaluation.

5. **Structural preservation**: The tree structure is preserved exactly — only the node types change. A `SemanticCallNode` with three arguments becomes a `CallTerm` with three arguments.

6. **One-way transformation**: Lowering is irreversible. The semantic IR is the last point where source locations and resolved signatures are available.

---

## Stage 6: Runtime

**Files**: `lib/compiler/runtime/runtime.dart`, `lib/compiler/runtime/term.dart`, `lib/compiler/runtime/bindings.dart`

The runtime evaluates the compiled program by applying **term substitution and reduction**. This is a substitution-based evaluation model consistent with lambda calculus beta-reduction.

### Transformation

**Input**: `Map<String, FunctionTerm>` (runtime functions from lowerer)

**Output**: `Term` (evaluated result)

### Evaluation Model

The runtime follows these steps for each function application:

1. **Reduce the callee** — resolve `FunctionReferenceTerm` to get the actual `FunctionTerm`
2. **Create bindings** — map parameter names to argument terms
3. **Substitute** — replace all `BoundVariableTerm` instances in the function body with their bound values
4. **Reduce** — evaluate the resulting term

### Evaluating `main`

The entry point is `main`, a nullary function that evaluates to the final result.

**Initial Term (from Stage 5):**

```
CallTerm(
  callee: FunctionReferenceTerm("max"),
  arguments: [
    CallTerm(
      callee: FunctionReferenceTerm("square"),
      arguments: [NumberTerm(3)]
    ),
    CallTerm(
      callee: FunctionReferenceTerm("square"),
      arguments: [NumberTerm(4)]
    )
  ]
)
```

### Step-by-Step Evaluation

The evaluation proceeds depth-first, reducing the outer call by first evaluating its callee and arguments.

#### Step 1: Reduce the Outer Call's Callee

| Action                                | Result                  |
| ------------------------------------- | ----------------------- |
| Reduce `FunctionReferenceTerm("max")` | Lookup in functions map |
| Returns `CustomFunctionTerm("max")`   | Function ready to apply |

#### Step 2: Evaluate First Argument — `square(3)`

**2a. Reduce the callee:**

| Action                                   | Result                  |
| ---------------------------------------- | ----------------------- |
| Reduce `FunctionReferenceTerm("square")` | Lookup in functions map |
| Returns `CustomFunctionTerm("square")`   | Function ready to apply |

**2b. Create bindings:**

| Parameter | Argument        |
| --------- | --------------- |
| `n`       | `NumberTerm(3)` |

**2c. Substitute into `square`'s body:**

Before substitution:

```
CallTerm(
  callee: FunctionReferenceTerm("*"),
  arguments: [
    BoundVariableTerm("n"),
    BoundVariableTerm("n")
  ]
)
```

After substitution (bindings: `{n → NumberTerm(3)}`):

```
CallTerm(
  callee: FunctionReferenceTerm("*"),
  arguments: [
    NumberTerm(3),
    NumberTerm(3)
  ]
)
```

**2d. Reduce the substituted term:**

| Action                                        | Result                                   |
| --------------------------------------------- | ---------------------------------------- |
| Reduce `FunctionReferenceTerm("*")`           | Lookup returns `NativeFunctionTerm("*")` |
| Apply `*` to `[NumberTerm(3), NumberTerm(3)]` | Native function evaluates `3 * 3`        |
| Native implementation returns                 | `NumberTerm(9)`                          |

**Result of `square(3)`**: `NumberTerm(9)`

#### Step 3: Evaluate Second Argument — `square(4)`

**3a. Reduce the callee:**

| Action                                   | Result                                 |
| ---------------------------------------- | -------------------------------------- |
| Reduce `FunctionReferenceTerm("square")` | Returns `CustomFunctionTerm("square")` |

**3b. Create bindings:**

| Parameter | Argument        |
| --------- | --------------- |
| `n`       | `NumberTerm(4)` |

**3c. Substitute into `square`'s body:**

After substitution (bindings: `{n → NumberTerm(4)}`):

```
CallTerm(
  callee: FunctionReferenceTerm("*"),
  arguments: [
    NumberTerm(4),
    NumberTerm(4)
  ]
)
```

**3d. Reduce the substituted term:**

| Action                                        | Result                                   |
| --------------------------------------------- | ---------------------------------------- |
| Reduce `FunctionReferenceTerm("*")`           | Lookup returns `NativeFunctionTerm("*")` |
| Apply `*` to `[NumberTerm(4), NumberTerm(4)]` | Native function evaluates `4 * 4`        |
| Native implementation returns                 | `NumberTerm(16)`                         |

**Result of `square(4)`**: `NumberTerm(16)`

#### Step 4: Apply `max` to Evaluated Arguments

**4a. Create bindings:**

| Parameter | Argument         |
| --------- | ---------------- |
| `a`       | `NumberTerm(9)`  |
| `b`       | `NumberTerm(16)` |

**4b. Substitute into `max`'s body:**

Before substitution:

```
CallTerm(
  callee: FunctionReferenceTerm("if"),
  arguments: [
    CallTerm(                              // condition
      callee: FunctionReferenceTerm(">="),
      arguments: [
        BoundVariableTerm("a"),
        BoundVariableTerm("b")
      ]
    ),
    BoundVariableTerm("a"),                // ifTrue
    BoundVariableTerm("b")                 // ifFalse
  ]
)
```

After substitution (bindings: `{a → NumberTerm(9), b → NumberTerm(16)}`):

```
CallTerm(
  callee: FunctionReferenceTerm("if"),
  arguments: [
    CallTerm(                              // condition
      callee: FunctionReferenceTerm(">="),
      arguments: [
        NumberTerm(9),
        NumberTerm(16)
      ]
    ),
    NumberTerm(9),                         // ifTrue
    NumberTerm(16)                         // ifFalse
  ]
)
```

**4c. Reduce the substituted term:**

The `if` function is a native function that implements lazy evaluation — it only evaluates the branch that will be taken.

| Action                               | Result                                   |
| ------------------------------------ | ---------------------------------------- |
| Reduce `FunctionReferenceTerm("if")` | Returns `NativeFunctionTerm("if")`       |
| Evaluate condition first             | Must reduce `>=(9, 16)` before branching |

**4d. Evaluate the condition — `>=(9, 16)`:**

| Action                                          | Result                             |
| ----------------------------------------------- | ---------------------------------- |
| Reduce `FunctionReferenceTerm(">=")`            | Returns `NativeFunctionTerm(">=")` |
| Apply `>=` to `[NumberTerm(9), NumberTerm(16)]` | Native evaluates `9 >= 16`         |
| Native implementation returns                   | `BooleanTerm(false)`               |

**4e. Complete `if` evaluation:**

| Action                                             | Result                    |
| -------------------------------------------------- | ------------------------- |
| Condition is `BooleanTerm(false)`                  | Take the `ifFalse` branch |
| Return `NumberTerm(16)` (lazy — not reduced again) | Already a value           |

**Result of `max(9, 16)`**: `NumberTerm(16)`

#### Step 5: Final Result

The evaluation of `main` completes:

| Expression                  | Evaluates To         |
| --------------------------- | -------------------- |
| `square(3)`                 | `NumberTerm(9)`      |
| `square(4)`                 | `NumberTerm(16)`     |
| `>=(9, 16)`                 | `BooleanTerm(false)` |
| `if(false, 9, 16)`          | `NumberTerm(16)`     |
| `max(square(3), square(4))` | `NumberTerm(16)`     |

**Final output**: `16`

### Evaluation Trace Visualization

```
main
└─ CallTerm(max, [square(3), square(4)])
   │
   ├─ Resolve max → CustomFunctionTerm("max")
   │
   ├─ Evaluate argument 1: square(3)
   │  ├─ Resolve square → CustomFunctionTerm("square")
   │  ├─ Bindings: {n → 3}
   │  ├─ Substitute: *(n, n) → *(3, 3)
   │  └─ Reduce: *(3, 3)
   │     ├─ Resolve * → NativeFunctionTerm("*")
   │     └─ Native: 3 * 3 = 9
   │
   ├─ Evaluate argument 2: square(4)
   │  ├─ Resolve square → CustomFunctionTerm("square")
   │  ├─ Bindings: {n → 4}
   │  ├─ Substitute: *(n, n) → *(4, 4)
   │  └─ Reduce: *(4, 4)
   │     ├─ Resolve * → NativeFunctionTerm("*")
   │     └─ Native: 4 * 4 = 16
   │
   ├─ Bindings: {a → 9, b → 16}
   │
   ├─ Substitute: if(>=(a, b), a, b) → if(>=(9, 16), 9, 16)
   │
   └─ Reduce: if(>=(9, 16), 9, 16)
      ├─ Resolve if → NativeFunctionTerm("if")
      ├─ Evaluate condition: >=(9, 16)
      │  ├─ Resolve >= → NativeFunctionTerm(">=")
      │  └─ Native: 9 >= 16 = false
      ├─ Condition is false → take ifFalse branch
      └─ Return: 16

Result: 16
```

### Native Function Execution

Native functions like `*`, `>=`, and `if` delegate to Dart implementations. Each follows a two-class pattern:

**Definition class** — declares the function signature:

```dart
class OperatorMul extends NativeFunctionTerm {
  const OperatorMul()
    : super(
        name: '*',
        parameters: const [
          Parameter.number('a'),
          Parameter.number('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(...);
}
```

**Evaluation class** — implements the logic:

```dart
class TermWithArguments extends NativeFunctionTermWithArguments {
  @override
  Term reduce() {
    final Term a = arguments[0].reduce();
    final Term b = arguments[1].reduce();

    if ((a is NumberTerm) && (b is NumberTerm)) {
      return NumberTerm(a.value * b.value);
    } else {
      throw InvalidArgumentTypesError(...);
    }
  }
}
```

### Lazy Evaluation in `if`

The `if` function demonstrates lazy evaluation — a key feature of the runtime:

```dart
@override
Term reduce() {
  final Term a = arguments[0].reduce();  // Only condition is evaluated first
  final Term b = arguments[1];           // ifTrue branch (not reduced yet)
  final Term c = arguments[2];           // ifFalse branch (not reduced yet)

  if (a is BooleanTerm) {
    if (a.value) {
      return b.reduce();                 // Only reduce if taken
    } else {
      return c.reduce();                 // Only reduce if taken
    }
  }
  // ...
}
```

This ensures that only the selected branch is evaluated, enabling:

- Short-circuit evaluation
- Infinite data structures (when combined with recursion)
- Efficient conditional computation

### Summary

| Property                   | Value                               |
| -------------------------- | ----------------------------------- |
| Input type                 | `Map<String, FunctionTerm>`         |
| Output type                | `Term` (evaluated result)           |
| Entry point                | `main` function                     |
| Evaluation model           | Substitution-based (beta reduction) |
| Function calls evaluated   | 6                                   |
| Substitutions performed    | 3                                   |
| Native operations executed | 3 (`*` x2, `>=` x1)                 |
| Lazy branches skipped      | 1 (`ifTrue` branch)                 |
| Final result               | `NumberTerm(16)`                    |

### Key Observations

1. **Substitution-based evaluation**: The runtime implements beta reduction from lambda calculus. When a function is applied, its body is copied with bound variables replaced by argument values, then reduced.

2. **Eager argument evaluation**: Arguments to custom functions are evaluated before substitution. In `max(square(3), square(4))`, both `square` calls are evaluated before `max`'s body is substituted.

3. **Lazy conditional branches**: The `if` function only evaluates the condition eagerly. The selected branch is evaluated only when needed, while the other branch remains unevaluated.

4. **Two term types for functions**: `CustomFunctionTerm` (user-defined, uses substitution) and `NativeFunctionTerm` (built-in, delegates to Dart) share the same interface but have different evaluation strategies.

5. **Recursion tracking**: The runtime tracks call depth via `FunctionTerm.incrementDepth()` and enforces a maximum recursion limit (1000) to prevent stack overflow.

6. **Deferred resolution**: `FunctionReferenceTerm` holds a reference to the functions map rather than the resolved function. Resolution happens at evaluation time via `reduce()`, enabling forward references and mutual recursion.
