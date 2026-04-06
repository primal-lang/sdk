# List

## Construction

### Constructor

- **Syntax:** `[Any, Any, Any, ...]: List`
- **Input:** Comma-separated elements
- **Output:** A list containing the elements
- **Purity:** Pure
- **Example:**

```
[1, 2, 3] // returns [1, 2, 3]
```

### Indexing

- **Syntax:** `List[Number]: Any`
- **Input:** A list and an index
- **Output:** The element at the specified index position
- **Purity:** Pure
- **Example:**

```
[10, 20, 30][1] // returns 20
```

### Filled

- **Signature:** `list.filled(a: Number, b: Any): List`
- **Input:** A number and a value
- **Output:** A list with the value repeated the specified number of times
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
list.filled(3, 0) // returns [0, 0, 0]
```

## Access

### At

- **Signature:** `list.at(a: List, b: Number): Any`
- **Input:** A list and an index
- **Output:** The element at the given index
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
list.at([10, 20, 30], 1) // returns 20
```

### First

- **Signature:** `list.first(a: List): Any`
- **Input:** One list
- **Output:** The first element of the list
- **Constraints:** Throws an error if the list is empty
- **Purity:** Pure
- **Example:**

```
list.first([10, 20, 30]) // returns 10
```

### Last

- **Signature:** `list.last(a: List): Any`
- **Input:** One list
- **Output:** The last element of the list
- **Constraints:** Throws an error if the list is empty
- **Purity:** Pure
- **Example:**

```
list.last([10, 20, 30]) // returns 30
```

### Sublist

- **Signature:** `list.sublist(a: List, b: Number, c: Number): List`
- **Input:** A list, a start index, and an end index
- **Output:** A new list spanning from start to end indices
- **Constraints:** Throws an error if the start index is negative, or if the start or end index is out of bounds
- **Purity:** Pure
- **Example:**

```
list.sublist([10, 20, 30, 40], 1, 3) // returns [20, 30]
```

### Init

- **Signature:** `list.init(a: List): List`
- **Input:** One list
- **Output:** A new list excluding the last element
- **Purity:** Pure
- **Example:**

```
list.init([1, 2, 3]) // returns [1, 2]
```

### Rest

- **Signature:** `list.rest(a: List): List`
- **Input:** One list
- **Output:** A new list excluding the first element
- **Purity:** Pure
- **Example:**

```
list.rest([1, 2, 3]) // returns [2, 3]
```

### Take

- **Signature:** `list.take(a: List, b: Number): List`
- **Input:** A list and a number
- **Output:** A new list containing the first n elements
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
list.take([1, 2, 3, 4], 2) // returns [1, 2]
```

### Drop

- **Signature:** `list.drop(a: List, b: Number): List`
- **Input:** A list and a number
- **Output:** A new list excluding the first n elements
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
list.drop([1, 2, 3, 4], 2) // returns [3, 4]
```

## Modification

### Set

- **Signature:** `list.set(a: List, b: Number, c: Any): List`
- **Input:** A list, an index, and a value
- **Output:** A new list with the value assigned at the specified index
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
list.set([1, 2, 3], 1, 99) // returns [1, 99, 3]
```

### Concat

- **Signature:** `list.concat(a: List, b: List): List`
- **Input:** Two lists
- **Output:** The two lists combined into a single new list
- **Purity:** Pure
- **Example:**

```
list.concat([1, 2], [3, 4]) // returns [1, 2, 3, 4]
```

### Insert Start

- **Signature:** `list.insertStart(a: List, b: Any): List`
- **Input:** A list and a value
- **Output:** A new list with the value added at the beginning
- **Purity:** Pure
- **Example:**

```
list.insertStart([2, 3], 1) // returns [1, 2, 3]
```

### Insert End

- **Signature:** `list.insertEnd(a: List, b: Any): List`
- **Input:** A list and a value
- **Output:** A new list with the value added at the end
- **Purity:** Pure
- **Example:**

```
list.insertEnd([1, 2], 3) // returns [1, 2, 3]
```

### Remove

- **Signature:** `list.remove(a: List, b: Any): List`
- **Input:** A list and a value
- **Output:** A new list with all occurrences of the value removed
- **Purity:** Pure
- **Example:**

```
list.remove([1, 2, 3, 2], 2) // returns [1, 3]
```

### Remove At

- **Signature:** `list.removeAt(a: List, b: Number): List`
- **Input:** A list and an index
- **Output:** A new list with the element at the index removed
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
list.removeAt([1, 2, 3], 1) // returns [1, 3]
```

### Reverse

- **Signature:** `list.reverse(a: List): List`
- **Input:** One list
- **Output:** A new list with elements in reverse order
- **Purity:** Pure
- **Example:**

