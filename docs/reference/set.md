# Set

## Creation

### New

- **Signature:** `set.new(a: List): Set`
- **Input:** One list
- **Output:** A set containing the elements from the list
- **Example:**

```
set.new([1, 2, 3]) // returns {1, 2, 3}
```

## Modification

### Add

- **Signature:** `set.add(a: Set, b: Any): Set`
- **Input:** A set and a value
- **Output:** A new set containing the element
- **Example:**

```
set.add(set.new([1, 2]), 3) // returns {1, 2, 3}
```

### Remove

- **Signature:** `set.remove(a: Set, b: Any): Set`
- **Input:** A set and a value
- **Output:** A new set without the element
- **Example:**

```
set.remove(set.new([1, 2, 3]), 2) // returns {1, 3}
```

### Union

- **Signature:** `set.union(a: Set, b: Set): Set`
- **Input:** Two sets
- **Output:** A new set containing all elements from both sets
- **Example:**

```
set.union(set.new([1, 2]), set.new([2, 3])) // returns {1, 2, 3}
```

### Intersection

- **Signature:** `set.intersection(a: Set, b: Set): Set`
- **Input:** Two sets
- **Output:** A new set containing only elements that are in both sets
- **Example:**

```
set.intersection(set.new([1, 2, 3]), set.new([2, 3, 4])) // returns {2, 3}
```

## Properties

### Contains

- **Signature:** `set.contains(a: Set, b: Any): Boolean`
- **Input:** A set and a value
- **Output:** True if the set contains the element, false otherwise
- **Example:**

```
set.contains(set.new([1, 2, 3]), 2) // returns true
```

### Is Empty

- **Signature:** `set.isEmpty(a: Set): Boolean`
- **Input:** One set
- **Output:** True if the set is empty, false otherwise
- **Example:**

```
set.isEmpty(set.new([])) // returns true
```

### Is Not Empty

- **Signature:** `set.isNotEmpty(a: Set): Boolean`
- **Input:** One set
- **Output:** True if the set is not empty, false otherwise
- **Example:**

```
set.isNotEmpty(set.new([1, 2])) // returns true
```

### Length

- **Signature:** `set.length(a: Set): Number`
- **Input:** One set
- **Output:** The number of elements in the set
- **Example:**

```
set.length(set.new([1, 2, 3])) // returns 3
```
