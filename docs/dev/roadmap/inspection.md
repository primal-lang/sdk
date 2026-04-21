---
title: Runtime Inspection
tags:
  - roadmap
  - runtime
sources: []
---

# Runtime Inspection

**TLDR**: Standard library functions for introspecting values at runtime, including `type.of(value)` to get type names and `function.name/arity/parameters` to inspect function metadata, all without new syntax.

Add a minimal set of runtime inspection helpers that fit Primal's existing model:

- functions are first-class values
- everything remains expression-oriented
- no new syntax or keywords are required

This revision keeps the parts of the original draft that are orthogonal and already supported by the runtime model, and removes the parts that overlap with existing constructs or remain underspecified.

## Summary

This proposal adds these standard-library functions:

- `type.of(a): String`
- `function.name(f): String`
- `function.arity(f): Number`
- `function.parameters(f): List`

## Syntax

No syntax changes are required.

These are ordinary standard-library identifiers:

```primal
type.of(value)
function.name(value)
function.arity(value)
function.parameters(value)
```

Like all standard-library functions (e.g., `list.map`, `str.concat`), these names are reserved and cannot be shadowed by user-defined functions. The semantic analyzer rejects any user-defined function whose name matches a library function.

## Semantics

### `type.of`

- **Signature:** `type.of(a: Any): String`
- **Purity:** Pure
- **Behavior:** Reduces its argument to a value and returns the canonical runtime type name as a string. Intermediate types such as `FunctionCall` or `Any` never appear in the result because the argument is always fully reduced before inspection

Possible result strings (PascalCase, matching runtime type names):

- `Boolean`
- `Number`
- `String`
- `List`
- `Map`
- `Set`
- `Stack`
- `Queue`
- `Vector`
- `File`
- `Directory`
- `Timestamp`
- `Duration`
- `Function`

### `function.name`

- **Signature:** `function.name(f: Function): String`
- **Purity:** Pure
- **Behavior:** Reduces its argument and returns the function's intrinsic name as a string (without parentheses or parameter list)

Name resolution by function kind:

- **User-defined functions:** Returns the declared name (e.g., `"addNumbers"`)
- **Standard-library functions:** Returns the qualified name (e.g., `"num.add"`)
- **Lambda expressions:** Returns the synthetic location-based name (e.g., `"<lambda@1:5>"`)
- **Let bindings:** Returns the bound function's intrinsic name, not the binding name. Writing `let alias = f in function.name(alias)` returns the name of `f`, not `"alias"`

### `function.arity`

- **Signature:** `function.arity(f: Function): Number`
- **Purity:** Pure
- **Behavior:** Reduces its argument and returns the number of parameters accepted by the function

### `function.parameters`

- **Signature:** `function.parameters(f: Function): List`
- **Purity:** Pure
- **Behavior:** Reduces its argument and returns the function parameter names, in declaration order, as a list of strings. Only names are returned; type information is not included

For user-defined functions, these are the original parameter names from the function definition.

For standard-library functions, these are the declared runtime parameter names. Most use generic names such as `"a"` and `"b"` rather than descriptive names.

For lambda expressions, these are the parameter names from the lambda syntax (e.g., `(x, y) -> x + y` yields `["x", "y"]`)

## Error Behavior

- Wrong arity raises `InvalidArgumentCountError` at the call site (e.g., `type.of(1, 2)` or `function.name()`)
- `function.name`, `function.arity`, and `function.parameters` must raise `InvalidArgumentTypesError` when their reduced argument is not a `FunctionTerm`
- `type.of` does not catch errors; any error during argument evaluation propagates unchanged
- Any error during argument reduction propagates before type checking occurs. This includes:
  - `NotFoundInScopeError` for unresolved references
  - `RecursionLimitError` for expressions exceeding the recursion depth limit
  - User-thrown errors via `error.throw`
  - Other runtime errors from nested function calls
- When the argument is a `FunctionReferenceTerm` (e.g., `addNumbers` or `num.add`), `reduce()` resolves it to the underlying `FunctionTerm` before inspection. Note: `FunctionReferenceTerm` is NOT a subtype of `FunctionTerm`—it extends `Term` directly—so the type check must occur AFTER reduction, not before

## Key Edge Cases

Note: `//` comments in examples below are annotations for clarity; Primal does not have comment syntax.

```primal
// Let bindings do not create aliases; the function's intrinsic name is returned
greet(name) = str.concat("Hello, ", name)
let alias = greet in function.name(alias) // returns "greet", not "alias"
```

```primal
// Lambda expressions return synthetic location-based names
// The position reflects where the lambda appears in source code (1-indexed)
// Given this single-line file:
id() = (x) -> x
function.name(id()) // returns "<lambda@1:8>" (row 1, column 8 where "(" of lambda starts)
```

```primal
// Lambda arity reflects parameter count, not curried depth
function.arity((x) -> (y) -> x + y) // returns 1, not 2
```

