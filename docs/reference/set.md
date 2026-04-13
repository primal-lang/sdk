# Set

Number of functions: 10

## Creation

### New

- **Signature:** `set.new(a: List): Set`
- **Input:** One list
- **Output:** A set containing the elements from the list
- **Purity:** Pure
- **Example:**

```
set.new([1, 2, 3]) // returns {1, 2, 3}
```

## Modification

### Add

- **Signature:** `set.add(a: Set, b: Hashable): Set`
- **Input:** A set and a hashable value
- **Output:** A new set containing the element
- **Purity:** Pure
- **Example:**

```
set.add(set.new([1, 2]), 3) // returns {1, 2, 3}
```

### Remove

- **Signature:** `set.remove(a: Set, b: Hashable): Set`
- **Input:** A set and a hashable value
- **Output:** A new set without the element
- **Purity:** Pure
- **Example:**

```
set.remove(set.new([1, 2, 3]), 2) // returns {1, 3}
```

### Union

- **Signature:** `set.union(a: Set, b: Set): Set`
- **Input:** Two sets
- **Output:** A new set containing all elements from both sets
- **Purity:** Pure
- **Example:**

```
set.union(set.new([1, 2]), set.new([2, 3])) // returns {1, 2, 3}
```

### Intersection

- **Signature:** `set.intersection(a: Set, b: Set): Set`
- **Input:** Two sets
- **Output:** A new set containing only elements that are in both sets
- **Purity:** Pure
- **Example:**

```
set.intersection(set.new([1, 2, 3]), set.new([2, 3, 4])) // returns {2, 3}
```

### Difference

- **Signature:** `set.difference(a: Set, b: Set): Set`
- **Input:** Two sets
- **Output:** A new set containing elements from the first set that are not in the second set
- **Purity:** Pure
- **Example:**

```
set.difference(set.new([1, 2, 3]), set.new([2, 3])) // returns {1}
```

## Properties

### Contains

- **Signature:** `set.contains(a: Set, b: Hashable): Boolean`
- **Input:** A set and a hashable value
- **Output:** True if the set contains the element, false otherwise
- **Purity:** Pure
- **Example:**

```
set.contains(set.new([1, 2, 3]), 2) // returns true
```

### Is Empty

- **Signature:** `set.isEmpty(a: Set): Boolean`
- **Input:** One set
- **Output:** True if the set is empty, false otherwise
- **Purity:** Pure
- **Example:**

```
set.isEmpty(set.new([])) // returns true
```

### Is Not Empty

- **Signature:** `set.isNotEmpty(a: Set): Boolean`
- **Input:** One set
- **Output:** True if the set is not empty, false otherwise
- **Purity:** Pure
- **Example:**

```
set.isNotEmpty(set.new([1, 2])) // returns true
```

### Length

- **Signature:** `set.length(a: Set): Number`
- **Input:** One set
- **Output:** The number of elements in the set
- **Purity:** Pure
- **Example:**

```
set.length(set.new([1, 2, 3])) // returns 3
```
