### 5. Inconsistent empty collection handling between init/rest and first/last

**File**: Multiple files in `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/`

- **Issue**: `list.first` and `list.last` throw `EmptyCollectionError` on empty lists, while `list.init` and `list.rest` return empty lists on empty input. Similarly for strings.
- **Impact**: This is actually intentional and documented behavior - `init` and `rest` are designed to be safe operations that work on empty collections, while `first` and `last` require at least one element.
- **Suggestion**: No change needed - this is consistent with common functional programming conventions (Haskell, etc.).

**Follow-up**:

- **Tests**: Verify both behaviors are tested
- **Docs**: Current docs are accurate
