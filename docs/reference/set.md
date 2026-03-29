# Set

## Creation

### New
- **Signature:** `set.new(a: List): Set`
- **Input:** One list
- **Output:** A set containing the elements from the list

## Modification

### Add
- **Signature:** `set.add(a: Set, b: Any): Set`
- **Input:** A set and a value
- **Output:** A new set containing the element

### Remove
- **Signature:** `set.remove(a: Set, b: Any): Set`
- **Input:** A set and a value
- **Output:** A new set without the element

### Union
- **Signature:** `set.union(a: Set, b: Set): Set`
- **Input:** Two sets
- **Output:** A new set containing all elements from both sets

### Intersection
- **Signature:** `set.intersection(a: Set, b: Set): Set`
- **Input:** Two sets
- **Output:** A new set containing only elements that are in both sets

## Properties

### Contains
- **Signature:** `set.contains(a: Set, b: Any): Boolean`
- **Input:** A set and a value
- **Output:** True if the set contains the element, false otherwise

### Is Empty
- **Signature:** `set.isEmpty(a: Set): Boolean`
- **Input:** One set
- **Output:** True if the set is empty, false otherwise

### Is Not Empty
- **Signature:** `set.isNotEmpty(a: Set): Boolean`
- **Input:** One set
- **Output:** True if the set is not empty, false otherwise

### Length
- **Signature:** `set.length(a: Set): Number`
- **Input:** One set
- **Output:** The number of elements in the set
