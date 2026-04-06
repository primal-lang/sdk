# Environment

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
