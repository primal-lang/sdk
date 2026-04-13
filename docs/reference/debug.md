# Debug

## Debug

- **Signature:** `debug(a: String, b: Any): Any`
- **Input:** A label string (`a`) and a value of any type (`b`)
- **Output:** The value `b`, after printing it to stdout with the label
- **Purity:** Impure

### Behavior

1. Evaluates expression `a` (must be a String)
2. Evaluates expression `b` (any type)
3. Deep-reduces `b`: recursively reduces all elements within collections
4. Prints to stdout: `[debug] <a>: <deeply-reduced b>`
5. Returns the deeply-reduced `b`

### Deep Evaluation

Evaluation is **deep**: `debug` recursively reduces `b` and all nested elements within collections before printing and returning. This ensures computed values are shown in output, and the return value contains fully evaluated elements.

- `debug("x", 1 + 2)` prints `[debug] x: 3` and returns `3`
- `debug("x", [1 + 2, 3 * 4])` prints `[debug] x: [3, 12]` and returns `[3, 12]`
- `debug("x", {"sum": 1 + 2})` prints `[debug] x: {sum: 3}` and returns `{"sum": 3}`

### Output Format

The output format is: `[debug] label: value`

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
| File      | Dart File format            | `File: '/path/to/file.txt'`     |
| Directory | Dart Directory format       | `Directory: '/path/to/dir'`     |
| Function  | `name(param: Type, ...)`    | `num.add(a: Number, b: Number)` |
| Lambda    | `<lambda@line:col>(params)` | `<lambda@1:7>(x)`               |

### Examples

**Basic usage:**

```primal
debug("result", 1 + 2)
// prints: [debug] result: 3
// returns: 3
```

**String values:**

```primal
debug("greeting", "hello world")
// prints: [debug] greeting: hello world
// returns: "hello world"
```

**Map values:**

```primal
debug("user", {"name": "Alice", "age": 30})
// prints: [debug] user: {name: Alice, age: 30}
// returns: {"name": "Alice", "age": 30}
```

**Function values:**

```primal
debug("function", num.add)
// prints: [debug] function: num.add(a: Number, b: Number)
// returns: num.add (callable)
```

**Inline in expressions:**

```primal
num.add(debug("a", 5), debug("b", 10))
// prints: [debug] a: 5
// prints: [debug] b: 10
// returns: 15
```

**Debugging intermediate values:**

```primal
process(items) = let filtered = debug("after filter", list.filter(items, (x) -> x > 0)),
                     mapped = debug("after map", list.map(filtered, (x) -> x * 2))
                 in mapped

main() = process([-1, 2, -3, 4])
// prints: [debug] after filter: [2, 4]
// prints: [debug] after map: [4, 8]
// returns: [4, 8]
```

### Error Conditions

| Condition                            | Phase    | Error                           |
| ------------------------------------ | -------- | ------------------------------- |
| Wrong argument count (direct call)   | Semantic | `InvalidNumberOfArgumentsError` |
| Wrong argument count (indirect call) | Runtime  | `InvalidArgumentCountError`     |
| `a` not String (direct call)         | Runtime  | `InvalidArgumentTypesError`     |
| `a` not String (indirect call)       | Runtime  | `InvalidArgumentTypesError`     |
| Expression `a` or `b` throws         | Runtime  | Error propagates                |

### Platform Support

Works on both CLI and web platforms.
