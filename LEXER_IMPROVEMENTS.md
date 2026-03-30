# Lexical Analyzer: Issues & Improvement Plan

This document details 10 issues found in the lexical analyzer (9 from code review + escape sequence support), explains each in depth, and proposes a concrete implementation plan.

---

## Table of Contents

3. [No String Escape Sequences](#3-no-string-escape-sequences)
4. [Unterminated Strings and Comments Give Poor Errors](#4-unterminated-strings-and-comments-give-poor-errors)
5. [Single-Character Tokens Pay Unnecessary Lookahead Cost](#5-single-character-tokens-pay-unnecessary-lookahead-cost)

---

## 3. No String Escape Sequences

### The Issue

`StringDoubleQuoteState` and `StringSingleQuoteState` (`lib/compiler/lexical/lexical_analyzer.dart:103-127`) treat everything between quotes as literal content:

```dart
class StringDoubleQuoteState extends State<Character, Lexeme> {
  @override
  State process(Character input) {
    if (input.value.isDoubleQuote) {
      return ResultState(iterator, [StringToken(output)]);
    } else {
      return StringDoubleQuoteState(iterator, output.add(input));
    }
  }
}
```

There is no handling of backslash. This means:

- `"hello\nworld"` produces the literal 12-character string `hello\nworld` (backslash, n -- not a newline)
- `"say \"hi\""` terminates the string at the second `"`, producing `say \` as the value
- There is no way to include a double-quote inside a double-quoted string, or a single-quote inside a single-quoted string

### Proposed Fix

Add two new escape states following the existing state machine pattern.

#### Step 1: Add `isBackslash` predicate

In `lib/extensions/string_extensions.dart`, add:

```dart
bool get isBackslash => this == '\\';
```

#### Step 2: Add `InvalidEscapeSequenceError`

In `lib/compiler/errors/lexical_error.dart`, add:

```dart
class InvalidEscapeSequenceError extends LexicalError {
  const InvalidEscapeSequenceError(Character character)
    : super(
        'Invalid escape sequence \'\\${character.value}\' at ${character.location}',
      );
}
```

Using `InvalidCharacterError` would be misleading -- the character `z` is valid in general, just not after a backslash. A dedicated error type also lets tests assert specifically.

#### Step 3: Add `Lexeme.addValue(String)` helper

In `lib/compiler/lexical/lexical_analyzer.dart`, add to `Lexeme`:

```dart
Lexeme addValue(String value) => Lexeme(
  value: this.value + value,
  location: location,
);
```

The existing `add(Character)` appends `character.value` directly. For escapes, the resolved value (`\n`) differs from the input character (`n`), so we need a way to append an arbitrary string.

#### Step 4: Add `StringDoubleQuoteEscapeState` and `StringSingleQuoteEscapeState`

Two separate escape states (not one shared) to stay consistent with the existing pattern where `StringDoubleQuoteState` and `StringSingleQuoteState` are already separate classes.

```dart
class StringDoubleQuoteEscapeState extends State<Character, Lexeme> {
  const StringDoubleQuoteEscapeState(super.iterator, super.output);

  @override
  State process(Character input) {
    if (input.value == 'n') {
      return StringDoubleQuoteState(iterator, output.addValue('\n'));
    } else if (input.value == 't') {
      return StringDoubleQuoteState(iterator, output.addValue('\t'));
    } else if (input.value.isBackslash) {
      return StringDoubleQuoteState(iterator, output.addValue('\\'));
    } else if (input.value.isDoubleQuote) {
      return StringDoubleQuoteState(iterator, output.addValue('"'));
    } else if (input.value.isSingleQuote) {
      return StringDoubleQuoteState(iterator, output.addValue("'"));
    } else {
      throw InvalidEscapeSequenceError(input);
    }
  }
}
```

`StringSingleQuoteEscapeState` is identical but returns to `StringSingleQuoteState`.

The supported escape sequences are:

| Source | Resolved | Meaning           |
| ------ | -------- | ----------------- |
| `\\`   | `\`      | Literal backslash |
| `\"`   | `"`      | Double quote      |
| `\'`   | `'`      | Single quote      |
| `\n`   | newline  | Line feed         |
| `\t`   | tab      | Horizontal tab    |

Both quote escapes are supported in both string types for consistency.

#### Step 5: Modify string states to detect backslash

In `StringDoubleQuoteState.process()`, add a branch between the quote check and the fallthrough:

```dart
} else if (input.value.isBackslash) {
  return StringDoubleQuoteEscapeState(iterator, output);
```

The backslash itself is **not** accumulated -- the escape state handles what follows.

Same change in `StringSingleQuoteState.process()`.

#### Step 6: How it works end-to-end

For input `"hello\nworld"`, the scanner produces characters: `"`, `h`, `e`, `l`, `l`, `o`, `\`, `n`, `w`, `o`, `r`, `l`, `d`, `"`, `\n`.

State transitions:

1. `"` -> InitState dispatches to StringDoubleQuoteState (empty lexeme)
2. `h`, `e`, `l`, `l`, `o` -> accumulates into lexeme `"hello"`
3. `\` -> StringDoubleQuoteState sees backslash -> StringDoubleQuoteEscapeState (lexeme still `"hello"`)
4. `n` -> EscapeState resolves to `\n` (actual newline), appends via `addValue('\n')` -> back to StringDoubleQuoteState (lexeme `"hello\n"`)
5. `w`, `o`, `r`, `l`, `d` -> accumulates into lexeme `"hello\nworld"`
6. `"` -> closing quote -> ResultState with StringToken(value: `"hello\nworld"`)

The StringToken's value contains an actual newline character, not the two-character sequence `\n`.

### Files to Modify

- `lib/extensions/string_extensions.dart` -- add `isBackslash`
- `lib/compiler/errors/lexical_error.dart` -- add `InvalidEscapeSequenceError`
- `lib/compiler/lexical/lexical_analyzer.dart` -- add `Lexeme.addValue`, two escape states, modify both string states
- `test/compiler/lexical_analyzer_test.dart` -- add escape sequence tests
- `docs/compiler/lexical.md` -- document the new states, escape sequences, and error type

### Test Cases

1. `"hello\nworld"` -> StringToken with actual newline in value
2. `'hello\tworld'` -> StringToken with actual tab in value
3. `"path\\to"` -> StringToken with value `path\to`
4. `"say \"hi\""` -> StringToken with value `say "hi"` (escaped quote does not terminate string)
5. `'it\'s'` -> StringToken with value `it's`
6. `"a\nb\tc"` -> multiple escapes in one string
7. `"\nhello"` -> escape at start of string
8. `"hello\n"` -> escape at end of string
9. `"hello\z"` -> throws `InvalidEscapeSequenceError`
10. `'hello\z'` -> throws `InvalidEscapeSequenceError` for single-quoted strings too

### Priority

**High** -- This is new functionality the user explicitly wants.

Update the file `docs/compiler/lexical.md` if necessary.

---

## 4. Unterminated Strings and Comments Give Poor Errors

### The Issue

When a string or multi-line comment is never closed, the state machine keeps consuming characters until the iterator is exhausted. At that point, `iterator.hasNext` returns false and the main loop exits normally. The in-progress state is silently abandoned -- no token is emitted and **no error is thrown**.

Current behavior:

- `"hello` -> returns empty token list (confirmed by test at line 1138)
- `'hello` -> returns empty token list (confirmed by test at line 1143)
- `/* comment` -> returns empty token list (confirmed by test at line 1559)

This is problematic because:

1. The user gets no diagnostic at all -- the compiler silently produces fewer tokens than expected
2. The error will surface later as a confusing parse error in the syntactic analyzer, far from the actual problem
3. For multi-line comments, the entire rest of the file is silently consumed with no indication

### Proposed Fix

After the main `while` loop in `LexicalAnalyzer.analyze()`, check the final state and throw descriptive errors:

```dart
if (state is StringDoubleQuoteState || state is StringDoubleQuoteEscapeState) {
  throw UnterminatedStringError(state.output.location);
} else if (state is StringSingleQuoteState || state is StringSingleQuoteEscapeState) {
  throw UnterminatedStringError(state.output.location);
} else if (state is StartMultiLineCommentState || state is ClosingMultiLineCommentState) {
  throw UnterminatedCommentError();
}
```

Add two new error classes in `lib/compiler/errors/lexical_error.dart`:

```dart
class UnterminatedStringError extends LexicalError {
  const UnterminatedStringError(Location location)
    : super('Unterminated string starting at $location');
}

class UnterminatedCommentError extends LexicalError {
  const UnterminatedCommentError()
    : super('Unterminated multi-line comment');
}
```

The `Location` in `UnterminatedStringError` points to the opening quote, helping the user find where the string starts. For comments, the `ForwardSlashState` already consumed the `/*` so we don't have a stored location, but "unterminated multi-line comment" is clear enough.

### Impact on Existing Tests

The existing tests at lines 1138-1145 and 1559 expect empty token lists for unterminated strings/comments. These tests would need to be updated to expect the new errors:

```dart
test('Unterminated double quoted string', () {
  expect(() => getTokens('"hello'), throwsA(isA<UnterminatedStringError>()));
});
```

### Files to Modify

- `lib/compiler/errors/lexical_error.dart` -- add `UnterminatedStringError`, `UnterminatedCommentError`
- `lib/compiler/lexical/lexical_analyzer.dart` -- add post-loop state checks in `analyze()`
- `test/compiler/lexical_analyzer_test.dart` -- update existing unterminated tests to expect errors

### Priority

**Medium** -- This is a significant UX improvement for error diagnostics. Unterminated strings are a common mistake.

Update the file `docs/compiler/lexical.md` if necessary.

---

## 5. Single-Character Tokens Pay Unnecessary Lookahead Cost

### The Issue

Tokens that are inherently single characters -- `(`, `)`, `[`, `]`, `{`, `}`, `,`, `:` -- still go through the full lookahead pattern. For example, `(` in the source:

1. `InitState` sees `(`, creates `OpenParenthesisState`
2. `OpenParenthesisState.process()` consumes the **next** character
3. Checks if it satisfies `isOpenParenthesisDelimiter`
4. If yes, calls `iterator.back()` to un-consume it
5. Returns `ResultState` with `OpenParenthesisToken`

This means every single-character token costs an extra character read + back + delimiter predicate evaluation. For the 8 single-character token types, this is unnecessary work.

### The Counter-Argument

The lookahead provides **validation**: it catches sequences like `(@` early with a helpful `InvalidCharacterError` rather than deferring the error to the parser. This is a legitimate design tradeoff -- stricter lexing means better error messages at the cost of extra work.

### Proposed Fix (If Desired)

Emit single-character tokens directly from `InitState` without entering a dedicated state:

```dart
} else if (input.value.isOpenParenthesis) {
  return ResultState(iterator, [OpenParenthesisToken(input.lexeme)]);
}
```

This removes the dedicated `OpenParenthesisState`, `CloseParenthesisState`, `OpenBracketState`, `CloseBracketState`, `OpenBracesState`, `CloseBracesState`, `CommaState`, and `ColonState` -- 8 classes totaling ~90 lines of code.

The tradeoff is that invalid sequences like `(@` would no longer be caught at the lexer level. They would instead be caught by the parser, which may produce less precise error messages.

### Files to Modify

- `lib/compiler/lexical/lexical_analyzer.dart` -- modify `InitState.process()` to emit directly for 8 token types, remove 8 state classes
- `lib/extensions/string_extensions.dart` -- the 8 delimiter predicates (`isCommaDelimiter`, `isColonDelimiter`, `isOpenParenthesisDelimiter`, etc.) could be removed
- `test/compiler/lexical_analyzer_test.dart` -- update any tests that depend on lexer-level delimiter validation

### Priority

**Low** -- This is an optimization that trades strictness for simplicity. The current approach is defensible.

Update the file `docs/compiler/lexical.md` if necessary.