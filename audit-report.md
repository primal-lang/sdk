### 2. Potential string concatenation in hot path (str.removeAt)

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/string/str_remove_at.dart`
**Line**: 49-51

- **Issue**: Uses string concatenation (`+`) to join two string parts. For very long strings with many removals, this could be slightly inefficient.

- **Impact**: Minimal - only relevant for performance-critical code with very long strings.

- **Fix**: Consider using `StringBuffer` or direct character manipulation if this becomes a bottleneck.

**Follow-up**:

- **Tests**: No tests needed
- **Docs**: No doc changes needed

---

### 3. `ListIterator.advance()` doesn't check bounds

**File**: `/home/max/Repositories/personal/primal-sdk/lib/utils/list_iterator.dart`
**Line**: 44-46

- **Issue**: The `advance()` method increments `_index` without checking if it's already at or past the end. Unlike `next` which throws, `advance()` will silently move past the end.

- **Impact**: Low - all current usages appear to check `hasNext` or `isAtEnd` before calling `advance()`, so this is defensive programming suggestion.

- **Fix**: Could add a bounds check, but current usage patterns make this a non-issue.

**Follow-up**:

- **Tests**: Add edge case tests for iterator at end
- **Docs**: No doc changes needed

---

### 4. `NumberToken` parsing could fail on malformed lexer output

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/lexical/token.dart`
**Line**: 37-43

- **Issue**: `NumberToken` constructor calls `num.parse(lexeme.value)` directly. If the lexer ever produced an invalid numeric string, this would throw a `FormatException`. However, the lexer properly validates numeric literals, making this a defensive observation.

- **Impact**: None currently - the lexer ensures only valid numeric strings reach `NumberToken`.

- **Fix**: The current design relies on lexer correctness, which is reasonable. Could add a try-catch with a descriptive error for extra safety.

**Follow-up**:

- **Tests**: Add tests verifying lexer rejects malformed numbers
- **Docs**: No doc changes needed
