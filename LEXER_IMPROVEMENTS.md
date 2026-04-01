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
