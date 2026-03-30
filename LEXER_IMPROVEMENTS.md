# Lexical Analyzer: Issues & Improvement Plan

This document details 10 issues found in the lexical analyzer (9 from code review + escape sequence support), explains each in depth, and proposes a concrete implementation plan.

---

## Table of Contents

3. [No String Escape Sequences](#3-no-string-escape-sequences)
4. [Unterminated Strings and Comments Give Poor Errors](#4-unterminated-strings-and-comments-give-poor-errors)
5. [Single-Character Tokens Pay Unnecessary Lookahead Cost](#5-single-character-tokens-pay-unnecessary-lookahead-cost)
6. [Operators Cannot Be Directly Adjacent to Unary Operators](#6-operators-cannot-be-directly-adjacent-to-unary-operators)
7. [O(n^2) String Building in Lexeme](#7-on2-string-building-in-lexeme)
8. [Token Class Boilerplate](#8-token-class-boilerplate)
9. [ResultState Always Wraps a List but Only Ever Contains One Token](#9-resultstate-always-wraps-a-list-but-only-ever-contains-one-token)
10. [Delimiter Predicate Inconsistencies](#10-delimiter-predicate-inconsistencies)

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

---

## 6. Operators Cannot Be Directly Adjacent to Unary Operators

### The Issue

`isOperatorDelimiter` (`lib/extensions/string_extensions.dart:74-82`) defines what can legally follow an operator:

```dart
bool get isOperatorDelimiter =>
    isWhitespace ||
    isDigit ||
    isLetter ||
    isDoubleQuote ||
    isSingleQuote ||
    isOpenParenthesis ||
    isOpenBracket ||
    isOpenBraces;
```

Notably absent: `isMinus` and `isBang` (the two unary operators). This means:

- `1+-2` **fails** -- PlusState sees `-`, which is not in `isOperatorDelimiter`, throws `InvalidCharacterError`
- `1+!x` **fails** -- same reason
- `!!x` **fails** -- BangState sees `!`, which is not in `isOperatorDelimiter`

Users must write `1 + -2`, `1 + !x`, or `! !x` instead (or use parentheses: `1+(-2)`).

In contrast, `isCommaDelimiter`, `isColonDelimiter`, and `isOpenParenthesisDelimiter` **do** include `isUnaryOperator`, so `f(-x)`, `f(a, -b)`, and `{x: -1}` all work without spaces.

This is a **language design decision**, not a bug. Many languages (C, Java, JavaScript, Python) allow `1+-2`. Some (like Go) are stricter. The current behavior is consistent and documented in the delimiter predicates, but it is restrictive compared to most languages.

### Proposed Fix (If Desired)

Add `isUnaryOperator` to `isOperatorDelimiter`:

```dart
bool get isOperatorDelimiter =>
    isWhitespace ||
    isDigit ||
    isLetter ||
    isDoubleQuote ||
    isSingleQuote ||
    isOpenParenthesis ||
    isOpenBracket ||
    isOpenBraces ||
    isUnaryOperator;  // <-- add this
```

This would allow `1+-2`, `1+!x`, and `!!x` to be lexed. The parser would then handle disambiguation (is the `-` in `1+-2` a binary minus or unary minus?). This is how most languages handle it -- the lexer just tokenizes, and the parser uses context to determine unary vs. binary.

### Impact Analysis

Adding `isUnaryOperator` to `isOperatorDelimiter` means that after any operator, `-` and `!` become legal next characters. This affects all 11 operator states: `MinusState`, `PlusState`, `EqualsState`, `GreaterState`, `LessState`, `PipeState`, `AmpersandState`, `BangState`, `ForwardSlashState`, `AsteriskState`, `PercentState`.

The parser would need to handle expressions like `1 + -2` as `1 + (unary- 2)`. This may already work if the parser supports unary prefix operators -- but this needs verification.

### Files to Modify

- `lib/extensions/string_extensions.dart` -- add `isUnaryOperator` to `isOperatorDelimiter`
- Parser files (verify the parser handles the resulting token sequences correctly)
- `test/compiler/lexical_analyzer_test.dart` -- add tests for `1+-2`, `1+!x`, `!!x`

### Priority

**Low** -- This is a language design decision. The current behavior is consistent and documented; changing it affects the language semantics.

---

## 7. O(n^2) String Building in Lexeme

### The Issue

`Lexeme.add()` (`lib/compiler/lexical/lexical_analyzer.dart:530-533`) creates a new string via concatenation on every character:

```dart
Lexeme add(Character character) => Lexeme(
  value: value + character.value,
  location: location,
);
```

For a token of length `n`, this performs `n` string concatenations. Each concatenation copies the existing string plus the new character, resulting in total work proportional to `1 + 2 + 3 + ... + n = O(n^2)`.

For typical tokens (identifiers, keywords, operators), `n` is small (1-20 characters) and this is not a practical concern. For long strings (e.g., a 10,000-character string literal), this becomes `O(10^8)` character copies.

### The Tradeoff

The current design maintains **immutability**: each `Lexeme.add()` returns a new `Lexeme`, and no state is mutated. This aligns with the `const` constructor pattern used throughout the state machine. Switching to a `StringBuffer` would require:

- Making `Lexeme` mutable (or wrapping a mutable buffer)
- Losing `const` constructors
- Changing the state machine's functional style to a more imperative one

### Proposed Fix (If Desired)

Replace `String value` in `Lexeme` with a `StringBuffer`:

```dart
class Lexeme extends Localized {
  final StringBuffer _buffer;

  Lexeme({required String value, required super.location})
    : _buffer = StringBuffer(value);

  String get value => _buffer.toString();

  Lexeme add(Character character) {
    _buffer.write(character.value);
    return this;  // mutates in place instead of creating new Lexeme
  }
}
```

This makes `add()` O(1) amortized, bringing total token construction from O(n^2) to O(n). The tradeoff is that `Lexeme` is no longer immutable, and `const` constructors are lost.

A middle ground: keep the current approach for the general case (most tokens are short) and only optimize if profiling shows string tokenization is a bottleneck.

### Files to Modify

- `lib/compiler/lexical/lexical_analyzer.dart` -- modify `Lexeme` class

### Priority

**Low** -- Not a practical issue for typical source files. Only relevant for very long string literals.

---

## 8. Token Class Boilerplate

### The Issue

`lib/compiler/lexical/token.dart` contains ~25 token subclasses, each with an identical constructor pattern:

```dart
class MinusToken extends Token<String> {
  MinusToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}

class PlusToken extends Token<String> {
  PlusToken(Lexeme lexeme)
    : super(
        value: lexeme.value,
        location: lexeme.location,
      );
}
// ... 20+ more identical patterns
```

Every `Token<String>` subclass has the exact same constructor body. The only thing that differs is the class name. This is 230+ lines of highly repetitive code.

### Why It Exists

In Dart, the idiomatic way to do type discrimination in `switch`/`is` checks is via subclasses. The parser uses `is MinusToken`, `is PlusToken`, etc. to match tokens. This requires distinct types, hence the subclasses.

### Proposed Fix (If Desired)

**Option A: Shared mixin for the constructor**

```dart
mixin LexemeToken on Token<String> {
  // Can't easily share the constructor in Dart, but could reduce the body
}
```

Unfortunately, Dart doesn't allow mixins to define constructors, so this doesn't help much.

**Option B: Factory + enum**

```dart
enum TokenType {
  minus, plus, asterisk, forwardSlash, percent, pipe, ampersand,
  bang, equal, notEqual, greaterThan, greaterEqualThan, lessThan, lessEqualThan,
  assign, comma, colon, openParenthesis, closeParenthesis,
  openBracket, closeBracket, openBraces, closeBraces,
  identifier, string, number, boolean, ifKeyword, elseKeyword,
}

class Token extends Localized {
  final TokenType type;
  final dynamic value;
  // ...
}
```

This replaces 25 classes with 1 class + 1 enum. Pattern matching changes from `is MinusToken` to `token.type == TokenType.minus`. This is a significant refactor that touches the parser and all downstream code.

**Option C: Keep as-is**

The boilerplate is verbose but clear, type-safe, and idiomatic Dart. Adding a new token type is mechanical (copy, rename, done). The compiler catches type errors. This is arguably the right tradeoff for a hand-rolled compiler.

### Priority

**Low** -- This is an aesthetic/maintenance concern. The current approach is idiomatic and type-safe. A refactor would be large and touch many files.

---

## 9. ResultState Always Wraps a List but Only Ever Contains One Token

### The Issue

`ResultState` (`lib/compiler/lexical/lexical_analyzer.dart:518-520`) is typed as:

```dart
class ResultState extends State<void, List<Token>> {
  const ResultState(super.iterator, super.output);
}
```

Every usage creates a single-element list:

```dart
return ResultState(iterator, [MinusToken(output)]);
return ResultState(iterator, [NumberToken(output)]);
// etc. -- always exactly one token in the list
```

And the main loop always uses `addAll`:

```dart
result.addAll(state.output);  // always adding a 1-element list
```

The `List<Token>` wrapper adds allocation overhead (one extra list per token) and obscures the fact that states always produce exactly one token.

### Proposed Fix

Change `ResultState` to carry a single `Token`:

```dart
class ResultState extends State<void, Token> {
  const ResultState(super.iterator, super.output);
}
```

Update the main loop:

```dart
if (state is ResultState) {
  result.add(state.output);
  state = InitState(iterator);
}
```

Update all ~30 call sites from `ResultState(iterator, [SomeToken(output)])` to `ResultState(iterator, SomeToken(output))`.

This is a straightforward mechanical refactor with no behavioral change.

### Files to Modify

- `lib/compiler/lexical/lexical_analyzer.dart` -- change `ResultState` type, update main loop, update all ~30 `ResultState(...)` calls

### Priority

**Low** -- Minor cleanup. No behavioral change, small performance improvement (fewer list allocations).

---

## 10. Delimiter Predicate Inconsistencies

### The Issue

The 10 delimiter predicates in `lib/extensions/string_extensions.dart` are hand-written boolean combinations, each defining which character classes can legally follow a specific token type. Analysis reveals several asymmetries that appear unintentional:

#### Inconsistency A: `isColon` missing from close bracket and close braces

| Predicate                     | Includes `isColon`? |
| ----------------------------- | ------------------- |
| `isCloseParenthesisDelimiter` | Yes (line 120)      |
| `isCloseBracketDelimiter`     | **No**              |
| `isCloseBracesDelimiter`      | **No**              |

This means `)` can be followed by `:` but `]` and `}` cannot. In a language with type annotations or ternary-like syntax, `]:` or `}:` could be valid sequences. The asymmetry suggests `isColon` was added to `isCloseParenthesisDelimiter` but missed in the other two.

#### Inconsistency B: `isOpenParenthesis` missing from close braces

| Predicate                     | Includes `isOpenParenthesis`? |
| ----------------------------- | ----------------------------- |
| `isCloseParenthesisDelimiter` | Yes (line 122)                |
| `isCloseBracketDelimiter`     | Yes (line 144)                |
| `isCloseBracesDelimiter`      | **No**                        |

This means `)(` and `](` are valid, but `}(` is not. If Primal allows expressions like `{...}(args)` (e.g., calling a lambda returned from a map/block), this would fail.

#### Full Comparison Matrix

Comparing the three close-delimiter predicates side by side:

| Character class    | `)`   | `]`   | `}`   |
| ------------------ | ----- | ----- | ----- |
| isWhitespace       | Y     | Y     | Y     |
| isComma            | Y     | Y     | Y     |
| isColon            | **Y** | **N** | **N** |
| isLetter           | Y     | Y     | Y     |
| isOpenParenthesis  | Y     | Y     | **N** |
| isCloseParenthesis | Y     | Y     | Y     |
| isOpenBracket      | Y     | Y     | Y     |
| isCloseBracket     | Y     | Y     | Y     |
| isCloseBraces      | N     | Y     | Y     |
| isBinaryOperator   | Y     | Y     | Y     |

### Proposed Fix

Add the missing character classes to restore symmetry:

1. Add `isColon` to `isCloseBracketDelimiter` and `isCloseBracesDelimiter`
2. Add `isOpenParenthesis` to `isCloseBracesDelimiter`

Before making these changes, verify with the language specification / test suite that these sequences should indeed be valid. If `]:` and `}(` are intentionally disallowed, the asymmetry is by design and should be documented.

### Files to Modify

- `lib/extensions/string_extensions.dart` -- add missing predicates to `isCloseBracketDelimiter` and `isCloseBracesDelimiter`
- `test/compiler/lexical_analyzer_test.dart` -- add tests for `]:`, `}:`, `}(`

### Priority

**Low** -- These may be intentional restrictions. Needs language-level decision before changing.

---

## Implementation Order

If all issues are to be addressed, the recommended order is:

| Order | Issue                         | Rationale                                          |
| ----- | ----------------------------- | -------------------------------------------------- |
| 1     | #3 Escape sequences           | New functionality, explicitly requested            |
| 2     | #4 Unterminated errors        | Directly related to string handling changes in #3  |
| 3     | #2 Regex performance          | Standalone, no dependencies, high impact           |
| 4     | #1 End-of-input flush         | Small, standalone                                  |
| 5     | #9 ResultState single token   | Small mechanical refactor                          |
| 6     | #10 Delimiter inconsistencies | Requires language-level decisions                  |
| 7     | #5 Single-char lookahead      | Requires decision on strictness tradeoff           |
| 8     | #6 Operator adjacency         | Requires language-level decisions + parser changes |
| 9     | #7 Lexeme O(n^2)              | Low priority, only matters for very long tokens    |
| 10    | #8 Token boilerplate          | Large refactor, low value                          |
