# Lexical Analyzer: Issues & Improvement Plan

This document details 10 issues found in the lexical analyzer (9 from code review + escape sequence support), explains each in depth, and proposes a concrete implementation plan.

---

## Table of Contents

3. [No String Escape Sequences](#3-no-string-escape-sequences)

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
