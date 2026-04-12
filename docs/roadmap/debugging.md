# Feature: `debug`

## Summary

A new function `debug` that evaluates an expression, prints its value with a label to stdout, and returns the expression's value. This enables inline debugging without altering control flow.

## Signature

```
debug(a: Any, b: String): Any
```

- **Input:** A value of any type (`a`) and a label string (`b`)
- **Output:** The value, after printing it to stdout
- **Purity:** Impure

## Behavior

1. Evaluate expression `a` (any type)
2. Evaluate expression `b` (must be a String)
3. Print to stdout: `[debug] <b>: <a>\n`
4. Return the evaluated value of `a`

## Output Format

```
[debug] label: value
```

Where `value` uses the same string conversion as `console.write` (strings print without quotes, lists print as `[1, 2, 3]`, maps print as `{a: 1, b: 2}`).

## Examples

### Basic Usage

```primal
debug(1 + 2, "result")
```

Output (stdout):

```
[debug] result: 3
```

Returns: `3`

### String Values

```primal
debug("hello world", "greeting")
```

Output (stdout):

```
[debug] greeting: hello world
```

Returns: `"hello world"`

Note: Strings print without quotes in the output (matching `console.write` behavior).

### Map and Collection Values

```primal
debug({"name": "Alice", "age": 30}, "user")
```

Output (stdout):

```
[debug] user: {name: Alice, age: 30}
```

Returns: `{"name": "Alice", "age": 30}`

Note: Map keys and string values print without quotes in the output. The return value retains its original structure.

### Inline in Expressions

```primal
num.add(debug(5, "a"), debug(10, "b"))
```

Output (stdout):

```
[debug] a: 5
[debug] b: 10
```

Returns: `15`

### Recursive Function Debugging

```primal
factorial(n) = if (n <= 1)
                  debug(1, "base case")
               else
                  n * debug(factorial(n - 1), "factorial(" + to.string(n - 1) + ")")

main() = factorial(4)
```

Output (stdout):

```
[debug] base case: 1
[debug] factorial(1): 1
[debug] factorial(2): 2
[debug] factorial(3): 6
```

Returns: `24`

### Debugging Intermediate Values

```primal
process(items) = let filtered = debug(list.filter(items, (x) -> x > 0), "after filter"),
                     mapped = debug(list.map(filtered, (x) -> x * 2), "after map")
                 in mapped

main() = process([-1, 2, -3, 4])
```

Output (stdout):

```
[debug] after filter: [2, 4]
[debug] after map: [4, 8]
```

Returns: `[4, 8]`

## Error Conditions

| Condition                  | Error                                  |
| -------------------------- | -------------------------------------- |
| Wrong argument count       | `InvalidArgumentCountError`            |
| Argument `b` not String    | `InvalidArgumentTypesError`            |
| Expression `a` throws      | Error propagates (not caught by debug) |

## Invalid Examples

```primal
// Missing arguments
debug()
// Error: InvalidArgumentCountError - expected 2, got 0

// Wrong type for argument b
debug("value", 123)
// Error: InvalidArgumentTypesError - expected String for argument 'b'

// Error propagation (not caught)
debug(num.div(1, 0), "oops")
// Error: DivisionByZeroError
```

## Platform Support

Works on both CLI and web platforms (uses platform console abstraction).

## Implementation

### File Location

```
lib/compiler/library/debug/debug.dart
```

### Registration

Add to `lib/compiler/library/standard_library.dart`:

1. Import: `import 'package:primal/compiler/library/debug/debug.dart';`
2. Add `const Debug()` to the function list in `StandardLibrary.get()`

### Architecture Notes

The implementation follows the pattern established by `console.write`:

- Extend `NativeFunctionTerm` for the function definition
- Extend `NativeFunctionTermWithArguments` for the evaluation logic
- Use `PlatformInterface().console.outWrite()` for output

## Post-Implementation

- Add documentation in `docs/reference/debug.md` and link from `docs/reference.md`
- Implement tests for:
  - Correct return value
  - Output format
  - Error propagation
  - Various value types (primitives, collections, functions)
  - Recursive scenarios
