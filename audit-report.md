### 1. Redundant empty collection check in `vector.normalize`

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/vector/vector_normalize.dart`
**Lines**: 37-39

- **Issue**: Empty vectors are returned early, but an empty vector's magnitude is 0, which would be caught by the division-by-zero check on line 46-47.

- **Rationale**: The early return is actually a performance optimization and provides a cleaner error path (returning the empty vector rather than erroring). This is intentional defensive programming.

- **Recommendation**: Keep as-is; the explicit empty check improves clarity.

---

### 2. String building in `Lexeme.add` uses concatenation

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/lexical/lexeme.dart`
**Line**: 11-14

- **Issue**: The `add` method creates a new `Lexeme` with `value + charValue` for each character. For very long strings, this creates O(n^2) string allocations.

- **Impact**: Minimal in practice since Primal strings in source code are typically short. Only becomes a concern for pathologically long string literals.

- **Recommendation**: Consider using `StringBuffer` if performance becomes an issue with very long strings, but current implementation is acceptable.

---

### 3. `LiteralNode.from` doesn't handle all collection node types

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/runtime/node.dart`
**Lines**: 37-59

- **Issue**: The factory method handles `List<Node>`, `Set<Node>`, and `Map<Node, Node>`, but doesn't check for `StackNode`, `QueueNode`, or `VectorNode` inner types explicitly.

- **Impact**: Low. This factory is mainly used for JSON decoding and literal construction where Stack/Queue/Vector wouldn't appear in the raw dynamic value. The existing code works correctly for its intended use cases.

- **Recommendation**: No change needed; the implementation matches its actual usage patterns.

---

### 4. `ResultState.next` throws `StateError` instead of returning self

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/syntactic/syntactic_analyzer.dart`
**Lines**: 144-147

- **Issue**: The `ResultState.next` getter throws a `StateError` with a helpful message explaining that callers should check for `ResultState` before calling `next`.

- **Rationale**: This is actually good defensive programming. The error message is clear and helps developers understand the contract. The main loop in `analyze()` correctly checks for `ResultState` before calling `next`.

- **Recommendation**: Keep as-is; this is intentional fail-fast behavior.

---

### 5. Missing `const` constructor on `Bindings` class

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/runtime/bindings.dart`
**Line**: 8

- **Issue**: The `Bindings` class has a `const` constructor, but the `Bindings.from` factory creates instances with mutable `Map<String, Node>` contents (via `{}` literal and loop assignment).

- **Impact**: None. The class correctly uses a non-const factory for runtime construction while keeping the basic constructor const-capable for cases where a pre-built const map could be passed.

- **Recommendation**: The current design is appropriate. The `const` constructor enables potential optimization when const bindings are known at compile time.
