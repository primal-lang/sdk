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

### Function Values

```primal
debug(num.add, "function")
```

Output (stdout):

```
[debug] function: num.add(a: Number, b: Number)
```

Returns: the function `num.add` (unmodified)

Lambda functions display without parameter types:

```primal
debug((x) -> x + 1, "lambda")
```

Output (stdout):

```
[debug] lambda: <lambda@1:7>(x)
```

Returns: the lambda `(x) -> x + 1` (unmodified)

Note: The return value is always the _unmodified_ first argument `a`. Named functions show parameter types in the printed output; lambdas show only parameter names. The `@1:7` indicates the source location (line:column) where the lambda was defined.

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

| Condition                               | Phase    | Error                                  |
| --------------------------------------- | -------- | -------------------------------------- |
| Wrong argument count (direct call)      | Semantic | `InvalidNumberOfArgumentsError`        |
| Wrong argument count (indirect call)    | Runtime  | `InvalidArgumentCountError`            |
| Argument `b` not String (direct call)   | Semantic | `InvalidArgumentTypesError`            |
| Argument `b` not String (indirect call) | Runtime  | `InvalidArgumentTypesError`            |
| Expression `a` throws                   | Runtime  | Error propagates (not caught by debug) |

## Invalid Examples

```primal
// Missing arguments (direct call - caught during semantic analysis)
debug()
// SemanticError: InvalidNumberOfArgumentsError - expected 2, got 0

// Wrong type for argument b (direct call - caught during semantic analysis)
debug("value", 123)
// SemanticError: InvalidArgumentTypesError - expected String for argument 'b'

// Error propagation (not caught)
debug(num.div(1, 0), "oops")
// RuntimeError: DivisionByZeroError
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
  - Error propagation (left-to-right evaluation order):
    - `debug(num.div(1, 0), "label")` throws `DivisionByZeroError`
    - `debug(num.div(1, 0), error.throw(0, "fail"))` throws `DivisionByZeroError` (first arg fails first)
    - `debug(1, error.throw(0, "fail"))` throws custom error (both args evaluated)
  - Recursive scenarios
  - Primitives: numbers, strings, booleans
  - Collections: lists, maps, sets, stacks, queues, vectors
  - Empty collections: `debug([], "empty")`, `debug({}, "empty")`
  - System types: timestamps, files, directories
  - Functions: named functions, lambdas
  - Special values: `debug(num.infinity(), "inf")`
  - Nested debug: `debug(debug(1, "inner"), "outer")`
  - Unicode in labels: `debug(1, "结果")`
  - Empty label: `debug(1, "")`
