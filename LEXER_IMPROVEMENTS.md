## 1. Bug: Multi-line comments with consecutive asterisks fail to close

### Problem

Comments like `/***/` or `/* ** */` throw `UnterminatedCommentError` when they should be valid.

**Trace for `/\***/`\*\*:

1. `/` - `InitState` dispatches to `ForwardSlashState`
2. `*` - `ForwardSlashState` transitions to `StartMultiLineCommentState`
3. `*` - `StartMultiLineCommentState` sees `*`, transitions to `ClosingMultiLineCommentState`
4. `*` - `ClosingMultiLineCommentState` sees `*` (not `/`), transitions **back** to `StartMultiLineCommentState`
5. `/` - `StartMultiLineCommentState` sees `/` (not `*`), stays in `StartMultiLineCommentState`
6. End of input - throws `UnterminatedCommentError`

**Root cause**: `ClosingMultiLineCommentState` goes back to `StartMultiLineCommentState` when it sees `*`, but it should stay in `ClosingMultiLineCommentState` because that `*` could be the start of `*/`.

### Solution

Modify `ClosingMultiLineCommentState.process()` to handle `*` by staying in `ClosingMultiLineCommentState`:

**Current code** (`lexical_analyzer.dart:752-762`):

```dart
class ClosingMultiLineCommentState extends State<Character, void> {
  const ClosingMultiLineCommentState(super.iterator, [super.output]);

  @override
  State process(Character input) {
    if (!input.value.isForwardSlash) {
      return StartMultiLineCommentState(iterator);  // BUG: * goes back too
    } else {
      return InitState(iterator);
    }
  }
}
```

**Fixed code**:

```dart
class ClosingMultiLineCommentState extends State<Character, void> {
  const ClosingMultiLineCommentState(super.iterator, [super.output]);

  @override
  State process(Character input) {
    if (input.value.isForwardSlash) {
      return InitState(iterator);
    } else if (input.value.isAsterisk) {
      return ClosingMultiLineCommentState(iterator);  // Stay here for consecutive *
    } else {
      return StartMultiLineCommentState(iterator);
    }
  }
}
```

**Correct trace for `/\***/` after fix\*\*:

1. `/` - `ForwardSlashState`
2. `*` - `StartMultiLineCommentState`
3. `*` - `ClosingMultiLineCommentState`
4. `*` - stays in `ClosingMultiLineCommentState`
5. `/` - `InitState` (comment closed correctly)

### Steps

1. Modify `ClosingMultiLineCommentState.process()` as shown above
2. Add test cases:
   - `/***/` - should produce no tokens
   - `/****/` - should produce no tokens
   - `/* * * */` - should produce no tokens
   - `/* ** /` - should throw `UnterminatedCommentError`
