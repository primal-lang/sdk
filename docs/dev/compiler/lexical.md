---
title: Lexical Analysis
tags: [compiler, lexer]
sources: [lib/compiler/lexical/]
---

# Lexical Analysis

**TLDR**: The lexical analyzer is a state machine that converts a character list into typed tokens, handling keywords, identifiers, literals, operators, comments, and escape sequences with single-character lookahead.

**Files**: `lib/compiler/lexical/lexical_analyzer.dart`, `lib/compiler/lexical/token.dart`, `lib/compiler/lexical/lexeme.dart`

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

When the iterator is exhausted, the main loop checks if the machine is in a state that can produce a valid token without further input. If the final state is `IntegerState`, `DecimalState`, `ExponentState`, or `IdentifierState`, the accumulated lexeme is converted to the appropriate token (applying keyword detection for identifiers). This allows tokens at the very end of the source to be recognized without a trailing delimiter.

If the final state is `ExponentInitState` or `ExponentSignState`, the lexer throws a `LexicalError` because the exponent is incomplete (e.g., `1e` or `1e+` without digits).

## Lookahead Pattern

Most states need to see one character past the end of their token to know the token is complete (e.g. the space after a number, or the `=` after `!`). When the terminating character is not part of the current token, the state calls `iterator.back()` to un-consume it so the next `InitState` cycle can re-dispatch it. This gives the machine single-character lookahead without a separate peek mechanism.

## State Machine

The analyzer starts in `InitState` and transitions based on the current character:

| Character class                                   | Target state                              |
| ------------------------------------------------- | ----------------------------------------- |
| ASCII letter (`a-z`, `A-Z`)                       | `IdentifierState` (see below)             |
| Digit                                             | `IntegerState`                            |
| `"`                                               | `StringState` (with `QuoteType.double`)   |
| `'`                                               | `StringState` (with `QuoteType.single`)   |
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
| `@`                                               | Emit `AtToken` via `ResultState`          |
| Delimiters `(`, `)`, `[`, `]`, `{`, `}`, `,`, `:` | Emit token directly via `ResultState`     |
| Whitespace / newline                              | Skipped, returns to `InitState`           |

Additional internal states not reachable from `InitState`:

| State                          | Reachable from                           | Purpose                                            |
| ------------------------------ | ---------------------------------------- | -------------------------------------------------- |
| `DecimalInitState`             | `IntegerState`                           | Entered after `.`; requires at least one digit     |
| `DecimalState`                 | `DecimalInitState`                       | Accumulates remaining decimal digits               |
| `ExponentInitState`            | `IntegerState`, `DecimalState`           | Entered after `e`/`E`; expects digit or sign       |
| `ExponentSignState`            | `ExponentInitState`                      | Entered after `+`/`-`; requires at least one digit |
| `ExponentState`                | `ExponentInitState`, `ExponentSignState` | Accumulates exponent digits                        |
| `StringEscapeState`            | `StringState`                            | Processes escape sequence in string                |
| `StringHexEscapeState`         | `StringEscapeState`                      | Accumulates hex digits for `\xXX` or `\uXXXX`      |
| `StringUnicodeEscapeState`     | `StringEscapeState`                      | Dispatches `\u` to fixed or braced format          |
| `StringBracedEscapeState`      | `StringUnicodeEscapeState`               | Accumulates hex digits for `\u{...}`               |
| `SingleLineCommentState`       | `ForwardSlashState`                      | Consumes until newline                             |
| `StartMultiLineCommentState`   | `ForwardSlashState`                      | Consumes until `*` is found                        |
| `ClosingMultiLineCommentState` | `StartMultiLineCommentState`             | Checks for `/` to close the comment                |
| `ResultState`                  | Any token-producing state                | Carries the completed token back to the main loop  |

All string states (including `StringState`, `StringEscapeState`, and related escape states) extend `StringRelatedState`, which provides a `stringStartLocation` property used for unterminated string error reporting.

Multi-character tokens are accumulated via a `Lexeme` object that tracks the starting location and collects characters with `.add(String)`, returning a new immutable `Lexeme` each time.

## String Escape Sequences

