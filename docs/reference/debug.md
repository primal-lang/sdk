# Debug

Number of functions: 1

## Debug

- **Signature:** `debug(a: String, b: Any): Any`
- **Input:** A label string and a value of any type
- **Output:** The value, after printing it to stdout with the label in format `[debug] label: value`
- **Purity:** Impure
- **Example:**

```
debug("result", 1 + 2) // prints "[debug] result: 3" and returns 3
```
