# Map

## Construction

### Constructor
- **Syntax:** `{Any: Any, ...}: Map`
- **Input:** A list of pairs separated by comma
- **Output:** A map containing all the pairs

### Indexing
- **Syntax:** `Map[Any]: Any`
- **Input:** A map and a key
- **Output:** The value associated with the key

## Access

### At
- **Signature:** `map.at(a: Map, b: Any): Any`
- **Input:** A map and a key
- **Output:** The value associated with the key

### Keys
- **Signature:** `map.keys(a: Map): List`
- **Input:** One map
- **Output:** A list containing all the keys

### Values
- **Signature:** `map.values(a: Map): List`
- **Input:** One map
- **Output:** A list containing all the values

## Modification

### Set
- **Signature:** `map.set(a: Map, b: Any, c: Any): Map`
- **Input:** A map, a key, and a value
- **Output:** A new map containing the new key-value pair

### Remove At
- **Signature:** `map.removeAt(a: Map, b: Any): Map`
- **Input:** A map and a key
- **Output:** A new map with the key removed

## Properties

### Contains Key
- **Signature:** `map.containsKey(a: Map, b: Any): Boolean`
- **Input:** A map and a key
- **Output:** True if the key is in the map, false otherwise

### Is Empty
- **Signature:** `map.isEmpty(a: Map): Boolean`
- **Input:** One map
- **Output:** True if the map is empty, false otherwise

### Is Not Empty
- **Signature:** `map.isNotEmpty(a: Map): Boolean`
- **Input:** One map
- **Output:** True if the map is not empty, false otherwise

### Length
- **Signature:** `map.length(a: Map): Number`
- **Input:** One map
- **Output:** The number of key-value pairs in the map
