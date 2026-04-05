### 3. `operator-` allows asymmetric set operations that may confuse users

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/operators/operator_sub.dart`
**Lines**: 45-56

- **Issue**: When subtracting between a `SetNode` and a non-set value, both `(set - element)` and `(element - set)` call `SetRemove.execute` with swapped arguments, making `element - set` behave identically to `set - element`. This is mathematically unintuitive.

- **Impact**: User confusion. `5 - {1, 5, 10}` returns `{1, 10}` (same as `{1, 5, 10} - 5`), which is unexpected. Most users would expect either an error or a completely different semantic.

- **Fix**: Consider throwing an error for `(non-set - set)` operations:

```dart
} else if ((a is! SetNode) && (b is SetNode)) {
  throw InvalidArgumentTypesError(
    function: name,
    expected: parameterTypes,
    actual: [a.type, b.type],
  );
}
```

**Follow-up**:

- **Tests**:
  - Success case: `{1, 2, 3} - 2` should return `{1, 3}`
  - Failure case: `2 - {1, 2, 3}` should throw an error
- **Docs**: Update `docs/reference.md` to clarify set subtraction semantics

---

## Info

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

---

## Additional Observations

### Well-Designed Patterns

1. **Empty collection guards**: Functions like `list.first`, `list.last`, `stack.peek`, `queue.peek` all correctly check for empty collections before accessing elements.

2. **Index bounds checking**: Functions like `list.at`, `list.sublist`, `str.at`, `str.substring` consistently validate indices with both negative and upper-bound checks.

3. **Division by zero protection**: Both `num.div`, `num.mod`, and their operator equivalents `/` and `%` correctly check for zero divisors.

4. **Type validation**: All native functions properly validate argument types and throw `InvalidArgumentTypesError` with helpful messages including expected vs. actual types.

5. **Recursion limit**: The `FunctionNode.maxRecursionDepth` of 1000 with proper increment/decrement in try/finally protects against stack overflow from unbounded recursion.

6. **Lazy evaluation**: The `if` function and boolean operators (`&`, `|`) correctly implement short-circuit evaluation by only evaluating branches when needed.

### Consistency Notes

- Function naming is consistent (`list.first`, `str.first`, `stack.peek`, etc.)
- All library functions follow the `NativeFunctionNode` / `NativeFunctionNodeWithArguments` pattern
- Parameter declarations match type checks in `evaluate()` methods
- Error propagation is consistent throughout the pipeline

---

## Conclusion

The codebase is well-structured with good defensive programming practices. The compiler pipeline handles edge cases appropriately, and the runtime functions consistently validate inputs. The three warnings identified are relatively minor and relate to edge case handling rather than correctness bugs.
