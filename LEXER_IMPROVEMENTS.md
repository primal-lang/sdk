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
