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
 Lowerer ............. Runtime nodes for evaluation       → compiler/semantic.md
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

The normalized string is split by `\n`:

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

---

## Stage 2: Lexical Analyzer

**File**: `lib/compiler/lexical/lexical_analyzer.dart`

The Lexical Analyzer (lexer) consumes the list of characters and produces a list of `Token` objects. It discards whitespace and comments while identifying keywords, literals, and operators.

### Transformation

**Input**: `List<Character>`

**Output**: `List<Token>`

### Step-by-Step Processing

The lexer uses a state machine to group characters into lexemes. For example, the characters `s`, `q`, `u`, `a`, `r`, `e` at `[1, 1]` through `[1, 6]` are grouped into an `IdentifierToken`.

#### Row 1: `square(n) = n * n`

1. `square` → `IdentifierToken("square")` at [1, 1]
2. `(` → `OpenParenthesisToken("(")` at [1, 7]
3. `n` → `IdentifierToken("n")` at [1, 8]
4. `)` → `CloseParenthesisToken(")")` at [1, 9]
5. `=` → `AssignToken("=")` at [1, 11]
6. `n` → `IdentifierToken("n")` at [1, 13]
7. `*` → `AsteriskToken("*")` at [1, 15]
8. `n` → `IdentifierToken("n")` at [1, 17]

#### Row 2: `max(a, b) = if (a >= b) a else b`

1. `max` → `IdentifierToken("max")` at [2, 1]
2. `(` → `OpenParenthesisToken("(")` at [2, 4]
3. `a` → `IdentifierToken("a")` at [2, 5]
4. `,` → `CommaToken(",")` at [2, 6]
5. `b` → `IdentifierToken("b")` at [2, 8]
6. `)` → `CloseParenthesisToken(")")` at [2, 9]
7. `=` → `AssignToken("=")` at [2, 11]
8. `if` → `IfToken("if")` at [2, 13]
9. `(` → `OpenParenthesisToken("(")` at [2, 16]
10. `a` → `IdentifierToken("a")` at [2, 17]
11. `>=` → `GreaterOrEqualToken(">=")` at [2, 19]
12. `b` → `IdentifierToken("b")` at [2, 22]
13. `)` → `CloseParenthesisToken(")")` at [2, 23]
14. `a` → `IdentifierToken("a")` at [2, 25]
15. `else` → `ElseToken("else")` at [2, 27]
16. `b` → `IdentifierToken("b")` at [2, 32]

### Summary

The lexer produces a flat `List<Token>` representing the linear structure of the program, ready for the syntactic analyzer to build an AST.

---

## Stage 3: Syntactic Analyzer

_Coming soon..._
