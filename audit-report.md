### 1. Missing const constructors on immutable Type subclasses

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/models/type.dart`
**Lines**: 1-108

- **Issue**: The base `Type` class and all its subclasses have only `final` fields (none in this case) but don't override `==` and `hashCode`. While the current code uses `const` constructors which works with `identical`, explicit equality would be more robust.
- **Impact**: Type comparisons rely on object identity rather than structural equality. This works because all instances are `const`, but is fragile if non-const instances are ever created.
- **Suggestion**: Add `==` and `hashCode` overrides to `Type` subclasses for defensive programming.

**Follow-up**:

- **Tests**: Verify type equality works as expected
- **Docs**: No doc changes needed

---

### 2. ListIterator.back() silently does nothing at position 0

**File**: `/home/max/Repositories/personal/primal-sdk/lib/utils/list_iterator.dart`
**Line**: 50-54

- **Issue**: `back()` silently does nothing when already at position 0, which could mask bugs in calling code.
- **Impact**: Minor - current usage in the lexer is correct, but future changes could introduce subtle bugs.
- **Suggestion**: Consider throwing an error or returning a boolean indicating success.

**Follow-up**:

- **Tests**: Current behavior is intentional for the lexer's usage pattern
- **Docs**: No doc changes needed

---

### 3. String concatenation in loop in error message construction

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/string/str_remove_at.dart`
**Line**: 50

- **Issue**: Uses `+` for string concatenation: `chars.take(index).toString() + chars.skip(index + 1).toString()`. This is in a single operation, not a loop, so performance impact is negligible.
- **Impact**: None in practice - this is a false positive based on the audit criteria. The concatenation happens once per function call, not in a loop.
- **Suggestion**: No change needed.

**Follow-up**:

- **Tests**: N/A
- **Docs**: No doc changes needed

---

### 4. try() function catches all exceptions including OutOfMemoryError

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/control/try.dart`
**Line**: 36

- **Issue**: The `catch (_)` clause catches all exceptions, including `Error` types like `OutOfMemoryError` or `StackOverflowError`.
- **Impact**: In rare cases, severe errors that should crash the program could be silently swallowed. However, this matches the documented behavior of `try()` and is consistent with the language's design philosophy.
- **Suggestion**: This is acceptable given the documented semantics. The function is designed to catch all errors.

**Follow-up**:

- **Tests**: Verify `try()` catches various error types as documented
- **Docs**: Current docs are accurate

---

### 5. Inconsistent empty collection handling between init/rest and first/last

**File**: Multiple files in `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/`

- **Issue**: `list.first` and `list.last` throw `EmptyCollectionError` on empty lists, while `list.init` and `list.rest` return empty lists on empty input. Similarly for strings.
- **Impact**: This is actually intentional and documented behavior - `init` and `rest` are designed to be safe operations that work on empty collections, while `first` and `last` require at least one element.
- **Suggestion**: No change needed - this is consistent with common functional programming conventions (Haskell, etc.).

**Follow-up**:

- **Tests**: Verify both behaviors are tested
- **Docs**: Current docs are accurate
