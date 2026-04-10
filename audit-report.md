### 2. `ValueTerm.from` does not handle QueueTerm or StackTerm

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/runtime/term.dart`
**Line**: 37-58

- **Issue**: The `ValueTerm.from` factory method handles `Set<Term>` and `List<Term>` but has no way to distinguish between `ListTerm`, `StackTerm`, `QueueTerm`, and `VectorTerm` since they all use `List<Term>` as the underlying type.

- **Impact**: This limits the usefulness of `ValueTerm.from` for certain operations. Currently only used in `json_decode.dart` which only produces `ListTerm`, so no immediate bug.

- **Fix**: Document this limitation or add a type hint parameter:
  ```dart
  static ValueTerm from(dynamic value, {String? typeHint}) {
    if (value is List<Term>) {
      return switch (typeHint) {
        'stack' => StackTerm(value),
        'queue' => QueueTerm(value),
        'vector' => VectorTerm(value),
        _ => ListTerm(value),
      };
    }
    // ... rest of method
  }
  ```

**Follow-up**:

- **Tests**: None immediately needed.
- **Docs**: Document the `ValueTerm.from` factory behavior.

---

### 3. No const constructors on several error classes

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/errors/runtime_error.dart`
**Lines**: Various

- **Issue**: Some error classes like `InvalidArgumentTypesError`, `InvalidArgumentCountError`, etc. could have `const` constructors but don't. Other similar classes in the same file do use `const`.

- **Impact**: Minor performance overhead when creating error instances. No functional impact.

- **Fix**: Add `const` to constructors where possible:
  ```dart
  const InvalidArgumentTypesError({
    required String function,
    required List<Type> expected,
    required List<Type> actual,
  }) : super(
         'Invalid argument types for function "$function". Expected: (${expected.join(', ')}). Actual: (${actual.join(', ')})',
       );
  ```
  Note: This specific example won't work because `expected.join()` is not const-evaluable. The current design is correct for these cases.

**Follow-up**:

- **Tests**: None needed.
- **Docs**: None needed.

---

### 4. `json.decode` silently filters null values from lists

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/json/json_decode.dart`
**Line**: 70-71

- **Issue**: When decoding JSON arrays, null elements are silently filtered out:

  ```dart
  ListTerm(element.where((e) => e != null).map(getValue).toList());
  ```

  This means `json.decode('[1, null, 2]')` returns `[1, 2]`, not `[1, null, 2]`.

- **Impact**: Data loss when parsing JSON with null array elements. Users may not expect this behavior.

- **Fix**: Either:
  1. Document this behavior clearly, OR
  2. Throw an error when null is encountered (consistent with top-level null handling), OR
  3. Introduce a `null` type to Primal

**Follow-up**:

- **Tests**: Add test case for JSON arrays containing null values.
- **Docs**: Document that null values in JSON are either filtered or cause errors.

---

## Notes

The codebase is generally well-structured with consistent patterns:

1. **Collection Safety**: All collection access operations (`list.first`, `list.last`, `list.at`, `stack.peek`, `stack.pop`, etc.) properly check for empty collections before access.

2. **Index Bounds**: All index-based operations (`list.at`, `list.set`, `list.removeAt`, `str.at`, `str.substring`, etc.) properly validate both negative indices and upper bounds.

3. **Division by Zero**: Both `/` and `%` operators, as well as `num.div`, `num.mod`, and `vector.normalize` check for division by zero.

4. **Numeric Edge Cases**: Functions like `num.sqrt` (negative), `num.log` (non-positive), `num.pow` (negative base with fractional exponent), and `num.integerRandom` (max < min) properly validate their inputs.

5. **Short-Circuit Evaluation**: The `&&` and `||` operators correctly implement short-circuit evaluation, evaluating the second operand only when necessary.

6. **Recursion Protection**: The recursion depth tracking with a limit of 1000 prevents stack overflow from deeply recursive user-defined functions.
