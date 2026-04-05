## Issue 1: `FunctionTerm.apply()` is effectively dead code

### Problem

`FunctionTerm` is a concrete class with an `apply()` implementation, but this implementation is never used in production:

- User-defined functions use `CustomFunctionTerm.apply()` (overrides base)
- Native functions use `NativeFunctionTerm` which delegates to base `apply()`, but the actual work happens in `NativeFunctionTermWithArguments.reduce()`

The base `FunctionTerm.apply()` has different semantics from `CustomFunctionTerm.apply()`:

| Behavior                  | `FunctionTerm.apply()` | `CustomFunctionTerm.apply()` |
| ------------------------- | ---------------------- | ---------------------------- |
| Recursion depth tracking  | No                     | Yes                          |
| Eager argument evaluation | No                     | Yes                          |

This inconsistency is confusing and error-prone. If someone extends `FunctionTerm` directly instead of `CustomFunctionTerm`, they get unexpected behavior.

### Current Code (term.dart:359-374)

```dart
Term apply(List<Term> arguments) {
  if (parameters.length != arguments.length) {
    throw InvalidArgumentCountError(
      function: name,
      expected: parameters.length,
      actual: arguments.length,
    );
  }

  final Bindings bindings = Bindings.from(
    parameters: parameters,
    arguments: arguments,
  );

  return substitute(bindings).reduce();
}
```

### Proposed Solution

Make `FunctionTerm` abstract and `apply()` abstract. This:

1. Prevents accidental instantiation of bare `FunctionTerm`
2. Forces subclasses to explicitly implement `apply()` semantics
3. Documents that `FunctionTerm` is a base class, not a usable type

### Changes Required

**File: `lib/compiler/runtime/term.dart`**

1. Change `class FunctionTerm` to `abstract class FunctionTerm`
2. Change `apply()` method signature to `Term apply(List<Term> arguments);` (abstract)
3. Remove the body of `apply()` from `FunctionTerm`

**File: `lib/compiler/runtime/term.dart` (NativeFunctionTerm)**

4. Add `apply()` override to `NativeFunctionTerm` that implements the current base behavior:

```dart
@override
Term apply(List<Term> arguments) {
  if (parameters.length != arguments.length) {
    throw InvalidArgumentCountError(
      function: name,
      expected: parameters.length,
      actual: arguments.length,
    );
  }

  final Bindings bindings = Bindings.from(
    parameters: parameters,
    arguments: arguments,
  );

  return substitute(bindings).reduce();
}
```

**Test files:**

5. Update tests that instantiate bare `FunctionTerm` to use a concrete test double or `CustomFunctionTerm`

### Files Affected

- `lib/compiler/runtime/term.dart`
- `test/runtime/core/term_test.dart`
- `test/utils/mapper_test.dart`
- `test/compiler/lowerer_expression_test.dart`

---

## Issue 2: `NativeFunctionTermWithArguments.reduce()` can be silently forgotten

### Problem

`NativeFunctionTermWithArguments` extends `FunctionTerm` and inherits the default `reduce() => this`. Native function authors must override `reduce()` in their inner class to implement the actual logic.

If an author forgets to override `reduce()`, the function silently returns itself instead of computing a result. This is a subtle bug that could go unnoticed.

### Current Code (term.dart:446-454)

```dart
class NativeFunctionTermWithArguments extends FunctionTerm {
  final List<Term> arguments;

  const NativeFunctionTermWithArguments({
    required super.name,
    required super.parameters,
    required this.arguments,
  });
  // No reduce() override - inherits `reduce() => this`
}
```

### Proposed Solution

Make `NativeFunctionTermWithArguments` abstract and declare `reduce()` as abstract. This forces every native function's inner class to implement `reduce()`.

### Changes Required

**File: `lib/compiler/runtime/term.dart`**

1. Change `class NativeFunctionTermWithArguments` to `abstract class NativeFunctionTermWithArguments`
2. Add abstract method declaration: `@override Term reduce();`

### Files Affected

- `lib/compiler/runtime/term.dart`

### Verification

All existing native functions already override `reduce()` in their inner classes, so no other changes are needed. The compiler will now catch any future omissions.

---

## Issue 3: `CallTerm.getFunctionTerm()` has redundant logic

### Problem

The `getFunctionTerm()` method manually handles cases that `reduce()` already handles:

