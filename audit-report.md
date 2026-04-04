### 2. Potential performance: `NumberToken` parses underscore-containing numbers

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/lexical/token.dart`
**Line**: 38

- **Issue**: `NumberToken` uses `num.parse(lexeme.value)` but the lexeme may contain underscores (e.g., `1_000_000`). Dart's `num.parse` does not support underscores, so if the lexer passes them through, parsing would fail. However, reviewing the lexer shows underscores are not included in the output lexeme - the `IntegerState`, `DecimalState`, and `ExponentState` only add digits to the output, not underscores. This is correct behavior, but the relationship is implicit and could be a source of bugs if the lexer is modified.
- **Impact**: None currently, but potential for future bugs if lexer behavior changes.
- **Suggested improvement**: Add a comment in `NumberToken` noting that the lexeme value must not contain underscores.

---

### 3. String concatenation in `str.removeAt`

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/string/str_remove_at.dart`
**Line**: 50

- **Issue**: Uses string concatenation `chars.take(index).toString() + chars.skip(index + 1).toString()` which creates an intermediate string. For very long strings, this could be slightly less efficient than using a StringBuffer.
- **Impact**: Minor performance concern for very large strings, but unlikely to be noticeable in practice.
- **Suggested improvement**: Consider using `StringBuffer` for consistency with best practices, though the current approach is acceptable.
