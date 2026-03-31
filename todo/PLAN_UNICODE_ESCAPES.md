# Plan: Unicode Escape Sequences

## Escape Formats to Support

| Format | Digits | Range | Example |
|--------|--------|-------|---------|
| `\xXX` | 2 hex (fixed) | U+0000 - U+00FF | `\x41` → "A" |
| `\uXXXX` | 4 hex (fixed) | U+0000 - U+FFFF | `\u03B1` → "α" |
| `\u{X...}` | 1-6 hex (variable) | U+0000 - U+10FFFF | `\u{1F600}` → "😀" |

The braced format (`\u{...}`) follows JavaScript ES6 and Rust conventions.

## Files to Modify

1. **`lib/extensions/string_extensions.dart`**
   - Add `isHexDigit` getter

2. **`lib/compiler/errors/lexical_error.dart`**
   - Add `InvalidHexEscapeError` class (fixed-length escapes)
   - Add `InvalidBracedEscapeError` class (braced escapes)
   - Add `InvalidCodePointError` class (out-of-range code points)

3. **`lib/compiler/lexical/lexical_analyzer.dart`**
   - Update `StringDoubleQuoteEscapeState.process()` to detect `x`, `u`
   - Update `StringSingleQuoteEscapeState.process()` to detect `x`, `u`
   - Add new state classes (6 total - 3 per quote type):
     - `StringDoubleQuoteHexEscapeState` - fixed 2-digit `\xXX`
     - `StringDoubleQuoteUnicodeEscapeState` - dispatch for `\u`
     - `StringDoubleQuoteBracedEscapeState` - variable `\u{...}`
     - `StringSingleQuoteHexEscapeState`
     - `StringSingleQuoteUnicodeEscapeState`
     - `StringSingleQuoteBracedEscapeState`
   - Update end-of-input handling for new states

4. **`docs/compiler/lexical.md`**
   - Update "String Escape Sequences" section with new escapes
   - Add new states to internal states table

5. **`test/compiler/lexical_analyzer_test.dart`**
   - Add tests for `\xXX` (valid + invalid)
   - Add tests for `\uXXXX` (valid + invalid)
   - Add tests for `\u{...}` (valid + invalid)
   - Add tests for edge cases (empty braces, too many digits, out of range)

---

## Implementation Details

### 1. Add hex digit helper (`string_extensions.dart`)

```dart
bool get isHexDigit => RegExp(r'[0-9a-fA-F]').hasMatch(this);
```

### 2. New error classes (`lexical_error.dart`)

```dart
class InvalidHexEscapeError extends LexicalError {
  InvalidHexEscapeError(Character character, String escapeType, int expected)
    : super(
        'Invalid hex escape: expected $expected hex digits after '
        "'\\$escapeType', got '${character.value}' at ${character.location}",
      );
}

class InvalidBracedEscapeError extends LexicalError {
  InvalidBracedEscapeError(String message, Location location)
    : super('$message at $location');
}

class InvalidCodePointError extends LexicalError {
  InvalidCodePointError(int codePoint, Location location)
    : super(
        'Invalid code point U+${codePoint.toRadixString(16).toUpperCase().padLeft(4, '0')}: '
        'exceeds maximum U+10FFFF at $location',
      );
}
```

### 3. State machine changes (`lexical_analyzer.dart`)

**Update escape states** to detect hex escapes:
```dart
// In StringDoubleQuoteEscapeState.process():
} else if (input.value == 'x') {
  return StringDoubleQuoteHexEscapeState(iterator, output, 2, '', input.location);
} else if (input.value == 'u') {
  return StringDoubleQuoteUnicodeEscapeState(iterator, output, input.location);
} else {
  throw InvalidEscapeSequenceError(input);
}
```

**Add fixed-length hex escape state** (for `\xXX`):
```dart
class StringDoubleQuoteHexEscapeState extends State<Character, Lexeme> {
  final int requiredDigits;   // 2 for \x
  final String hexAccum;      // accumulated hex digits
  final Location escapeStart; // for error reporting

  const StringDoubleQuoteHexEscapeState(
    super.iterator,
    super.output,
    this.requiredDigits,
    this.hexAccum,
    this.escapeStart,
  );

  @override
  State process(Character input) {
    if (!input.value.isHexDigit) {
      throw InvalidHexEscapeError(input, 'x', requiredDigits);
    }

    final String newHex = hexAccum + input.value;

    if (newHex.length == requiredDigits) {
      final int codePoint = int.parse(newHex, radix: 16);
      return StringDoubleQuoteState(
        iterator,
        output.addValue(String.fromCharCode(codePoint)),
      );
    }

    return StringDoubleQuoteHexEscapeState(
      iterator, output, requiredDigits, newHex, escapeStart,
    );
  }
}
```