```primal
// Conditional expressions are reduced before type inspection
type.of(if (ready) value else fallback) // returns the type of the selected branch only
```

```primal
// Standard-library functions have generic parameter names
function.parameters(num.add) // returns ["a", "b"]
```

```primal
// Mutual recursion works because references resolve at reduction time
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
function.name(isEven) // returns "isEven"
```

```primal
// Wrapping a function creates a new lambda with its own identity
partial() = (x) -> num.add(x, 5)
function.arity(partial()) // returns 1, not 2
function.parameters(partial()) // returns ["x"], not ["a", "b"]
```

```primal
// Closures that capture outer variables only expose their own parameters
makeAdder(n) = (x) -> x + n
addFive() = makeAdder(5)
function.parameters(addFive()) // returns ["x"], not ["x", "n"] (n is captured, not a parameter)
```

## Examples

### Valid

```primal
type.of([1, 2, 3]) // returns "List"
```

```primal
type.of(duration.fromHours(2)) // returns "Duration"
```

```primal
type.of(num.add) // returns "Function"
```

```primal
addNumbers(a, b) = a + b

function.name(addNumbers) // returns "addNumbers"
function.arity(addNumbers) // returns 2
function.parameters(addNumbers) // returns ["a", "b"]
```

### Invalid

```primal
function.name(42)
// Runtime error: Invalid argument types for function "function.name". Expected: (Function). Actual: (Number)
```

```primal
function.parameters("hello")
// Runtime error: Invalid argument types for function "function.parameters". Expected: (Function). Actual: (String)
```

## Compiler Impact

### Lexical Analysis

- No changes

### Syntactic Analysis

- No changes

### Semantic Analysis

- Add standard-library signatures with `Parameter.any` for `type.of` and `Parameter.function` for the `function.*` family
- Existing identifier resolution and arity checking remain sufficient

### Lowering

- No structural changes

### Runtime

- Add native runtime functions following the existing `NativeFunctionTerm` pattern
- Each `function.*` implementation must:
  1. Call `reduce()` on its argument FIRST
  2. THEN check `is FunctionTerm` on the reduced result (not before reducing)
  3. Throw `InvalidArgumentTypesError` if the check fails
- This ordering is critical because `FunctionReferenceTerm` (which holds function names like `addNumbers` or `num.add`) is NOT a subtype of `FunctionTerm`. Calling `reduce()` resolves the reference to the actual `FunctionTerm`
- `type.of` must call `reduce()` on its argument, then return `StringTerm(reducedValue.type.toString())`
- `function.parameters` must extract only the `name` field from each `Parameter`, discarding type information:
  ```dart
  final List<Term> names = function.parameters
      .map((Parameter p) => StringTerm(p.name))
      .toList();
  return ListTerm(names);
  ```
- Error construction should follow the existing library pattern (e.g., `list_map.dart`):
  ```dart
  throw InvalidArgumentTypesError(
    function: name,
    expected: parameterTypes,  // [FunctionType()]
    actual: [a.type],          // e.g., [NumberType()]
  );
  ```

## Post-Implementation

- Create documentation in `docs/lang/reference/core/introspection.md` (these are reflection functions, not casting functions). Add cross-reference from `docs/lang/reference/core/casting.md` since users may look there for type-related functions
- Implement tests covering:
  - `type.of` with each of the 14 listed runtime types
  - `type.of` with nested expressions that require reduction
  - `type.of` with wrong arity (e.g., `type.of(1, 2)` throws `InvalidArgumentCountError`)
  - `type.of` with error-throwing argument (e.g., `type.of(error.throw("x"))` propagates error)
  - `function.name`, `function.arity`, `function.parameters` with user-defined functions
  - `function.name`, `function.arity`, `function.parameters` with standard-library functions
  - `function.name`, `function.arity`, `function.parameters` with lambda expressions
  - Lambda introspection: synthetic names, correct arity for nested lambdas
  - Let bindings return the bound function's intrinsic name
  - Closures: `function.parameters` returns only lambda parameters, not captured variables
  - Error cases: passing non-function values to `function.*`
  - Error propagation: unresolved references, recursion limits, user-thrown errors
  - Consistency: `function.name(x)` throws iff `is.function(x)` returns false
  - FunctionReferenceTerm resolution: `function.name(num.add)` returns `"num.add"` (reference resolves before inspection)

## Implementation Complexity

Low to moderate.

The feature set is limited to additional standard-library functions and does not require new syntax, new tokens, or new intermediate representation forms. However, each implementation must:

- Follow the existing `NativeFunctionTerm` / `NativeFunctionTermWithArguments` pattern
- Correctly call `reduce()` BEFORE inspecting values (critical for `FunctionReferenceTerm` handling)
- Perform explicit runtime type checks (`is FunctionTerm`) AFTER reduction
- For `function.parameters`: extract only `parameter.name` from each `Parameter`, discarding type information, and convert to `ListTerm([StringTerm, ...])`
