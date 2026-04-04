### 3. `InvalidArgumentTypesError` in `list.filter` reports incomplete actual types
ri
**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_filter.dart`
**Line**: 60

- **Issue**: The error thrown reports `actual: [a.type]` but the function takes two parameters (list and function). This inconsistency makes the error message confusing because it only shows one actual type while `expected` shows two (`parameterTypes`).
- **Impact**: Users see a confusing error message that doesn't fully describe the type mismatch.
- **Fix**:

```dart
throw InvalidArgumentTypesError(
  function: name,
  expected: parameterTypes,
  actual: [a.type, b.type],
);
```

**Follow-up**:

- **Tests**: Add/update tests to cover this case
  - Success case: Verify filter works with correct types
  - Failure case: Verify error message correctly shows both actual types when passed wrong types
- **Docs**: No doc changes needed

---

### 4. `list.sort` error reports incomplete actual types

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_sort.dart`
**Line**: 58

- **Issue**: Same issue as `list.filter` - the error reports `actual: [a.type]` instead of `actual: [a.type, b.type]`.
- **Impact**: Confusing error message for users.
- **Fix**:

```dart
throw InvalidArgumentTypesError(
  function: name,
  expected: parameterTypes,
  actual: [a.type, b.type],
);
```

**Follow-up**:

- **Tests**: Add/update tests to cover this case
  - Success case: Verify sort works with correct types
  - Failure case: Verify error message correctly shows both actual types
- **Docs**: No doc changes needed

## Info

### 1. `list.any` and `list.none` report incomplete actual types

**Files**:

- `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_any.dart` (line 58)
- `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_none.dart` (line 58)

- **Issue**: Both functions report `actual: [a.type]` in their `InvalidArgumentTypesError` instead of including both argument types.
- **Impact**: Minor - error messages are slightly less informative.
- **Suggested improvement**: Change to `actual: [a.type, b.type]` for consistency.

---

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
