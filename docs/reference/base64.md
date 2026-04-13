# Base64

Number of functions: 2

## Functions

### Encode

- **Signature:** `base64.encode(a: String): String`
- **Input:** A string to encode
- **Output:** A Base64 encoded string
- **Purity:** Pure
- **Example:**

```
base64.encode("Hello, World!") // returns "SGVsbG8sIFdvcmxkIQ=="
base64.encode("") // returns ""
```

### Decode

- **Signature:** `base64.decode(a: String): String`
- **Input:** A Base64 encoded string
- **Output:** The decoded string
- **Constraints:** Throws an error if the string is not valid Base64
- **Purity:** Pure
- **Example:**

```
base64.decode("SGVsbG8sIFdvcmxkIQ==") // returns "Hello, World!"
base64.decode("") // returns ""
```
