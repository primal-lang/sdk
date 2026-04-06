# Error

## Functions

### Throw

- **Signature:** `error.throw(a: Any, b: String): Error`
- **Input:** An error code and a message string
- **Output:** An error that wraps the provided code and message
- **Purity:** Impure
- **Example:**

```
error.throw(404, "not found") // throws an error with code 404 and message "not found"
```