3. Update `docs/compiler/lexical.md` if needed (current docs don't describe this edge case)

---

## 2. Code Duplication: Single/double quote string states

### Problem

There are 6 pairs of nearly-identical state classes for single vs double quoted strings:

| Double Quote State                    | Single Quote State                    |
| ------------------------------------- | ------------------------------------- |
| `StringDoubleQuoteState`              | `StringSingleQuoteState`              |
| `StringDoubleQuoteEscapeState`        | `StringSingleQuoteEscapeState`        |
| `StringDoubleQuoteHexEscapeState`     | `StringSingleQuoteHexEscapeState`     |
| `StringDoubleQuoteUnicodeEscapeState` | `StringSingleQuoteUnicodeEscapeState` |
| `StringDoubleQuoteBracedEscapeState`  | `StringSingleQuoteBracedEscapeState`  |

The only difference is which quote character terminates the string and which state to return to. This results in ~240 lines of duplicated code.

### Solution

Create a parameterized set of string states that accept a `QuoteType` enum:

```dart
enum QuoteType { single, double }

extension QuoteTypeExtension on QuoteType {
  bool isTerminator(String char) => switch (this) {
    QuoteType.single => char.isSingleQuote,
    QuoteType.double => char.isDoubleQuote,
  };
}
```

Then unify the state classes:

```dart
class StringState extends State<Character, Lexeme> {
  final QuoteType quoteType;

  const StringState(super.iterator, super.output, this.quoteType);

  @override
  State process(Character input) {
    if (quoteType.isTerminator(input.value)) {
      return ResultState(iterator, StringToken(output));
    } else if (input.value.isBackslash) {
      return StringEscapeState(iterator, output, quoteType);
    } else {
      return StringState(iterator, output.add(input), quoteType);
    }
  }
}
```

Apply the same pattern to `StringEscapeState`, `StringHexEscapeState`, `StringUnicodeEscapeState`, and `StringBracedEscapeState`.

### Steps

1. Create `QuoteType` enum with `single` and `double` values
2. Create unified `StringState` class parameterized by `QuoteType`
3. Create unified `StringEscapeState` class parameterized by `QuoteType`
4. Create unified `StringHexEscapeState` class parameterized by `QuoteType`
5. Create unified `StringUnicodeEscapeState` class parameterized by `QuoteType`
6. Create unified `StringBracedEscapeState` class parameterized by `QuoteType`
7. Update `InitState` to use the new classes:
   ```dart
   } else if (input.value.isDoubleQuote) {
     return StringState(iterator, Lexeme(value: '', location: input.location), QuoteType.double);
   } else if (input.value.isSingleQuote) {
     return StringState(iterator, Lexeme(value: '', location: input.location), QuoteType.single);
   }
   ```
8. Update end-of-input handling in `analyze()` to check for `StringState`, `StringEscapeState`, etc.
9. Remove the old 10 separate string state classes
10. Update tests to ensure behavior is unchanged
11. Update documentation if class names are mentioned

---

## 3. Fragility: End-of-input handling in `analyze()`

### Problem

The `analyze()` method has a long if-else chain (lines 29-67) checking for every possible string-related state:

```dart
} else if (state is StringDoubleQuoteState) {
  throw UnterminatedStringError(state.output.location);
} else if (state is StringSingleQuoteState) {
  throw UnterminatedStringError(state.output.location);
} else if (state is StringDoubleQuoteEscapeState) {
  throw UnterminatedStringError(state.output.location);
// ... 8 more checks
```

If a new string escape state is added, this list must be manually updated. Forgetting to do so would cause the analyzer to silently accept unterminated strings.

### Solution

Create a marker interface or base class for states that represent "inside a string":

```dart
abstract class StringRelatedState<T> extends State<Character, T> {
  const StringRelatedState(super.iterator, super.output);

  Location get stringStartLocation;
}
```

Have all string states extend this:

```dart
class StringState extends StringRelatedState<Lexeme> {
  // ...

  @override
  Location get stringStartLocation => output.location;
}
```

Then simplify the end-of-input check:

```dart
} else if (state is StringRelatedState) {
  throw UnterminatedStringError(state.stringStartLocation);
}
```

### Steps

1. Define `StringRelatedState` abstract class with `stringStartLocation` getter
2. Have all string states extend `StringRelatedState`
3. Replace the 10 if-else checks with a single `is StringRelatedState` check
4. Ensure tests still pass

---

## 4. Enhancement: Underscore separators in numbers

### Problem

Many modern languages allow `1_000_000` for readability. Currently, `IntegerState` and `DecimalState` only accept digits.

### Solution

Modify `IntegerState` and `DecimalState` to accept `_` between digits:

```dart
class IntegerState extends State<Character, Lexeme> {
  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return IntegerState(iterator, output.add(input));
    } else if (input.value == '_') {
      // Underscore allowed, but don't add to lexeme (or add and strip later)
      return IntegerState(iterator, output);  // Skip the underscore
    } else if (input.value.isDot) {
      return DecimalInitState(iterator, output.add(input));
    } else if (input.value.isOperandDelimiter) {
      iterator.back();
      return ResultState(iterator, NumberToken(output));
    } else {
      throw InvalidCharacterError(input, 'digit, underscore, or dot');
    }
  }
}
```

**Considerations**:

- Should `_` be allowed at the start? (No: `_123` is an identifier)
- Should `_` be allowed at the end? (Probably no: `123_` looks unfinished)
- Should consecutive `__` be allowed? (Debatable)

### Steps

1. Decide on underscore rules (start/end/consecutive)
2. Modify `IntegerState` to accept `_` between digits
3. Modify `DecimalState` to accept `_` between digits
4. Add validation for leading/trailing underscores if disallowed
5. Add test cases: `1_000`, `1_000_000`, `3.14_159`, edge cases
6. Update documentation

---

## 5. Enhancement: Scientific notation

### Problem

Numbers like `1e10` or `1.5e-3` are not supported.

### Solution

Add new states for scientific notation:

```dart
// After IntegerState or DecimalState sees 'e' or 'E'
class ExponentInitState extends State<Character, Lexeme> {
  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return ExponentState(iterator, output.add(input));
    } else if (input.value == '+' || input.value == '-') {
      return ExponentSignState(iterator, output.add(input));
    } else {
      throw InvalidCharacterError(input, 'digit or sign');
    }
  }
}

class ExponentSignState extends State<Character, Lexeme> {
  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return ExponentState(iterator, output.add(input));
    } else {
      throw InvalidCharacterError(input, 'digit');
    }
  }
}

class ExponentState extends State<Character, Lexeme> {
  @override
  State process(Character input) {
    if (input.value.isDigit) {
      return ExponentState(iterator, output.add(input));
    } else if (input.value.isOperandDelimiter) {
      iterator.back();
      return ResultState(iterator, NumberToken(output));
    } else {
      throw InvalidCharacterError(input, 'digit');
    }
  }
}
```

Modify `IntegerState` and `DecimalState` to transition to `ExponentInitState` on `e` or `E`.

### Steps

1. Create `ExponentInitState`, `ExponentSignState`, `ExponentState`
2. Modify `IntegerState` to transition to `ExponentInitState` on `e`/`E`
3. Modify `DecimalState` to transition to `ExponentInitState` on `e`/`E`
4. Add end-of-input handling for exponent states
5. Add test cases: `1e10`, `1E10`, `1e+10`, `1e-10`, `1.5e10`, `1.5e-3`
6. Update documentation
