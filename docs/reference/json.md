# JSON

## Functions

### Encode

- **Signature:** `json.encode(a: Map): String`
- **Input:** One map
- **Output:** A JSON string encoding of the map
- **Example:**

```
json.encode({"name": "Alice", "age": 30}) // returns '{"name":"Alice","age":30}'
```

### Decode

- **Signature:** `json.decode(a: String): Map`
- **Input:** One JSON string
- **Output:** A map parsed from the JSON string
- **Example:**

```
json.decode('{"name":"Alice","age":30}') // returns {"name": "Alice", "age": 30}
```

> **Note:** JSON `null` values are not supported. When decoding, `null` values in objects are skipped (the key is omitted), and `null` values in arrays are filtered out. A top-level `null` (e.g., `json.decode("null")`) throws a runtime error.
