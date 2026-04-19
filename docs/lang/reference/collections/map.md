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

- **Signature:** `map.at(a: Map, b: Any): Any`
- **Input:** A map and a key
- **Output:** The value associated with the key
- **Constraints:** Throws an error if the key is not found in the map
- **Purity:** Pure
- **Example:**

```
map.at({"name": "Alice"}, "name") // returns "Alice"
```

### Keys

- **Signature:** `map.keys(a: Map): List`
- **Input:** A map
- **Output:** A list containing all the keys
- **Purity:** Pure
- **Example:**

```
map.keys({"a": 1, "b": 2}) // returns ["a", "b"]
```

### Values

- **Signature:** `map.values(a: Map): List`
- **Input:** A map
- **Output:** A list containing all the values
- **Purity:** Pure
- **Example:**

```
map.values({"a": 1, "b": 2}) // returns [1, 2]
```

### Entries

- **Signature:** `map.entries(a: Map): List`
- **Input:** A map
- **Output:** A list of key-value pairs as two-element lists
- **Purity:** Pure
- **Example:**

```
map.entries({"a": 1, "b": 2}) // returns [["a", 1], ["b", 2]]
```

## Modification

### Set

- **Signature:** `map.set(a: Map, b: Any, c: Any): Map`
- **Input:** A map, a key, and a value
- **Output:** A new map containing the new key-value pair
- **Purity:** Pure
- **Example:**

```
map.set({"a": 1}, "b", 2) // returns {"a": 1, "b": 2}
```

### Merge

- **Signature:** `map.merge(a: Map, b: Map): Map`
- **Input:** Two maps
- **Output:** A new map containing all key-value pairs from both maps
- **Purity:** Pure
- **Example:**

```
map.merge({"a": 1}, {"b": 2}) // returns {"a": 1, "b": 2}
```

### Remove At

- **Signature:** `map.removeAt(a: Map, b: Any): Map`
- **Input:** A map and a key
- **Output:** A new map with the key removed
- **Purity:** Pure
- **Example:**

```
map.removeAt({"a": 1, "b": 2}, "a") // returns {"b": 2}
```

## Properties

### Contains Key

- **Signature:** `map.containsKey(a: Map, b: Any): Boolean`
- **Input:** A map and a key
- **Output:** True if the key is in the map, false otherwise
- **Purity:** Pure
- **Example:**

```
map.containsKey({"a": 1}, "a") // returns true
```

### Is Empty

- **Signature:** `map.isEmpty(a: Map): Boolean`
- **Input:** A map
- **Output:** True if the map is empty, false otherwise
- **Purity:** Pure
- **Example:**

```
map.isEmpty({}) // returns true
```

### Is Not Empty

- **Signature:** `map.isNotEmpty(a: Map): Boolean`
- **Input:** A map
- **Output:** True if the map is not empty, false otherwise
- **Purity:** Pure
- **Example:**

```
map.isNotEmpty({"a": 1}) // returns true
```

### Length

- **Signature:** `map.length(a: Map): Number`
- **Input:** A map
- **Output:** The number of key-value pairs in the map
- **Purity:** Pure
- **Example:**

```
map.length({"a": 1, "b": 2}) // returns 2
```
