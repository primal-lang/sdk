# Environment

Number of functions: 2

Note: Environment functions are not available on the web platform.

## Functions

### Get

- **Signature:** `env.get(a: String): String`
- **Input:** One string name
- **Output:** The value of the environment variable, or an empty string if it does not exist
- **Purity:** Impure
- **Example:**

```
env.get("HOME") // returns "/home/user"
```

### Has

- **Signature:** `env.has(a: String): Boolean`
- **Input:** One string name
- **Output:** True if the environment variable exists, false otherwise
- **Purity:** Impure
- **Example:**

```
env.has("HOME") // returns true
env.has("NONEXISTENT") // returns false
```
