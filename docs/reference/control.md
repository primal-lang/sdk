# Control

## Control Flow

### If-Else

- **Syntax:** `if (a: Boolean) b: Any else c: Any`
- **Input:** A boolean condition and two branch arguments
- **Output:** The first branch argument if the condition is true, the second branch argument otherwise
- **Purity:** Pure
- **Example:**

```
if (true) "yes" else "no" // returns "yes"
```

### Try

- **Signature:** `try(a: Any, b: Any): Any`
- **Input:** Two arguments
- **Output:** The first argument unless it produces an error, in which case the second argument
- **Purity:** Pure
- **Example:**

```
try(num.div(10, 0), 0) // returns 0
```
