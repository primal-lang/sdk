### 4. `NumberToken` parsing could fail on malformed lexer output

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/lexical/token.dart`
**Line**: 37-43

- **Issue**: `NumberToken` constructor calls `num.parse(lexeme.value)` directly. If the lexer ever produced an invalid numeric string, this would throw a `FormatException`. However, the lexer properly validates numeric literals, making this a defensive observation.

- **Impact**: None currently - the lexer ensures only valid numeric strings reach `NumberToken`.

- **Fix**: The current design relies on lexer correctness, which is reasonable. Could add a try-catch with a descriptive error for extra safety.

**Follow-up**:

- **Tests**: Add tests verifying lexer rejects malformed numbers
- **Docs**: No doc changes needed