```dart
FunctionTerm getFunctionTerm(Term callee) {
  if (callee is CallTerm) {
    return getFunctionTerm(callee.reduce());  // CallTerm.reduce() returns result
  } else if (callee is FunctionReferenceTerm) {
    return callee.reduce();  // FunctionReferenceTerm.reduce() returns FunctionTerm
  } else if (callee is FunctionTerm) {
    return callee;  // Already a FunctionTerm
  } else {
    throw InvalidFunctionError(callee.toString());
  }
}
```

All three cases can be unified: call `reduce()` on the callee, then check if it's a `FunctionTerm`.

### Proposed Solution

Simplify to:

```dart
FunctionTerm getFunctionTerm(Term callee) {
  final Term reduced = callee.reduce();
  if (reduced is FunctionTerm) {
    return reduced;
  }
  throw InvalidFunctionError(callee.toString());
}
```

### Changes Required

**File: `lib/compiler/runtime/term.dart`**

1. Replace the `getFunctionTerm()` method body with the simplified version

### Files Affected

- `lib/compiler/runtime/term.dart`

### Considerations

- `FunctionTerm.reduce()` returns `this`, so the behavior is preserved
- `FunctionReferenceTerm.reduce()` returns the resolved `FunctionTerm`
- `CallTerm.reduce()` returns the result of the call (could be a `FunctionTerm` for higher-order functions)

---

## Issue 4: `LiteralTerm` naming is misleading

### Problem

`LiteralTerm<T>` is used as a base class for both:

1. **Atomic values** (self-evaluating, no substitution needed): `BooleanTerm`, `NumberTerm`, `StringTerm`, `FileTerm`, `DirectoryTerm`, `TimestampTerm`

2. **Compound values** (require recursive substitution): `ListTerm`, `MapTerm`, `SetTerm`, `VectorTerm`, `StackTerm`, `QueueTerm`

The name "literal" traditionally means a self-evaluating atomic value. Collection terms override `substitute()` to recurse into their elements, so they're not truly "literal" in the traditional sense.

### Current Hierarchy

```
Term
├── LiteralTerm<T>
│   ├── BooleanTerm (truly literal)
│   ├── NumberTerm (truly literal)
│   ├── StringTerm (truly literal)
│   ├── FileTerm (truly literal)
│   ├── DirectoryTerm (truly literal)
│   ├── TimestampTerm (truly literal)
│   ├── ListTerm (overrides substitute)
│   ├── VectorTerm (overrides substitute)
│   ├── SetTerm (overrides substitute)
│   ├── StackTerm (overrides substitute)
│   ├── QueueTerm (overrides substitute)
│   └── MapTerm (overrides substitute)
├── FunctionReferenceTerm
├── BoundVariableTerm
├── CallTerm
└── FunctionTerm
```

### Proposed Solution

Rename `LiteralTerm` to `ValueTerm` to better reflect its role as a base for all value-carrying terms (both atomic and compound).

The name "value" is more accurate because:

- All subclasses carry a `value` field
- They represent evaluated values in the runtime
- It doesn't imply atomic/self-evaluating semantics

### Alternative Considered

Split into `AtomicValueTerm` and `CompoundValueTerm`. Rejected because:

- Adds complexity without significant benefit
- The current design works well; only the name is misleading
- Both share the same interface (`value`, `native()`)

### Changes Required

**File: `lib/compiler/runtime/term.dart`**

1. Rename `LiteralTerm<T>` to `ValueTerm<T>`
2. Rename `LiteralTerm.from()` to `ValueTerm.from()`
3. Update doc comments to reflect the new name

**File: `lib/compiler/errors/runtime_error.dart`**

4. Rename `InvalidLiteralValueError` to `InvalidValueError` (if it exists and is specific to this)

**Other files:**

5. Update any imports or references to `LiteralTerm`

### Files Affected

- `lib/compiler/runtime/term.dart`
- `lib/compiler/errors/runtime_error.dart` (if applicable)
- Any test files that reference `LiteralTerm` directly

---

## Implementation Order

Recommended order based on dependencies and risk:

1. **Issue 3** (simplify `getFunctionTerm`) - Low risk, isolated change
2. **Issue 2** (make `NativeFunctionTermWithArguments` abstract) - Low risk, no behavior change
3. **Issue 4** (rename `LiteralTerm` to `ValueTerm`) - Medium risk, touches multiple files but is a pure rename
4. **Issue 1** (make `FunctionTerm` abstract) - Higher risk, requires test updates

---

## Testing Strategy

After each change:

1. Run existing tests: `dart test`
2. Verify no regressions in integration tests
3. For Issue 1, ensure test doubles properly exercise the `apply()` contract
