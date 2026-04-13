# Map

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

- **Syntax:** `Map[Hashable]: Any`
- **Input:** A map and a hashable key
- **Output:** The value associated with the key
- **Purity:** Pure
- **Example:**

```
{"name": "Alice"}["name"] // returns "Alice"
```

## Access

### At

- **Signature:** `map.at(a: Map, b: Hashable): Any`
- **Input:** A map and a hashable key
- **Output:** The value associated with the key
- **Constraints:** Throws an error if the key is not found in the map
- **Purity:** Pure
- **Example:**

```
map.at({"name": "Alice"}, "name") // returns "Alice"
```

### Keys

- **Signature:** `map.keys(a: Map): List`
- **Input:** One map
- **Output:** A list containing all the keys
- **Purity:** Pure
- **Example:**

```
map.keys({"a": 1, "b": 2}) // returns ["a", "b"]
```

### Values

- **Signature:** `map.values(a: Map): List`
- **Input:** One map
- **Output:** A list containing all the values
- **Purity:** Pure
- **Example:**

```
map.values({"a": 1, "b": 2}) // returns [1, 2]
```

## Modification

### Set

- **Signature:** `map.set(a: Map, b: Hashable, c: Any): Map`
- **Input:** A map, a hashable key, and a value
- **Output:** A new map containing the new key-value pair
- **Purity:** Pure
- **Example:**

```
map.set({"a": 1}, "b", 2) // returns {"a": 1, "b": 2}
```

### Remove At

- **Signature:** `map.removeAt(a: Map, b: Number): Map`
- **Input:** A map and a number key
- **Output:** A new map with the key removed
- **Purity:** Pure
- **Example:**

```
map.removeAt({1: "a", 2: "b"}, 1) // returns {2: "b"}
```

## Properties

### Contains Key

- **Signature:** `map.containsKey(a: Map, b: Hashable): Boolean`
- **Input:** A map and a hashable key
- **Output:** True if the key is in the map, false otherwise
- **Purity:** Pure
- **Example:**

```
map.containsKey({"a": 1}, "a") // returns true
```

### Is Empty

- **Signature:** `map.isEmpty(a: Map): Boolean`
- **Input:** One map
- **Output:** True if the map is empty, false otherwise
- **Purity:** Pure
- **Example:**

```
map.isEmpty({}) // returns true
```

### Is Not Empty

- **Signature:** `map.isNotEmpty(a: Map): Boolean`
- **Input:** One map
- **Output:** True if the map is not empty, false otherwise
- **Purity:** Pure
- **Example:**

```
map.isNotEmpty({"a": 1}) // returns true
```

### Length

- **Signature:** `map.length(a: Map): Number`
- **Input:** One map
- **Output:** The number of key-value pairs in the map
- **Purity:** Pure
- **Example:**

```
map.length({"a": 1, "b": 2}) // returns 2
```