```
list.reverse([1, 2, 3]) // returns [3, 2, 1]
```

### Swap

- **Signature:** `list.swap(a: List, b: Number, c: Number): List`
- **Input:** A list and two indices
- **Output:** A new list with the elements at the given indices exchanged
- **Constraints:** Throws an error if either index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
list.swap([1, 2, 3], 0, 2) // returns [3, 2, 1]
```

### Join

- **Signature:** `list.join(a: List, b: String): String`
- **Input:** A list and a separator string
- **Output:** The list elements concatenated into a string with the separator
- **Purity:** Pure
- **Example:**

```
list.join(["a", "b", "c"], ", ") // returns "a, b, c"
```

## Properties

### Length

- **Signature:** `list.length(a: List): Number`
- **Input:** One list
- **Output:** The count of elements in the list
- **Purity:** Pure
- **Example:**

```
list.length([1, 2, 3]) // returns 3
```

### Is Empty

- **Signature:** `list.isEmpty(a: List): Boolean`
- **Input:** One list
- **Output:** True if the list contains no elements, false otherwise
- **Purity:** Pure
- **Example:**

```
list.isEmpty([]) // returns true
```

### Is Not Empty

- **Signature:** `list.isNotEmpty(a: List): Boolean`
- **Input:** One list
- **Output:** True if the list contains at least one element, false otherwise
- **Purity:** Pure
- **Example:**

```
list.isNotEmpty([1, 2]) // returns true
```

### Contains

- **Signature:** `list.contains(a: List, b: Any): Boolean`
- **Input:** A list and a value
- **Output:** True if the value exists in the list, false otherwise
- **Purity:** Pure
- **Example:**

```
list.contains([1, 2, 3], 2) // returns true
```

### Index Of

- **Signature:** `list.indexOf(a: List, b: Any): Number`
- **Input:** A list and a value
- **Output:** The position of the first occurrence, or -1 if absent
- **Purity:** Pure
- **Example:**

```
list.indexOf([10, 20, 30], 20) // returns 1
```

## Higher-Order Functions

### Map

- **Signature:** `list.map(a: List, b: Function): List`
- **Input:** A list and a function
- **Output:** A new list with the function applied to each element
- **Purity:** Pure
- **Example:**

```
list.map([1, 2, 3], double) // returns [2, 4, 6]
```

### Filter

- **Signature:** `list.filter(a: List, b: Function): List`
- **Input:** A list and a function
- **Output:** A new list containing only elements satisfying the condition
- **Purity:** Pure
- **Example:**

```
list.filter([1, 2, 3, 4], isEven) // returns [2, 4]
```

### Reduce

- **Signature:** `list.reduce(a: List, b: Any, c: Function): Any`
- **Input:** A list, an initial value, and a function
- **Output:** A single value accumulated by applying the function across elements
- **Purity:** Pure
- **Example:**

```
list.reduce([1, 2, 3], 0, num.add) // returns 6
```

### All

- **Signature:** `list.all(a: List, b: Function): Boolean`
- **Input:** A list and a function
- **Output:** True if the condition holds for every element, false otherwise
- **Purity:** Pure
- **Example:**

```
list.all([2, 4, 6], num.isEven) // returns true
```

### None

- **Signature:** `list.none(a: List, b: Function): Boolean`
- **Input:** A list and a function
- **Output:** True if the condition is false for all elements, false otherwise
- **Purity:** Pure
- **Example:**

```
list.none([1, 3, 5], num.isEven) // returns true
```

### Any

- **Signature:** `list.any(a: List, b: Function): Boolean`
- **Input:** A list and a function
- **Output:** True if the condition is true for at least one element, false otherwise
- **Purity:** Pure
- **Example:**

```
list.any([1, 2, 3], num.isEven) // returns true
```

### Zip

- **Signature:** `list.zip(a: List, b: List, c: Function): List`
- **Input:** Two lists and a function
- **Output:** A new list from pairing elements and applying the function to each pair
- **Purity:** Pure
- **Example:**

```
list.zip([1, 2], [3, 4], num.add) // returns [4, 6]
```

> **Note:** When the lists have different lengths, the function is applied to pairs where both elements exist. Remaining elements from the longer list are included unmodified. For example, `list.zip([1, 2, 3], [10, 20], num.add)` returns `[11, 22, 3]`.

### Sort

- **Signature:** `list.sort(a: List, b: Function): List`
- **Input:** A list and a comparison function
- **Output:** A new list with elements ordered by the comparison function
- **Purity:** Pure
- **Example:**

```
list.sort([3, 1, 2], num.compare) // returns [1, 2, 3]
```
