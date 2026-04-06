# JSON

## Functions

### Encode

- **Signature:** `json.encode(a: Any): String`
- **Input:** A map or a list
- **Output:** A JSON string encoding of the value
- **Purity:** Pure
- **Example:**

```
json.encode({"name": "Alice", "age": 30}) // returns '{"name":"Alice","age":30}'
json.encode([1, 2, 3]) // returns '[1,2,3]'
```

### Decode

- **Signature:** `json.decode(a: String): Any`
- **Input:** One JSON string
- **Output:** A value parsed from the JSON string (map, list, number, string, or boolean)
- **Constraints:** Throws an error if the string is not valid JSON
- **Purity:** Pure
- **Example:**

```
json.decode('{"name":"Alice","age":30}') // returns {"name": "Alice", "age": 30}
json.decode('[1, 2, 3]') // returns [1, 2, 3]
```

> **Note:** JSON `null` values are not supported. When decoding, `null` values in objects are skipped (the key is omitted), and `null` values in arrays are filtered out. A top-level `null` (e.g., `json.decode("null")`) throws a runtime error.
