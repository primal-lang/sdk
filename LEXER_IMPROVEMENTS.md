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

Update and/or add unit tests if necessary.
