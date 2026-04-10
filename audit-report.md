### 2. `list.filled` with large count could cause memory exhaustion

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/list/list_filled.dart`
**Line**: 42

- **Issue**: There is no upper bound check on the count parameter. A call like `list.filled(999999999999, 1)` could cause memory exhaustion.

- **Impact**: Potential denial-of-service or crash when users (intentionally or accidentally) provide very large counts.

- **Fix**:

  ```dart
  final int count = a.value.toInt();

  if (count < 0) {
    throw NegativeIndexError(function: name, index: count);
  }

  const int maxAllowedSize = 10000000; // 10 million elements
  if (count > maxAllowedSize) {
    throw InvalidNumericOperationError(
      function: name,
      reason: 'count ($count) exceeds maximum allowed size ($maxAllowedSize)',
    );
  }

  return ListTerm(List.filled(count, b));
  ```

**Follow-up**:

- **Tests**: Add test for `list.filled` with excessively large count.
- **Docs**: Document the maximum allowed list size.

---

### 3. `try` function catches ALL exceptions including programming errors

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/control/try.dart`
**Line**: 36

- **Issue**: The `try` function uses a bare `catch (_)` which catches all exceptions, including Dart's `Error` types (like `StateError`, `RangeError`). This could mask internal programming errors in the interpreter itself.

- **Impact**: Bugs in the interpreter could be silently swallowed by user code using `try`, making debugging difficult.

- **Fix**:
  ```dart
  try {
    return a.reduce();
  } on RuntimeError {
    return b.reduce();
  } on GenericError {
    return b.reduce();
  }
  // Let other exceptions (StateError, etc.) propagate
  ```

**Follow-up**:

- **Tests**: Verify that `try` catches `RuntimeError` but lets `StateError` propagate.
- **Docs**: Document which error types are caught by `try`.

---

### 4. `FunctionSignature.hashCode` ignores parameter types

**File**: `/home/max/Repositories/personal/primal-sdk/lib/compiler/models/function_signature.dart`
**Line**: 26-27

- **Issue**: The `hashCode` only considers parameter names, not types, while `==` compares by parameter names only (which is actually consistent). However, this is a design smell since `Parameter` has a `type` field that is ignored in equality checks. This could cause issues if the type system becomes more sophisticated.

- **Impact**: Currently benign since user-defined functions use `Parameter.any` types. Could become a bug if typed parameters are added.

- **Fix**: Consider whether `FunctionSignature` equality should include parameter types for future-proofing:
  ```dart
  @override
  int get hashCode => Object.hash(name, Object.hashAll(parameters));
  ```

**Follow-up**:

- **Tests**: Add test ensuring signatures with same names but different parameter types are handled correctly.
- **Docs**: Document that function signatures are compared by name and parameter names only.

---

### 5. Inconsistent empty collection error messages

**File**: Multiple files in `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/`
**Lines**: Various

- **Issue**: The error messages for empty collection operations are inconsistent:
  - `stack.peek` and `stack.pop` use: `RuntimeError('Cannot peek from an empty stack')`
  - `queue.peek` and `queue.dequeue` use: `RuntimeError('Cannot peek from an empty queue')`
  - `list.first` and `list.last` use: `EmptyCollectionError(function: name, collectionType: 'list')`

  Some use the specialized `EmptyCollectionError`, others use raw `RuntimeError`.

- **Impact**: Inconsistent error handling behavior and error messages for users.

- **Fix**: Standardize all empty collection operations to use `EmptyCollectionError`:

  ```dart
  // In stack_peek.dart and stack_pop.dart:
  throw EmptyCollectionError(function: name, collectionType: 'stack');

  // In queue_peek.dart and queue_dequeue.dart:
  throw EmptyCollectionError(function: name, collectionType: 'queue');
  ```

**Follow-up**:

- **Tests**: Verify all empty collection operations throw `EmptyCollectionError`.
- **Docs**: None required.

---

## Info

### 1. Duplicate `TermWithArguments` class names across files

**File**: All files in `/home/max/Repositories/personal/primal-sdk/lib/compiler/library/`
**Lines**: Various

- **Issue**: Every native function implementation file defines its own `TermWithArguments` class. While this works due to Dart's library scope, it makes navigation and debugging harder. IDEs may show multiple definitions when searching.

- **Impact**: Code organization issue. No runtime impact.

- **Fix**: Consider using unique class names like `ListFirstTermWithArguments` or moving the pattern to use anonymous classes/closures.

**Follow-up**:

- **Tests**: None needed.
- **Docs**: None needed.

---

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
