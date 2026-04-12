# Feature: `debug`

## Summary

A new function `debug` that evaluates an expression, prints its value with an optional label to stderr, and returns the expression's value. This enables inline debugging without altering control flow.

## Signature

```
debug(label: String, value: Any): Any
```

- **Input:** A label string and a value of any type
- **Output:** The value, after printing it to stderr
- **Purity:** Impure

## Behavior

1. Evaluate the `label` expression (must be a String)
2. Evaluate the `value` expression (any type)
3. Print to stderr:
   - If label is non-empty: `[debug] <label>: <value>\n`
   - If label is empty: `[debug] <value>\n`
4. Return the evaluated value

## Output Format

```
[debug] label: value
```

Where `value` uses the same string conversion as `console.write`.

## Examples

### Basic Usage

```primal
debug("result", 1 + 2)
```

Output (stderr):

```
[debug] result: 3
```

Returns: `3`

### Without Label

```primal
debug("", 42)
```

Output (stderr):

```
[debug] 42
```

Returns: `42`

### Inline in Expressions

```primal
num.add(debug("a", 5), debug("b", 10))
```

Output (stderr):

```
[debug] a: 5
[debug] b: 10
```

Returns: `15`

### Recursive Function Debugging

```primal
factorial(n) = if (n <= 1)
                  debug("base case", 1)
               else
                  n * debug("factorial(" + to.string(n - 1) + ")", factorial(n - 1))

main() = factorial(4)
```

Output (stderr):

```
[debug] base case: 1
[debug] factorial(1): 1
[debug] factorial(2): 2
[debug] factorial(3): 6
```

Returns: `24`

### Debugging Intermediate Values

```primal
process(items) = let filtered = debug("after filter", list.filter(items, (x) -> x > 0)),
                     mapped = debug("after map", list.map(filtered, (x) -> x * 2))
                 in mapped

main() = process([-1, 2, -3, 4])
```

Output (stderr):

```
[debug] after filter: [2, 4]
[debug] after map: [4, 8]
```

Returns: `[4, 8]`

## Error Conditions

| Condition                 | Error                                  |
| ------------------------- | -------------------------------------- |
| Wrong argument count      | `InvalidArgumentCountError`            |
| First argument not String | `InvalidArgumentTypesError`            |
| Value expression throws   | Error propagates (not caught by debug) |

## Invalid Examples

```primal
// Missing arguments
debug()
// Error: InvalidArgumentCountError - expected 2, got 0

// Wrong label type
debug(123, "value")
// Error: InvalidArgumentTypesError - expected String for argument 'label'

// Error propagation (not caught)
debug("oops", num.div(1, 0))
// Error: DivisionByZeroError
```

## Platform Support

Works on both CLI and web platforms (uses platform console abstraction).

## Post-Implementation

- Add documentation in `docs/reference/debug.md` and link from `docs/reference.md`
- Implement tests for:
  - Correct return value
  - Output format with and without label
  - Error propagation
  - Various value types (primitives, collections, functions)
  - Recursive scenarios
