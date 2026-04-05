### 3. json.decode silently filters null values from arrays and maps

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/json/json_decode.dart`
**Lines**: 70-84

- **Issue**: When decoding JSON, null values in arrays are silently removed (`element.where((e) => e != null)`) and null values in maps are skipped (`if (value != null)`). This is intentional since Primal doesn't support null, but it means the decoded data structure may have fewer elements than the original JSON.

- **Impact**: Users may be surprised that `json.decode("[1, null, 2]")` returns `[1, 2]` instead of throwing an error. The current behavior is reasonable but could be better documented.

- **Fix**: No code change needed, but add documentation.

**Follow-up**:

- **Tests**: Tests already exist covering this behavior
- **Docs**: Update `docs/reference/json.md` to document that null values are stripped during decoding

---

### 4. list.zip behavior with mismatched lengths may be unexpected

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_zip.dart`
**Lines**: 32-56

- **Issue**: When the two input lists have different lengths, `list.zip` applies the function only where both elements exist, and includes remaining elements unmodified. This is a valid design choice but differs from typical zip implementations that either truncate to the shorter length or require equal lengths.

- **Impact**: Users familiar with zip from other languages may expect different behavior. The function works correctly but could benefit from clearer documentation.

- **Fix**: No code change needed, but add documentation.

**Follow-up**:

- **Tests**: Existing tests should cover this behavior
- **Docs**: Update `docs/reference/list.md` to clarify the behavior with mismatched lengths

---

## Notes

The codebase is well-structured with consistent patterns:

- Empty collection checks are properly implemented throughout (`list.first`, `list.last`, `stack.peek`, etc.)
- Division by zero is consistently checked in division and modulo operations
- Index bounds checking is thorough in list, string, and map access functions
- Error handling follows a consistent pattern with descriptive error types
- The lexer state machine is complete and handles all edge cases including escape sequences

Static analysis (`dart analyze`) reports no issues, confirming the codebase follows Dart best practices.
