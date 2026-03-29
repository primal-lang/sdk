# Lexical Analysis

**Files**: `lib/compiler/lexical/lexical_analyzer.dart`, `lib/compiler/lexical/token.dart`

The lexical analyzer consumes the character list and produces a list of typed tokens. It is implemented as a **state machine** with 20+ state classes, each responsible for recognizing a specific kind of lexeme.

## State Machine

The analyzer starts in `InitState` and transitions based on the current character:

| Character class                                   | Target state                              |
| ------------------------------------------------- | ----------------------------------------- |
| Letter                                            | `IdentifierState`                         |
| Digit                                             | `IntegerState`                            |
| `"`                                               | `StringDoubleQuoteState`                  |
| `'`                                               | `StringSingleQuoteState`                  |
| `+`                                               | `PlusState`                               |
| `-`                                               | `MinusState`                              |
| `=`                                               | `EqualsState`                             |
| `>`                                               | `GreaterState`                            |
| `<`                                               | `LessState`                               |
| `\|`                                              | `PipeState`                               |
| `&`                                               | `AmpersandState`                          |
| `!`                                               | `BangState`                               |
| `/`                                               | `ForwardSlashState` (division or comment) |
| Delimiters `(`, `)`, `[`, `]`, `{`, `}`, `,`, `:` | Corresponding delimiter states            |
| Whitespace / newline                              | Skipped, returns to `InitState`           |

Multi-character tokens are accumulated via a `Lexeme` object that tracks the starting location and collects characters with `.add(Character)`.

## Token Types

All tokens extend `Token<T>` and carry a typed value plus location:

- **Literals**: `StringToken`, `NumberToken`, `BooleanToken`
- **Identifiers**: `IdentifierToken` (variable and function names)
- **Keywords**: `IfToken`, `ElseToken`
- **Assignment**: `AssignToken` (`=`)
- **Binary operators**: `PlusToken`, `MinusToken`, `AsteriskToken`, `ForwardSlashToken`, `PercentToken`, `PipeToken`, `AmpersandToken`, `EqualToken`, `NotEqualToken`, `GreaterThanToken`, `GreaterEqualThanToken`, `LessThanToken`, `LessEqualThanToken`
- **Unary operators**: `BangToken`
- **Delimiters**: `OpenParenthesisToken`, `CloseParenthesisToken`, `OpenBracketToken`, `CloseBracketToken`, `OpenBracesToken`, `CloseBracesToken`, `CommaToken`, `ColonToken`

Comments (single-line `//` and multi-line `/* */`) are recognized and discarded.
