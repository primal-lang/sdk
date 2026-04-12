# Runtime Inspection and Timing

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
- **Behavior:** Evaluates its argument exactly once, reduces it to a value, and returns the canonical runtime type name as a string

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
- **Behavior:** Returns the underlying function value's runtime name

### `function.arity`

- **Signature:** `function.arity(f: Function): Number`
- **Purity:** Pure
- **Behavior:** Returns the number of parameters accepted by the function

### `function.parameters`

- **Signature:** `function.parameters(f: Function): List`
- **Purity:** Pure
- **Behavior:** Returns the function parameter names, in declaration order, as a list of strings

For user-defined functions, these are the original parameter names.

For standard-library functions, these are the declared runtime parameter names. They may be generic names such as `"a"` and `"b"`.

## Error Behavior

- Wrong arity remains an existing call-site error
- `function.name`, `function.arity`, and `function.parameters` must raise `InvalidArgumentTypesError` when their reduced argument is not a function value
- `type.of` propagates any error raised while evaluating its argument

## Key Edge Cases

```primal
let alias = greet in function.name(alias) // returns "greet()"
```

```primal
type.of(if (ready) value else fallback) // returns the type of the selected branch only
```

```primal
function.parameters(num.add) // returns the runtime parameter names for the built-in function
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

- Add standard-library signatures only
- Existing identifier resolution and arity checking remain sufficient

### Lowering

- No structural changes

### Runtime

- Add native runtime functions only

## Post-Implementation

- Update documentation in `docs/`
- Implement tests

## Implementation Complexity

Low.

The feature set is limited to additional standard-library functions and does not require new syntax, new tokens, or new intermediate representation forms.
