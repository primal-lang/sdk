### 1. Missing Recursion Depth Tracking in `FunctionNode.apply`

**File**: `lib/compiler/runtime/node.dart`
**Line**: 273 (approx)

- **Issue**: The `FunctionNode.apply` method does not increment or decrement the recursion depth counter. Only `CustomFunctionNode.apply` implements this tracking. However, `FunctionNode.apply` is the primary entry point for all function applications, and it is called by higher-order functions like `list.map`, `list.filter`, and `list.sort`.
- **Impact**: Mutual recursion between a custom function and a higher-order library function (or another native function that calls `apply`) will bypass the recursion limit, potentially leading to a stack overflow and crashing the process.
- **Fix**:

```dart
  Node apply(List<Node> arguments) {
    if (parameters.length != arguments.length) {
      throw InvalidArgumentCountError(
        function: name,
        expected: parameters.length,
        actual: arguments.length,
      );
    }

    FunctionNode.incrementDepth();
    try {
      final Bindings bindings = Bindings.from(
        parameters: parameters,
        arguments: arguments,
      );

      return substitute(bindings).reduce();
    } finally {
      FunctionNode.decrementDepth();
    }
  }
```

_Note: The `CustomFunctionNode.apply` override should then be removed as it would be redundant._

**Follow-up**:

- **Tests**: Add a test case with a deeply recursive mutual call between a custom function and `list.map`.
  - Success case: Recursion limit is hit at 1000 and `RecursionLimitError` is thrown.
  - Failure case: Process crashes with `Stack Overflow`.
- **Docs**: No doc changes needed (behavioral fix).

## Warnings

### 1. Inefficient Evaluation in Vector Operations

**Files**: `lib/compiler/library/vector/vector_magnitude.dart`, `lib/compiler/library/vector/vector_angle.dart`, `lib/compiler/library/vector/vector_normalize.dart`

- **Issue**: These functions call `a.native()` to perform calculations. `a.native()` recursively converts the entire `VectorNode` (a list of `Node`s) into a `List<dynamic>` of native types. In `VectorNormalize`, `a.native()` is called, and then `VectorMagnitude.execute(a)` is called, which calls `a.native()` _again_.
- **Impact**: Significant performance penalty and unnecessary memory allocations on "hot paths" for vector math, especially for large vectors or in tight loops.
- **Fix**: Access `a.value` directly (which is `List<Node>`) and reduce/extract native values during the loop, or ensure `a.native()` is only called once.

**Follow-up**:

- **Tests**: Performance benchmarks for large vectors.
- **Docs**: No doc changes needed.

### 2. Error Propagation in `ListSort`

**File**: `lib/compiler/library/list/list_sort.dart`
**Line**: 40

- **Issue**: `b.apply([x, y])` is called inside the `Comparator` passed to Dart's `List.sort`.
- **Impact**: If `b.apply` throws a `RecursionLimitError` (once tracking is fixed) or any `RuntimeError`, it happens inside a synchronous callback of a Dart system method. While Dart usually propagates this, it can lead to inconsistent state if not carefully handled in the surrounding Primal runtime.
- **Fix**: Defensive check or pre-validation if possible, though propagation usually works, it's a point of fragility.

**Follow-up**:

- **Tests**: Test `list.sort` where the comparator function triggers a recursion limit.
- **Docs**: No doc changes needed.

### 3. Inconsistent Internal API Usage

**Files**: `lib/compiler/library/vector/vector_angle.dart` vs `lib/compiler/library/vector/vector_magnitude.dart`

- **Issue**: `VectorAngle` uses `a.value.length` to check size, while `VectorMagnitude` uses `a.native().length` (implicitly via loop).
- **Impact**: Maintainability issue and slight performance discrepancy.
- **Fix**: Standardize on using `a.value` for metadata (like length) to avoid unnecessary native conversions.

**Follow-up**:

- **Tests**: No new tests needed.
- **Docs**: No doc changes needed.

## Info

### 1. Missing `const` Constructors in Pipeline Classes

**Files**: `lib/compiler/syntactic/expression_parser.dart`, `lib/compiler/lexical/lexical_analyzer.dart`, `lib/compiler/semantic/semantic_analyzer.dart`, `lib/compiler/lowering/lowerer.dart`, etc.

- **Issue**: Many classes have only `final` fields and are used as stateless or near-stateless processors, but lack `const` constructors.
- **Impact**: Prevents potential optimizations and `const` allocation of these analyzer instances.
- **Fix**: Add `const` to constructors where all fields are `final`.

**Follow-up**:

- **Tests**: No new tests needed.
- **Docs**: No doc changes needed.

### 2. Redundant Parameter Mapping in `SemanticAnalyzer`

**File**: `lib/compiler/semantic/semantic_analyzer.dart`
**Line**: 32 (approx)

- **Issue**: `Parameter.any(function.parameters[i])` is called during the first pass, but the second pass already has access to the `FunctionDefinition`.
- **Impact**: Minor allocation overhead.
- **Fix**: Refactor to pass the `Parameter` list directly if available.

**Follow-up**:

- **Tests**: No new tests needed.
- **Docs**: No doc changes needed.
