### 2. `list.zip` reports incomplete type information in error

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_zip.dart`
**Line**: 57-63

- **Issue**: When throwing `InvalidArgumentTypesError`, only `a.type` is passed to the `actual` parameter, but all three types (`a.type, b.type, c.type`) should be included for accurate error reporting.

- **Impact**: Error messages will be confusing and incomplete when invalid argument types are passed to `list.zip`.

- **Fix**:

```dart
throw InvalidArgumentTypesError(
  function: name,
  expected: parameterTypes,
  actual: [a.type, b.type, c.type],  // Include all three types
);
```

**Follow-up**:

- **Tests**:
  - Success case: Test `list.zip` with valid arguments
  - Failure case: Test error message includes all argument types when given invalid types
- **Docs**: No doc changes needed

---

### 3. Static mutable state for recursion depth counter

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/runtime/node.dart`
**Line**: 311-349

- **Issue**: `FunctionNode._currentDepth` is a static mutable field shared across all evaluations. While `resetDepth()` exists, there's no guarantee it will be called before each evaluation. If an exception occurs during evaluation (after depth was incremented), the depth counter might not be properly decremented, leaving stale state that could affect subsequent evaluations.

- **Impact**: In scenarios with multiple sequential evaluations (REPL, test suite, web server), a failed evaluation could leave the depth counter in an incorrect state, potentially causing premature `RecursionLimitError` in subsequent evaluations.

- **Fix**: Ensure `resetDepth()` is called at the start of every top-level evaluation, or consider using a context object passed through the evaluation chain instead of static state.

**Follow-up**:

- **Tests**:
  - Success case: Multiple sequential evaluations work correctly
  - Failure case: After an evaluation that throws mid-recursion, subsequent evaluations still work
- **Docs**: No doc changes needed

---

### 4. Inconsistent behavior between `list.take`/`list.drop` and `str.take`/`str.drop`

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_take.dart`, `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/string/str_take.dart` (and corresponding `drop` files)
**Lines**: Various

- **Issue**: `list.take(list, n)` and `str.take(str, n)` throw `IndexOutOfBoundsError` when `n > length`. This is inconsistent with common functional programming conventions where `take` typically returns as many elements as available (clamping to length). The same applies to `drop`.

- **Impact**: Users familiar with functional programming patterns may be surprised by the strict bounds checking, leading to more defensive code or unexpected runtime errors.

- **Fix**: Consider allowing `take`/`drop` to clamp the count to the collection length rather than throwing. If strict behavior is desired, document it clearly.

**Follow-up**:

- **Tests**: Current behavior is correct per implementation; add tests documenting this design choice
- **Docs**: Update `docs/reference/list.md` and `docs/reference/string.md` to clarify bounds behavior

---

## Info

### 1. Missing `const` constructor on several `NativeFunctionNode` subclasses

**Files**: Multiple files in `lib/compiler/library/`

- **Issue**: Many `NativeFunctionNode` subclasses (e.g., `ListFirst`, `NumAbs`, etc.) define constructors without the `const` keyword, even though they could be const. This is a minor optimization opportunity.

- **Impact**: Minimal - prevents potential compile-time constant folding, but no functional impact.

- **Fix**: Add `const` keyword to constructors that only call super with constant values.

**Follow-up**:

- **Tests**: No tests needed
- **Docs**: No doc changes needed

---

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
