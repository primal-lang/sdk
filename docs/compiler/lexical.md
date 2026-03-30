# Lexical Analysis

**Files**: `lib/compiler/lexical/lexical_analyzer.dart`, `lib/compiler/lexical/token.dart`

The lexical analyzer consumes the character list and produces a list of typed tokens. It is implemented as a **state machine** with state classes responsible for recognizing specific kinds of lexemes.

## Main Loop

The `analyze()` method drives the state machine:

1. A `ListIterator<Character>` wraps the input character list.
2. The machine starts in `InitState`.
3. Each iteration calls `state.next`, which reads the next character and delegates to `process()`.
4. When a state returns `ResultState`, its tokens are collected into the result list and the machine resets to `InitState`.
5. The loop ends when the iterator is exhausted.

`ResultState` carries a single `Token`. The reset-to-`InitState` cycle ensures every token is produced independently.

## End-of-Input Handling

When the iterator is exhausted, the main loop checks if the machine is in a state that can produce a valid token without further input. If the final state is `IntegerState`, `DecimalState`, or `IdentifierState`, the accumulated lexeme is converted to the appropriate token (applying keyword detection for identifiers). This allows tokens at the very end of the source to be recognized without a trailing delimiter.

## Lookahead Pattern

Most states need to see one character past the end of their token to know the token is complete (e.g. the space after a number, or the `=` after `!`). When the terminating character is not part of the current token, the state calls `iterator.back()` to un-consume it so the next `InitState` cycle can re-dispatch it. This gives the machine single-character lookahead without a separate peek mechanism.

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
| `*`                                               | `AsteriskState`                           |
| `%`                                               | `PercentState`                            |
| Delimiters `(`, `)`, `[`, `]`, `{`, `}`, `,`, `:` | Emit token directly via `ResultState`     |
| Whitespace / newline                              | Skipped, returns to `InitState`           |

Additional internal states not reachable from `InitState`:

| State                          | Reachable from               | Purpose                                        |
| ------------------------------ | ---------------------------- | ---------------------------------------------- |
| `DecimalInitState`             | `IntegerState`               | Entered after `.`; requires at least one digit |
| `DecimalState`                 | `DecimalInitState`           | Accumulates remaining decimal digits           |
| `SingleLineCommentState`       | `ForwardSlashState`          | Consumes until newline                         |
| `StartMultiLineCommentState`   | `ForwardSlashState`          | Consumes until `*` is found                    |
| `ClosingMultiLineCommentState` | `StartMultiLineCommentState` | Checks for `/` to close the comment            |
| `ResultState`                  | Any token-producing state    | Carries the completed token back to the main loop |

Multi-character tokens are accumulated via a `Lexeme` object that tracks the starting location and collects characters with `.add(Character)`, returning a new immutable `Lexeme` each time.

## Number Parsing

Numbers are parsed through a three-state pipeline:

1. **`IntegerState`** — accumulates digits. On encountering a `.`, transitions to `DecimalInitState`.
2. **`DecimalInitState`** — requires at least one digit after the dot. If the next character is not a digit, throws `InvalidCharacterError`.
3. **`DecimalState`** — accumulates remaining decimal digits until a delimiter is reached.

Both integer and decimal numbers emit a `NumberToken`, which parses the accumulated lexeme to a Dart `num`.

## Two-Character Operators

Four states peek at the next character to distinguish single-character tokens from two-character compound tokens:

| State          | If next is `=`                 | Otherwise (delimiter)    |
| -------------- | ------------------------------ | ------------------------ |
| `EqualsState`  | `EqualToken` (`==`)            | `AssignToken` (`=`)      |
| `GreaterState` | `GreaterEqualThanToken` (`>=`) | `GreaterThanToken` (`>`) |
| `LessState`    | `LessEqualThanToken` (`<=`)    | `LessThanToken` (`<`)    |
| `BangState`    | `NotEqualToken` (`!=`)         | `BangToken` (`!`)        |

