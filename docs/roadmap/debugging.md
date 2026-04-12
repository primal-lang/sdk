# Feature: `debug`

## Summary

A new function `debug` that evaluates an expression, prints its value with a label to stdout, and returns the expression's value. This enables inline debugging without altering control flow.

## Signature

```
debug(a: String, b: Any): Any
```

- **Input:** A label string (`a`) and a value of any type (`b`)
- **Output:** The value `b`, after printing it to stdout
- **Purity:** Impure

## Behavior

1. Reduce expression `a` to a value (must be a String)
2. Reduce expression `b` to a value (any type)
3. Deep-reduce `b`: recursively reduce all elements within collections (see [Evaluation Semantics](#evaluation-semantics))
4. Print to stdout: `[debug] <a>: <deeply-reduced b>\n`
5. Return the deeply-reduced `b` (a new term with all collection elements fully evaluated)

### Evaluation Semantics

Evaluation is **deep**: `debug` recursively reduces `b` and all nested elements within collections before printing and returning. This ensures computed values are shown in output, and the return value contains fully evaluated elements.

- `debug("x", 1 + 2)` prints `[debug] x: 3` and returns `3`
- `debug("x", [1 + 2, 3 * 4])` prints `[debug] x: [3, 12]` and returns `[3, 12]`
- `debug("x", {"sum": 1 + 2})` prints `[debug] x: {sum: 3}` and returns `{"sum": 3}`

This differs from `console.write`, which does not deep-reduce collection elements. For `debug`, the return value is a **new term** with all nested computations resolved, not the original unevaluated `b` term.

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
debug("result", 1 + 2)
```

Output (stdout):

```
[debug] result: 3
```

Returns: `3`

### String Values

```primal
debug("greeting", "hello world")
```

Output (stdout):

```
[debug] greeting: hello world
```

Returns: `"hello world"`

Note: Strings print without quotes in the output (matching `console.write` behavior).

### Map and Collection Values

```primal
debug("user", {"name": "Alice", "age": 30})
```

Output (stdout):

```
[debug] user: {name: Alice, age: 30}
```

Returns: `{"name": "Alice", "age": 30}`

Note: Map keys and string values print without quotes in the output. The return value retains its original structure.

### Function Values

```primal
debug("function", num.add)
```

Output (stdout):

```
[debug] function: num.add(a: Number, b: Number)
```

Returns: the function `num.add` (unmodified)

Lambda functions display without parameter types:

```primal
debug("lambda", (x) -> x + 1)
```

Output (stdout):

```
[debug] lambda: <lambda@1:7>(x)
```

Returns: the lambda `(x) -> x + 1` (unmodified)

Note: The return value is always the _unmodified_ `b` argument. Named functions show parameter types in the printed output; lambdas show only parameter names. The `@1:7` indicates the source location (line:column) where the lambda was defined.

Since functions are returned unmodified, they remain callable:

```primal
debug("abs", num.abs)(-5)
```

Output (stdout):

```
[debug] abs: num.abs(a: Number)
```

Returns: `5`

### Inline in Expressions

```primal
num.add(debug("a", 5), debug("b", 10))
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
                  debug("base case", 1)
               else
                  n * debug("factorial(" + to.string(n - 1) + ")", factorial(n - 1))

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
process(items) = let filtered = debug("after filter", list.filter(items, (x) -> x > 0)),
                     mapped = debug("after map", list.map(filtered, (x) -> x * 2))
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

| Condition                            | Phase    | Error                                  |
| ------------------------------------ | -------- | -------------------------------------- |
| Wrong argument count (direct call)   | Semantic | `InvalidNumberOfArgumentsError`        |
| Wrong argument count (indirect call) | Runtime  | `InvalidArgumentCountError`            |
| `a` not String (direct call)         | Runtime  | `InvalidArgumentTypesError`            |
| `a` not String (indirect call)       | Runtime  | `InvalidArgumentTypesError`            |
| Expression `a` or `b` throws         | Runtime  | Error propagates (not caught by debug) |

## Invalid Examples

### Direct Calls

```primal
// Missing arguments (caught during semantic analysis)
debug()
// SemanticError: Invalid number of arguments calling function "debug": expected 2, got 0

// Wrong type for a (caught at runtime)
debug(123, "value")
// RuntimeError: Invalid argument types for function "debug". Expected: (String, Any). Actual: (Number, String)

// Error propagation (not caught)
debug("oops", num.div(1, 0))
// RuntimeError: Division by zero is not allowed in "num.div"
```

### Indirect Calls (Higher-Order Usage)

When `debug` is passed as a value and called indirectly, errors occur at runtime. The error message always uses the function name "debug":

```primal
// Passing debug as higher-order function - valid usage
let f = debug in f("label", 42)
// prints: [debug] label: 42
// returns: 42

// Wrong argument count via indirect call
let f = debug in f("only one arg")
// RuntimeError: Invalid argument count for function "debug". Expected: 2. Actual: 1

// Wrong type via indirect call
let f = debug in f(123, "value")
// RuntimeError: Invalid argument types for function "debug". Expected: (String, Any). Actual: (Number, String)
```

Note: Primal does not support partial application. `debug("label")` fails immediately with an argument count error; it does not return a partially applied function.

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
2. **Type checking**: Verify `a` is a `StringTerm`; throw `InvalidArgumentTypesError` if not
3. **Deep reduction**: Recursively reduce `b` and all nested collection elements before printing and returning
4. **Return value**: Return the deeply-reduced `b` term (not the original unreduced term)
5. **Output format**: Concatenate `[debug] ` + `a.value` + `: ` + `deeplyReduced.toString()`

#### Deep Reduction Implementation

Unlike `console.writeLn` which calls `a.reduce()` once and returns, `debug` must deeply reduce collection elements. This requires a recursive helper:

```dart
Term _deepReduce(Term term) {
  final Term reduced = term.reduce();
  return switch (reduced) {
    ListTerm() => ListTerm(reduced.value.map(_deepReduce).toList()),
    VectorTerm() => VectorTerm(reduced.value.map(_deepReduce).toList()),
    StackTerm() => StackTerm(reduced.value.map(_deepReduce).toList()),
    QueueTerm() => QueueTerm(reduced.value.map(_deepReduce).toList()),
    SetTerm() => SetTerm(reduced.value.map(_deepReduce).toSet()),
    MapTerm() => MapTerm(Map.fromEntries(
        reduced.value.entries.map((e) => MapEntry(
          _deepReduce(e.key),
          _deepReduce(e.value),
        )),
      )),
    _ => reduced,  // Primitives, functions, etc. are already fully reduced
  };
}
```

This ensures that `debug("x", [1 + 2])` prints `[debug] x: [3]` and returns `ListTerm([NumberTerm(3)])`.

## Post-Implementation

- Add documentation in `docs/reference/debug.md` and link from `docs/reference.md`
- Implement tests for:
  - Correct return value
  - Output format
  - Error propagation (left-to-right evaluation order):
    - `debug("label", num.div(1, 0))` throws `DivisionByZeroError`
    - `debug(error.throw(0, "fail"), num.div(1, 0))` throws custom error (label fails first)
    - `debug("ok", error.throw(0, "fail"))` throws custom error (value evaluated after label)
  - Recursive scenarios
  - Primitives: numbers, strings, booleans
  - Collections with literal elements: `debug("list", [1, 2])`, `debug("map", {"a": 1})`
  - Empty collections: `debug("empty", [])`, `debug("empty", {})`
  - Deep evaluation (computed elements reduced in output AND return value):
    - `debug("x", [1 + 2])` prints `[debug] x: [3]` and returns `[3]`
    - `debug("x", {"sum": 1 + 2})` prints `[debug] x: {sum: 3}` and returns `{"sum": 3}`
    - Nested collections: `debug("x", [[1 + 2]])` prints `[debug] x: [[3]]` and returns `[[3]]`
    - Return value usable: `list.first(debug("x", [1 + 2]))` returns `3` (not a CallTerm)
  - System types with exact format expectations:
    - `debug("t", time.now())` prints Dart DateTime format (e.g., `[debug] t: 2024-01-15 10:30:00.000`)
    - `debug("f", file.fromPath("/tmp/test.txt"))` prints `[debug] f: /tmp/test.txt`
    - `debug("d", directory.fromPath("/tmp"))` prints `[debug] d: /tmp`
  - Functions remain callable after debug:
    - `debug("abs", num.abs)(-5)` returns `5`
    - `debug("inc", (x) -> x + 1)(5)` returns `6`
    - Closures preserve captured bindings: `let y = 10 in debug("f", (x) -> x + y)(5)` returns `15`
  - Special values: `debug("inf", num.infinity())`
  - Nested debug: `debug("outer", debug("inner", 1))`
  - Unicode in labels: `debug("结果", 1)`
  - Empty label: `debug("", 1)`
  - Higher-order function usage:
    - `let f = debug in f("x", 1)` works correctly
    - `list.map([1, 2], (x) -> debug("item", x))` prints each item
  - Indirect call errors (error message includes "debug" as function name):
    - `let f = debug in f("only one")` throws `InvalidArgumentCountError`
    - `let f = debug in f(123, "value")` throws `InvalidArgumentTypesError`
  - No partial application: `debug("label")` throws `InvalidNumberOfArgumentsError` immediately