Both double-quoted and single-quoted strings support escape sequences. When a backslash (`\`) is encountered inside a string, the lexer transitions to `StringEscapeState` which interprets the following character:

| Source | Resolved | Meaning           |
| ------ | -------- | ----------------- |
| `\\`   | `\`      | Literal backslash |
| `\"`   | `"`      | Double quote      |
| `\'`   | `'`      | Single quote      |
| `\n`   | newline  | Line feed         |
| `\t`   | tab      | Horizontal tab    |

Both quote escapes are supported in both string types for consistency. This allows `"it\'s"` and `'say \"hi\"'` to work as expected.

### Unicode Escape Sequences

Three Unicode escape formats are supported:

| Format     | Digits             | Range             | Example            |
| ---------- | ------------------ | ----------------- | ------------------ |
| `\xXX`     | 2 hex (fixed)      | U+0000 - U+00FF   | `\x41` → "A"       |
| `\uXXXX`   | 4 hex (fixed)      | U+0000 - U+FFFF   | `\u03B1` → "α"     |
| `\u{X...}` | 1-6 hex (variable) | U+0000 - U+10FFFF | `\u{1F600}` → "😀" |

The braced format (`\u{...}`) follows JavaScript ES6 and Rust conventions, allowing any valid Unicode code point with 1-6 hex digits.

**Examples:**

- `"\x48\x69"` → "Hi"
- `"\u0048\u0065\u006C\u006C\u006F"` → "Hello"
- `"\u{1F600}"` → "😀"

**Error conditions:**

- Non-hex character in escape: `InvalidHexEscapeError`
- Empty braces (`\u{}`): `InvalidBracedEscapeError`
- Too many digits in braces (>6): `InvalidBracedEscapeError`
- Invalid character in braces: `InvalidBracedEscapeError`
- Code point exceeds U+10FFFF: `InvalidCodePointError`

The escape state uses `Lexeme.add(String)` to append the resolved character (which may differ from the input character) and returns to the parent string state.

If an unrecognized escape sequence is encountered (e.g., `\z`), the lexer throws `InvalidEscapeSequenceError`.

## Number Parsing

Numbers are parsed through a six-state pipeline supporting integers, decimals, scientific notation, and underscore separators:

1. **`IntegerState`** — accumulates digits. On encountering a `.`, transitions to `DecimalInitState`. On encountering `e` or `E`, transitions to `ExponentInitState`.
2. **`DecimalInitState`** — requires at least one digit after the dot. If the next character is not a digit, throws `InvalidCharacterError`.
3. **`DecimalState`** — accumulates remaining decimal digits. On encountering `e` or `E`, transitions to `ExponentInitState`.
4. **`ExponentInitState`** — expects a digit or sign (`+`/`-`). On sign, transitions to `ExponentSignState`. On digit, transitions to `ExponentState`.
5. **`ExponentSignState`** — requires at least one digit after the sign.
6. **`ExponentState`** — accumulates exponent digits until a delimiter is reached.

All integer, decimal, and exponent states emit a `NumberToken`, which parses the accumulated lexeme to a Dart `num`.

### Underscore Separators

Numeric literals support underscore separators for readability (e.g., `1_000_000`, `3.141_592`, `1e1_0`). The following rules apply:

- Underscores are allowed between digits
- Consecutive underscores are not allowed (throws `InvalidCharacterError`)
- Trailing underscores are not allowed (throws `LexicalError`)
- Underscores are not stored in the lexeme; they are skipped during accumulation

## Two-Character Operators

Several states peek at the next character to distinguish single-character tokens from two-character compound tokens:

| State            | If next is... | Token produced                      | Otherwise (delimiter)          |
| ---------------- | ------------- | ----------------------------------- | ------------------------------ |
| `EqualsState`    | `=`           | `EqualToken` (`==`)                 | `AssignToken` (`=`)            |
| `GreaterState`   | `=`           | `GreaterOrEqualToken` (`>=`)        | `GreaterThanToken` (`>`)       |
| `LessState`      | `=`           | `LessOrEqualToken` (`<=`)           | `LessThanToken` (`<`)          |
| `BangState`      | `=`           | `NotEqualToken` (`!=`)              | `BangToken` (`!`)              |
| `PipeState`      | `\|`          | `DoublePipeToken` (`\|\|`, lazy)    | `PipeToken` (`\|`, strict)     |
| `AmpersandState` | `&`           | `DoubleAmpersandToken` (`&&`, lazy) | `AmpersandToken` (`&`, strict) |
| `MinusState`     | `>`           | `ArrowToken` (`->`)                 | `MinusToken` (`-`)             |

In all cases the lookahead pattern applies: if the next character does not form a compound token, `iterator.back()` un-consumes it.

The logical operators have semantic differences:

- `&` and `|` (single-character) are **strict** — both operands are always evaluated
- `&&` and `||` (double-character) are **short-circuit** — the second operand is only evaluated if needed

## Identifiers and Keywords

Identifiers must start with an ASCII letter (`a-z`, `A-Z`) and may continue with any combination of:

- Letters (`a-z`, `A-Z`)
- Digits (`0-9`)
- Dots (`.`)
- Underscores (`_`)

This allows dotted names like `math.pi` or `list.head` to be parsed as single identifier tokens.

Keywords are not recognized by dedicated `InitState` branches. Instead, `IdentifierState` accumulates all identifier characters and checks the final lexeme value:

- `isBoolean` → `BooleanToken`
- `isIf` → `IfToken`
- `isElse` → `ElseToken`
- `isAnd` → `DoubleAmpersandToken` (keyword alias for `&&`, short-circuit)
- `isOr` → `DoublePipeToken` (keyword alias for `||`, short-circuit)
- `isNot` → `BangToken` (keyword alias for `!`)
- Otherwise → `IdentifierToken`

This means keywords are identifiers that are reclassified at the boundary. The `and` and `or` keywords produce double-character operator tokens (`&&`, `||`) for short-circuit evaluation. The `not` keyword produces `BangToken` with the canonical symbol `!`.

## Delimiter Predicates

Different token types use distinct delimiter predicates to determine what can legally follow them:

| Predicate             | Used by                                                                                                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `isOperandDelimiter`  | `IntegerState`, `DecimalState`, `ExponentState`, `IdentifierState`                                                                                                      |
| `isOperatorDelimiter` | `MinusState`, `PlusState`, `EqualsState`, `GreaterState`, `LessState`, `PipeState`, `AmpersandState`, `BangState`, `ForwardSlashState`, `AsteriskState`, `PercentState` |

Single-character delimiters (`(`, `)`, `[`, `]`, `{`, `}`, `,`, `:`) are emitted directly from `InitState` without lookahead validation. Invalid sequences following these tokens are caught by the parser rather than the lexer.

## Comments

Both comment styles are recognized and discarded (they produce no tokens):

- **Single-line** (`//`): `ForwardSlashState` sees a second `/` and enters `SingleLineCommentState`, which consumes characters until a newline, then returns to `InitState`.
- **Multi-line** (`/* */`): `ForwardSlashState` sees `*` and enters `StartMultiLineCommentState`, which scans for `*`. When `*` is found, it transitions to `ClosingMultiLineCommentState`, which checks for `/`. If `/` follows, the comment is closed and the machine returns to `InitState`. If the next character is another `*`, the state stays in `ClosingMultiLineCommentState` (handling consecutive `*` characters such as in `/***/`). Otherwise, it falls back to `StartMultiLineCommentState` to keep scanning.

## Error Handling

When a state encounters an unexpected character, it throws `InvalidCharacterError`. Some states provide an expected-character hint for better diagnostics:

- `IntegerState` expects `'digit, underscore, or dot'`
- `DecimalInitState` expects `'digit'`
- `DecimalState` expects `'digit or underscore'`
- `ExponentInitState` expects `'digit or sign'`
- `ExponentSignState` and `ExponentState` expect `'digit'`

Additionally, `IntegerState`, `DecimalState`, and `ExponentState` throw `InvalidCharacterError` with expected `'digit'` when a non-digit character follows an underscore (e.g., after an underscore before a dot, exponent, or delimiter).

All other states throw a generic `InvalidCharacterError` with just the offending character.

The escape state (`StringEscapeState`) throws `InvalidEscapeSequenceError` when an unrecognized escape sequence is encountered (e.g., `\z`).

After the main loop completes, the analyzer checks for unterminated or incomplete constructs:

- **Unterminated strings**: If the final state is any `StringRelatedState` subclass, throws `UnterminatedStringError` with the location of the opening quote.
- **Unterminated comments**: If the final state is `StartMultiLineCommentState` or `ClosingMultiLineCommentState`, throws `UnterminatedCommentError`.
- **Incomplete exponents**: If the final state is `ExponentInitState` or `ExponentSignState`, throws `LexicalError('Incomplete exponent in number literal')`.
- **Trailing underscores**: If the final state is `IntegerState`, `DecimalState`, or `ExponentState` with `lastWasUnderscore` set, throws `LexicalError('Trailing underscore in number literal')`.

## Token Types

All tokens extend `Token<T>` and carry a typed value plus location:

| Category    | Tokens                                                                                                                                                                                                                                                                   | Value type              |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------- |
| Literals    | `StringToken`, `NumberToken`, `BooleanToken`                                                                                                                                                                                                                             | `String`, `num`, `bool` |
| Identifiers | `IdentifierToken`                                                                                                                                                                                                                                                        | `String`                |
| Keywords    | `IfToken`, `ElseToken`, `LetToken`, `InToken`                                                                                                                                                                                                                            | `String`                |
| Assignment  | `AssignToken` (`=`)                                                                                                                                                                                                                                                      | `String`                |
| Binary ops  | `PlusToken`, `MinusToken`, `AsteriskToken`, `ForwardSlashToken`, `PercentToken`, `PipeToken`, `DoublePipeToken`, `AmpersandToken`, `DoubleAmpersandToken`, `EqualToken`, `NotEqualToken`, `GreaterThanToken`, `GreaterOrEqualToken`, `LessThanToken`, `LessOrEqualToken` | `String`                |
| Unary ops   | `BangToken`                                                                                                                                                                                                                                                              | `String`                |
| Symbols     | `AtToken` (`@`), `ArrowToken` (`->`)                                                                                                                                                                                                                                     | `String`                |
| Delimiters  | `OpenParenthesisToken`, `CloseParenthesisToken`, `OpenBracketToken`, `CloseBracketToken`, `OpenBracesToken`, `CloseBracesToken`, `CommaToken`, `ColonToken`                                                                                                              | `String`                |

`NumberToken` parses the lexeme string to `num` and `BooleanToken` parses to `bool` at construction time. All other token types store the raw lexeme string.
