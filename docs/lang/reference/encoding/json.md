---
title: JSON
tags:
  - reference
  - encoding
sources:
  - lib/compiler/library/json/
---

# JSON

**TLDR**: Functions for encoding values to JSON strings and decoding JSON strings back to maps, lists, and primitive values.

Number of functions: 2

## Functions

### Encode

- **Signature:** `json.encode(a: Any): String`
- **Input:** A map or a list. Other types will throw an error.
- **Output:** A JSON string encoding of the value.
- **Purity:** Pure
- **Example:**

```
json.encode({"name": "Alice", "age": 30}) // returns '{"name":"Alice","age":30}'
```

### Decode

- **Signature:** `json.decode(a: String): Any`
- **Input:** A JSON string.
- **Output:** A value parsed from the JSON string (map, list, number, string, or boolean).
- **Constraints:** Throws an error if the string is not valid JSON
- **Purity:** Pure
- **Example:**

```
json.decode('{"name":"Alice","age":30}') // returns {"name": "Alice", "age": 30}
```

> **Note:** JSON `null` values are not supported. When decoding, `null` values in objects are skipped (the key is omitted), and `null` values in arrays are filtered out. A top-level `null` (e.g., `json.decode("null")`) throws a runtime error.
