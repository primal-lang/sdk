---
title: Map
tags:
  - reference
  - data-structures
sources:
  - lib/compiler/library/map/
---

# Map

**TLDR**: Functions for creating and manipulating key-value pair collections with support for accessing, setting, merging, and querying entries.

Number of functions: 11

## Construction

### Constructor

- **Syntax:** `{Any: Any, ...}: Map`
- **Input:** A list of pairs separated by comma
- **Output:** A map containing all the pairs
- **Purity:** Pure
- **Example:**

```
{"name": "Alice", "age": 30} // returns {"name": "Alice", "age": 30}
```

### Indexing

- **Syntax:** `Map[Any]: Any`
- **Input:** A map and a key
- **Output:** The value associated with the key
- **Purity:** Pure
- **Example:**

```
{"name": "Alice"}["name"] // returns "Alice"
```

## Access

### At

- **Signature:** `map_at(a: Map, b: Hashable): Any`
- **Input:** A map and a hashable key
- **Output:** The value associated with the key
- **Constraints:** Throws an error if the key is not found in the map
- **Purity:** Pure
- **Example:**

```
map_at({"name": "Alice"}, "name") // returns "Alice"
```

### Keys

- **Signature:** `map_keys(a: Map): List`
- **Input:** A map
- **Output:** A list containing all the keys
- **Purity:** Pure
- **Example:**

```
map_keys({"a": 1, "b": 2}) // returns ["a", "b"]
```

### Values

- **Signature:** `map_values(a: Map): List`
- **Input:** A map
- **Output:** A list containing all the values
- **Purity:** Pure
- **Example:**

```
map_values({"a": 1, "b": 2}) // returns [1, 2]
```

### Entries

- **Signature:** `map_entries(a: Map): List`
- **Input:** A map
- **Output:** A list of key-value pairs as two-element lists
- **Purity:** Pure
- **Example:**

```
map_entries({"a": 1, "b": 2}) // returns [["a", 1], ["b", 2]]
```

## Modification

### Set

- **Signature:** `map_set(a: Map, b: Hashable, c: Any): Map`
- **Input:** A map, a hashable key, and a value
- **Output:** A new map containing the new key-value pair
- **Purity:** Pure
- **Example:**

```
map_set({"a": 1}, "b", 2) // returns {"a": 1, "b": 2}
```

### Merge

- **Signature:** `map_merge(a: Map, b: Map): Map`
- **Input:** Two maps
- **Output:** A new map containing all key-value pairs from both maps. When both maps contain the same key, the value from the second map takes precedence
- **Purity:** Pure
- **Example:**

```
map_merge({"a": 1}, {"b": 2}) // returns {"a": 1, "b": 2}
```

### Remove At

- **Signature:** `map_removeAt(a: Map, b: Hashable): Map`
- **Input:** A map and a hashable key
- **Output:** A new map with the key removed
- **Purity:** Pure
- **Example:**

```
map_removeAt({"a": 1, "b": 2}, "a") // returns {"b": 2}
```

## Properties

### Contains Key

- **Signature:** `map_containsKey(a: Map, b: Hashable): Boolean`
- **Input:** A map and a hashable key
- **Output:** True if the key is in the map, false otherwise
- **Purity:** Pure
- **Example:**

```
map_containsKey({"a": 1}, "a") // returns true
```

### Is Empty

- **Signature:** `map_isEmpty(a: Map): Boolean`
- **Input:** A map
- **Output:** True if the map is empty, false otherwise
- **Purity:** Pure
- **Example:**

```
map_isEmpty({}) // returns true
```

### Is Not Empty

- **Signature:** `map_isNotEmpty(a: Map): Boolean`
- **Input:** A map
- **Output:** True if the map is not empty, false otherwise
- **Purity:** Pure
- **Example:**

```
map_isNotEmpty({"a": 1}) // returns true
```

### Length

- **Signature:** `map_length(a: Map): Number`
- **Input:** A map
- **Output:** The number of key-value pairs in the map
- **Purity:** Pure
- **Example:**

```
map_length({"a": 1, "b": 2}) // returns 2
```