**Add unicode escape state** (handles both `\uXXXX` and `\u{X...}`):
```dart
class StringDoubleQuoteUnicodeEscapeState extends State<Character, Lexeme> {
  final Location escapeStart;

  const StringDoubleQuoteUnicodeEscapeState(
    super.iterator,
    super.output,
    this.escapeStart,
  );

  @override
  State process(Character input) {
    if (input.value == '{') {
      // Braced format: \u{...}
      return StringDoubleQuoteBracedEscapeState(iterator, output, '', escapeStart);
    } else if (input.value.isHexDigit) {
      // Fixed 4-digit format: \uXXXX
      return StringDoubleQuoteHexEscapeState(
        iterator, output, 4, input.value, escapeStart,
      );
    } else {
      throw InvalidHexEscapeError(input, 'u', 4);
    }
  }
}
```

**Add braced escape state** (for `\u{X...}`):
```dart
class StringDoubleQuoteBracedEscapeState extends State<Character, Lexeme> {
  final String hexAccum;      // accumulated hex digits (1-6)
  final Location escapeStart;

  const StringDoubleQuoteBracedEscapeState(
    super.iterator,
    super.output,
    this.hexAccum,
    this.escapeStart,
  );

  @override
  State process(Character input) {
    if (input.value == '}') {
      if (hexAccum.isEmpty) {
        throw InvalidBracedEscapeError('Empty \\u{} escape', escapeStart);
      }
      final int codePoint = int.parse(hexAccum, radix: 16);
      if (codePoint > 0x10FFFF) {
        throw InvalidCodePointError(codePoint, escapeStart);
      }
      return StringDoubleQuoteState(
        iterator,
        output.addValue(String.fromCharCode(codePoint)),
      );
    } else if (input.value.isHexDigit) {
      if (hexAccum.length >= 6) {
        throw InvalidBracedEscapeError(
          'Too many digits in \\u{} escape (max 6)', escapeStart);
      }
      return StringDoubleQuoteBracedEscapeState(
        iterator, output, hexAccum + input.value, escapeStart,
      );
    } else {
      throw InvalidBracedEscapeError(
        "Invalid character '${input.value}' in \\u{} escape", escapeStart);
    }
  }
}
```

**Duplicate for single quotes**: Create matching `StringSingleQuote*` versions of all three states (identical logic, return to `StringSingleQuoteState`)

### 4. Update unterminated string handling

In `LexicalAnalyzer.analyze()`, add checks for all hex escape states at end-of-input:
```dart
} else if (state is StringDoubleQuoteHexEscapeState) {
  throw UnterminatedStringError(state.output.location);
} else if (state is StringDoubleQuoteUnicodeEscapeState) {
  throw UnterminatedStringError(state.output.location);
} else if (state is StringDoubleQuoteBracedEscapeState) {
  throw UnterminatedStringError(state.output.location);
// ... same for SingleQuote variants
```

---

## Test Cases

**Valid fixed-length escapes (`\x`, `\u`):**
- `"\x41"` → "A"
- `"\x00"` → null character
- `"\u0041"` → "A"
- `"\u03B1"` → "α"
- `"\u0000"` → null character

**Valid braced escapes (`\u{...}`):**
- `"\u{41}"` → "A"
- `"\u{0041}"` → "A" (leading zeros ok)
- `"\u{3B1}"` → "α"
- `"\u{1F600}"` → "😀"
- `"\u{10FFFF}"` → max code point

**Mixed escapes:**
- `"\u0041\u0042"` → "AB"
- `"\u{48}ello"` → "Hello"
- `"Say \x22hi\x22"` → `Say "hi"`

**Invalid escapes:**
- `"\u41"` → error (only 2 digits, needs 4)
- `"\uGGGG"` → error (non-hex)
- `"\x4"` → error (only 1 digit, needs 2)
- `"\xGG"` → error (non-hex)
- `"\u{}"` → error (empty braces)
- `"\u{GGGG}"` → error (non-hex in braces)
- `"\u{1234567}"` → error (too many digits, max 6)
- `"\u{110000}"` → error (exceeds U+10FFFF)
- `"\u{41"` → error (missing closing brace)
- `"\u004` (EOF) → unterminated string error

---

## Verification

1. Run existing tests: `dart test test/compiler/lexical_analyzer_test.dart`
2. Run new tests for Unicode escapes
3. Manual test in REPL:
   ```
   > "\u0048\u0065\u006C\u006C\u006F"
   Hello
   > "\u{1F600}"
   😀
   > "\x48\x69"
   Hi
   ```
