# UUID

Number of functions: 1

## Functions

### V4

- **Signature:** `uuid.v4(): String`
- **Input:** None
- **Output:** A randomly generated UUID v4 string
- **Purity:** Impure (generates random values)
- **Example:**

```
uuid.v4() // returns "550e8400-e29b-41d4-a716-446655440000" (example)
```

The generated UUID follows the RFC 4122 version 4 format:

- Format: `xxxxxxxx-xxxx-4xxx-vxxx-xxxxxxxxxxxx`
- `x` represents any hexadecimal digit (0-9, a-f)
- `4` is the version indicator (always 4 for UUID v4)
- `v` is the variant indicator (always 8, 9, a, or b)