In all cases the lookahead pattern applies: if the next character is not `=`, `iterator.back()` un-consumes it.

## Keyword Detection

Keywords are not recognized by dedicated `InitState` branches. Instead, `IdentifierState` accumulates all letter/identifier characters and checks the final lexeme value:

- `isBoolean` → `BooleanToken`
- `isIf` → `IfToken`
- `isElse` → `ElseToken`
- Otherwise → `IdentifierToken`

This means keywords are identifiers that are reclassified at the boundary.

## Delimiter Predicates

Different token types use distinct delimiter predicates to determine what can legally follow them:

| Predicate             | Used by                                                                                                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `isOperandDelimiter`  | `IntegerState`, `DecimalState`, `IdentifierState`                                                                                                                       |
| `isOperatorDelimiter` | `MinusState`, `PlusState`, `EqualsState`, `GreaterState`, `LessState`, `PipeState`, `AmpersandState`, `BangState`, `ForwardSlashState`, `AsteriskState`, `PercentState` |

Single-character delimiters (`(`, `)`, `[`, `]`, `{`, `}`, `,`, `:`) are emitted directly from `InitState` without lookahead validation. Invalid sequences following these tokens are caught by the parser rather than the lexer.

## Comments

Both comment styles are recognized and discarded (they produce no tokens):

- **Single-line** (`//`): `ForwardSlashState` sees a second `/` and enters `SingleLineCommentState`, which consumes characters until a newline, then returns to `InitState`.
- **Multi-line** (`/* */`): `ForwardSlashState` sees `*` and enters `StartMultiLineCommentState`, which scans for `*`. When `*` is found, it transitions to `ClosingMultiLineCommentState`, which checks for `/`. If `/` follows, the comment is closed and the machine returns to `InitState`. If not, it falls back to `StartMultiLineCommentState` to keep scanning.

## Error Handling

When a state encounters an unexpected character, it throws `InvalidCharacterError`. Some states provide an expected-character hint for better diagnostics:

- `IntegerState` expects `'digit or dot'`
- `DecimalInitState` and `DecimalState` expect `'digit'`

All other states throw a generic `InvalidCharacterError` with just the offending character.

After the main loop completes, the analyzer checks for unterminated constructs:

- **Unterminated strings**: If the final state is `StringDoubleQuoteState` or `StringSingleQuoteState`, throws `UnterminatedStringError` with the location of the opening quote.
- **Unterminated comments**: If the final state is `StartMultiLineCommentState` or `ClosingMultiLineCommentState`, throws `UnterminatedCommentError`.

## Token Types

All tokens extend `Token<T>` and carry a typed value plus location:

| Category    | Tokens                                                                                                                                                                                                                            | Value type              |
| ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| Literals    | `StringToken`, `NumberToken`, `BooleanToken`                                                                                                                                                                                      | `String`, `num`, `bool` |
| Identifiers | `IdentifierToken`                                                                                                                                                                                                                 | `String`                |
| Keywords    | `IfToken`, `ElseToken`                                                                                                                                                                                                            | `String`                |
| Assignment  | `AssignToken` (`=`)                                                                                                                                                                                                               | `String`                |
| Binary ops  | `PlusToken`, `MinusToken`, `AsteriskToken`, `ForwardSlashToken`, `PercentToken`, `PipeToken`, `AmpersandToken`, `EqualToken`, `NotEqualToken`, `GreaterThanToken`, `GreaterEqualThanToken`, `LessThanToken`, `LessEqualThanToken` | `String`                |
| Unary ops   | `BangToken`                                                                                                                                                                                                                       | `String`                |
| Delimiters  | `OpenParenthesisToken`, `CloseParenthesisToken`, `OpenBracketToken`, `CloseBracketToken`, `OpenBracesToken`, `CloseBracesToken`, `CommaToken`, `ColonToken`                                                                       | `String`                |

`NumberToken` parses the lexeme string to `num` and `BooleanToken` parses to `bool` at construction time. All other token types store the raw lexeme string.
