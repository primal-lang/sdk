### 1. Inefficient Evaluation in Vector Operations

**Files**: `lib/compiler/library/vector/vector_magnitude.dart`, `lib/compiler/library/vector/vector_angle.dart`, `lib/compiler/library/vector/vector_normalize.dart`

- **Issue**: These functions call `a.native()` to perform calculations. `a.native()` recursively converts the entire `VectorTerm` (a list of `Term`s) into a `List<dynamic>` of native types. In `VectorNormalize`, `a.native()` is called, and then `VectorMagnitude.execute(a)` is called, which calls `a.native()` _again_.
- **Impact**: Significant performance penalty and unnecessary memory allocations on "hot paths" for vector math, especially for large vectors or in tight loops.
- **Fix**: Access `a.value` directly (which is `List<Term>`) and reduce/extract native values during the loop, or ensure `a.native()` is only called once.

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
