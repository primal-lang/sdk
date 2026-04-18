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

## Semantics

### `type.of`

- **Signature:** `type.of(a: Any): String`
- **Purity:** Pure
- **Behavior:** Reduces its argument to a value and returns the canonical runtime type name as a string. Intermediate types such as `FunctionCall` or `Any` never appear in the result because the argument is always fully reduced before inspection

Possible result strings:

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
- `Function`

### `function.name`

- **Signature:** `function.name(f: Function): String`
- **Purity:** Pure
- **Behavior:** Reduces its argument and returns the function's declared name as a string (without parentheses or parameter list). For aliased references, returns the original function name, not the alias

### `function.arity`

- **Signature:** `function.arity(f: Function): Number`
- **Purity:** Pure
- **Behavior:** Reduces its argument and returns the number of parameters accepted by the function

### `function.parameters`

- **Signature:** `function.parameters(f: Function): List`
- **Purity:** Pure
- **Behavior:** Reduces its argument and returns the function parameter names, in declaration order, as a list of strings

For user-defined functions, these are the original parameter names from the function definition.

For standard-library functions, these are the declared runtime parameter names. Most use generic names such as `"a"` and `"b"` rather than descriptive names

## Error Behavior

- Wrong arity remains an existing call-site error
- `function.name`, `function.arity`, and `function.parameters` must raise `InvalidArgumentTypesError` when their reduced argument is not a `FunctionTerm`
- `type.of` propagates any error raised while reducing its argument
- If a `FunctionReferenceTerm` fails to resolve (e.g., the referenced function does not exist), the `NotFoundInScopeError` propagates before the type check occurs

## Key Edge Cases

```primal
// Aliased function references resolve to the original name
greet(name) = str.concat("Hello, ", name)
let alias = greet in function.name(alias) // returns "greet"
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

## Examples

### Valid

```primal
type.of([1, 2, 3]) // returns "List"
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
- Each `function.*` implementation must call `reduce()` on its argument, then check `is FunctionTerm` and throw `InvalidArgumentTypesError` if the check fails
- `type.of` must call `reduce()` on its argument, then return `StringTerm(reducedValue.type.toString())`

## Post-Implementation

- Update documentation in `docs/`
- Implement tests covering:
  - `type.of` with each of the 14 listed runtime types
  - `type.of` with nested expressions that require reduction
  - `function.name`, `function.arity`, `function.parameters` with user-defined functions
  - `function.name`, `function.arity`, `function.parameters` with standard-library functions
  - Aliased function references (via `let` bindings)
  - Error cases: passing non-function values to `function.*`
  - Error propagation: invalid expressions that fail during reduction

## Implementation Complexity

Low to moderate.

The feature set is limited to additional standard-library functions and does not require new syntax, new tokens, or new intermediate representation forms. However, each implementation must:

- Follow the existing `NativeFunctionTerm` / `NativeFunctionTermWithArguments` pattern
- Correctly call `reduce()` before inspecting values
- Perform explicit runtime type checks (`is FunctionTerm`)
- Convert `List<Parameter>` to `ListTerm([StringTerm, ...])` for `function.parameters`
