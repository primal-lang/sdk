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

1. Reduce expression `a` to a value (any type)
2. Reduce expression `b` to a value (must be a String)
3. Print to stdout: `[debug] <b>: <a>\n`
4. Return the reduced value of `a`

### Evaluation Semantics

Evaluation is **deep**: `debug` recursively reduces `a` and all nested elements within collections before printing. This ensures computed values are shown, making debug output more useful.

- `debug(1 + 2, "x")` prints `[debug] x: 3`
- `debug([1 + 2, 3 * 4], "x")` prints `[debug] x: [3, 12]`
- `debug({"sum": 1 + 2}, "x")` prints `[debug] x: {sum: 3}`

Note: Deep evaluation may trigger side effects in nested expressions and will not terminate for infinite structures.

## Output Format

```
[debug] label: value
```

Where `value` uses `Term.toString()` (same as `console.write`):

| Type      | Format                      | Example                         |
| --------- | --------------------------- | ------------------------------- |
| Number    | Numeric value               | `42`, `3.14`                    |
| String    | Raw string (no quotes)      | `hello world`                   |
| Boolean   | `true` or `false`           | `true`                          |
| List      | `[elem, ...]`               | `[1, 2, 3]`                     |
| Vector    | `[elem, ...]`               | `[1, 2, 3]`                     |
| Stack     | `[elem, ...]`               | `[1, 2, 3]`                     |
| Queue     | `[elem, ...]`               | `[1, 2, 3]`                     |
| Map       | `{key: value, ...}`         | `{name: Alice, age: 30}`        |
| Set       | `{elem, ...}`               | `{1, 2, 3}`                     |
| Timestamp | Dart DateTime format        | `2024-01-15 10:30:00.000`       |
| File      | File path                   | `/path/to/file.txt`             |
| Directory | Directory path              | `/path/to/directory`            |
| Function  | `name(param: Type, ...)`    | `num.add(a: Number, b: Number)` |
| Lambda    | `<lambda@line:col>(params)` | `<lambda@1:7>(x)`               |

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

Since functions are returned unmodified, they remain callable:

```primal
debug(num.abs, "abs")(-5)
```

Output (stdout):

```
[debug] abs: num.abs(a: Number)
```

Returns: `5`

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
| Argument `b` not String (direct call)   | Runtime  | `InvalidArgumentTypesError`            |
| Argument `b` not String (indirect call) | Runtime  | `InvalidArgumentTypesError`            |
| Expression `a` throws                   | Runtime  | Error propagates (not caught by debug) |

## Invalid Examples

```primal
// Missing arguments (direct call - caught during semantic analysis)
debug()
// SemanticError: Invalid number of arguments calling function "debug": expected 2, got 0

// Wrong type for argument b (caught at runtime)
debug("value", 123)
// RuntimeError: Invalid argument types for function "debug". Expected: (String). Actual: (Number)

// Error propagation (not caught)
debug(num.div(1, 0), "oops")
// RuntimeError: Division by zero is not allowed in "num.div"
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

The implementation extends the pattern established by `console.writeLn`:

- Extend `NativeFunctionTerm` for the function definition
- Extend `NativeFunctionTermWithArguments` for the evaluation logic
- Use `PlatformInterface().console.outWriteLn()` for output (includes newline)

Key differences from `console.writeLn`:

1. **Two arguments**: Evaluate `a` first, then `b` (left-to-right order matters for error propagation)
2. **Type checking**: Verify `b` is a `StringTerm`; throw `InvalidArgumentTypesError` if not
3. **Deep reduction**: Recursively reduce `a` and all nested collection elements before printing
4. **Return value**: Return the deeply-reduced `a` term (not a string representation)
5. **Output format**: Concatenate `[debug] ` + `b.value` + `: ` + `a.toString()`

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
  - Collections with literal elements: `debug([1, 2], "list")`, `debug({"a": 1}, "map")`
  - Empty collections: `debug([], "empty")`, `debug({}, "empty")`
  - Deep evaluation (computed elements reduced):
    - `debug([1 + 2], "x")` prints `[debug] x: [3]`
    - `debug({"sum": 1 + 2}, "x")` prints `[debug] x: {sum: 3}`
    - Nested collections: `debug([[1 + 2]], "x")` prints `[debug] x: [[3]]`
  - System types with exact format expectations:
    - `debug(time.now(), "t")` prints Dart DateTime format (e.g., `[debug] t: 2024-01-15 10:30:00.000`)
    - `debug(file.fromPath("/tmp/test.txt"), "f")` prints `[debug] f: /tmp/test.txt`
    - `debug(directory.fromPath("/tmp"), "d")` prints `[debug] d: /tmp`
  - Functions remain callable after debug:
    - `debug(num.abs, "abs")(-5)` returns `5`
    - `debug((x) -> x + 1, "inc")(5)` returns `6`
    - Closures preserve captured bindings: `let y = 10 in debug((x) -> x + y, "f")(5)` returns `15`
  - Special values: `debug(num.infinity(), "inf")`
  - Nested debug: `debug(debug(1, "inner"), "outer")`
  - Unicode in labels: `debug(1, "结果")`
  - Empty label: `debug(1, "")`
