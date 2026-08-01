---
title: List
tags:
  - reference
  - data-structures
sources:
  - lib/compiler/library/list/
---

# List

**TLDR**: Functions for creating, accessing, modifying, and iterating over ordered collections of elements with support for higher-order operations like map, filter, and reduce.

Number of functions: 35

## Construction

### Constructor

- **Syntax:** `[Any, Any, Any, ...]: List`
- **Input:** A list of elements separated by comma
- **Output:** A list containing all the elements
- **Purity:** Pure
- **Example:**

```
[1, 2, 3] // returns [1, 2, 3]
```

### Indexing

- **Syntax:** `List[Number]: Any`
- **Input:** A list and a number representing the index
- **Output:** The element at the specified index in the list
- **Purity:** Pure
- **Example:**

```
[10, 20, 30][1] // returns 20
```

### Filled

- **Signature:** `list_filled(a: Number, b: Any): List`
- **Input:** A number and any value
- **Output:** A list filled with the specified value, repeated the specified number of times
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
list_filled(3, 0) // returns [0, 0, 0]
```

## Access

### At

- **Signature:** `list_at(a: List, b: Number): Any`
- **Input:** A list and a number representing the index
- **Output:** The element at the specified index in the list
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
list_at([10, 20, 30], 1) // returns 20
```

### First

- **Signature:** `list_first(a: List): Any`
- **Input:** A list
- **Output:** The first element of the list
- **Constraints:** Throws an error if the list is empty
- **Purity:** Pure
- **Example:**

```
list_first([10, 20, 30]) // returns 10
```

### Last

- **Signature:** `list_last(a: List): Any`
- **Input:** A list
- **Output:** The last element of the list
- **Constraints:** Throws an error if the list is empty
- **Purity:** Pure
- **Example:**

```
list_last([10, 20, 30]) // returns 30
```

### Sublist

- **Signature:** `list_sublist(a: List, b: Number, c: Number): List`
- **Input:** A list and two numbers representing the start and end indices
- **Output:** A new list from the start index (inclusive) to the end index (exclusive)
- **Constraints:** Throws an error if the start index is negative, or if the start or end index is out of bounds
- **Purity:** Pure
- **Example:**

```
list_sublist([10, 20, 30, 40], 1, 3) // returns [20, 30]
```

### Init

- **Signature:** `list_init(a: List): List`
- **Input:** A list
- **Output:** A new list containing all elements except the last one
- **Purity:** Pure
- **Example:**

```
list_init([1, 2, 3]) // returns [1, 2]
```

### Rest

- **Signature:** `list_rest(a: List): List`
- **Input:** A list
- **Output:** A new list containing all elements except the first one
- **Purity:** Pure
- **Example:**

```
list_rest([1, 2, 3]) // returns [2, 3]
```

### Take

- **Signature:** `list_take(a: List, b: Number): List`
- **Input:** A list and a number
- **Output:** A new list containing the first n elements of the input list, where n is the specified number
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
list_take([1, 2, 3, 4], 2) // returns [1, 2]
```

### Drop

- **Signature:** `list_drop(a: List, b: Number): List`
- **Input:** A list and a number
- **Output:** A new list containing all elements except the first n elements, where n is the specified number
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
list_drop([1, 2, 3, 4], 2) // returns [3, 4]
```

## Modification

### Set

- **Signature:** `list_set(a: List, b: Number, c: Any): List`
- **Input:** A list, a number, and any value
- **Output:** A new list with the value set at the specified index
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
list_set([1, 2, 3], 1, 99) // returns [1, 99, 3]
```

### Concat

- **Signature:** `list_concat(a: List, b: List): List`
- **Input:** Two lists
- **Output:** A new list that is the result of concatenating the two lists
- **Purity:** Pure
- **Example:**

```
list_concat([1, 2], [3, 4]) // returns [1, 2, 3, 4]
```

### Insert Start

- **Signature:** `list_insertStart(a: List, b: Any): List`
- **Input:** A list and any value
- **Output:** A new list with the value inserted at the start
- **Purity:** Pure
- **Example:**

```
list_insertStart([2, 3], 1) // returns [1, 2, 3]
```

### Insert End

- **Signature:** `list_insertEnd(a: List, b: Any): List`
- **Input:** A list and any value
- **Output:** A new list with the value inserted at the end
- **Purity:** Pure
- **Example:**

```
list_insertEnd([1, 2], 3) // returns [1, 2, 3]
```

### Remove

- **Signature:** `list_remove(a: List, b: Equatable): List`
- **Input:** A list and an equatable value
- **Output:** A new list with all the occurrences of the value removed
- **Purity:** Pure
- **Example:**

```
list_remove([1, 2, 3, 2], 2) // returns [1, 3]
```

### Remove At

- **Signature:** `list_removeAt(a: List, b: Number): List`
- **Input:** A list and a number
- **Output:** A new list with the element at the specified index removed
- **Constraints:** Throws an error if the index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
list_removeAt([1, 2, 3], 1) // returns [1, 3]
```

### Reverse

- **Signature:** `list_reverse(a: List): List`
- **Input:** A list
- **Output:** A new list with the elements in reverse order
- **Purity:** Pure
- **Example:**

```
list_reverse([1, 2, 3]) // returns [3, 2, 1]
```

### Flatten

- **Signature:** `list_flatten(a: List): List`
- **Input:** A list of lists
- **Output:** A new list with nested lists flattened into a single list
- **Purity:** Pure
- **Example:**

```
list_flatten([[1, 2], [3, 4]]) // returns [1, 2, 3, 4]
```

### Distinct

- **Signature:** `list_distinct(a: List): List`
- **Input:** A list
- **Output:** A new list with duplicate elements removed, preserving order
- **Purity:** Pure
- **Example:**

```
list_distinct([1, 2, 2, 3, 1]) // returns [1, 2, 3]
```

### Chunk

- **Signature:** `list_chunk(a: List, b: Number): List`
- **Input:** A list and a number representing the chunk size
- **Output:** A list of lists, each containing at most n elements
- **Constraints:** Throws an error if the chunk size is zero or negative
- **Purity:** Pure
- **Example:**

```
list_chunk([1, 2, 3, 4, 5], 2) // returns [[1, 2], [3, 4], [5]]
```

### Swap

- **Signature:** `list_swap(a: List, b: Number, c: Number): List`
- **Input:** A list and two numbers
- **Output:** A new list with the elements at the specified indices swapped
- **Constraints:** Throws an error if either index is negative or out of bounds
- **Purity:** Pure
- **Example:**

```
list_swap([1, 2, 3], 0, 2) // returns [3, 2, 1]
```

### Join

- **Signature:** `list_join(a: List, b: String): String`
- **Input:** A list and a string
- **Output:** A string that is the result of concatenating the list elements, separated by the specified string
- **Purity:** Pure
- **Example:**

```
list_join(["a", "b", "c"], ", ") // returns "a, b, c"
```

## Properties

### Length

- **Signature:** `list_length(a: List): Number`
- **Input:** A list
- **Output:** The number of elements in the list
- **Purity:** Pure
- **Example:**

```
list_length([1, 2, 3]) // returns 3
```

### Is Empty

- **Signature:** `list_isEmpty(a: List): Boolean`
- **Input:** A list
- **Output:** True if the list is empty. False otherwise
- **Purity:** Pure
- **Example:**

```
list_isEmpty([]) // returns true
```

### Is Not Empty

- **Signature:** `list_isNotEmpty(a: List): Boolean`
- **Input:** A list
- **Output:** True if the list is not empty. False otherwise
- **Purity:** Pure
- **Example:**

```
list_isNotEmpty([1, 2]) // returns true
```

### Contains

- **Signature:** `list_contains(a: List, b: Equatable): Boolean`
- **Input:** A list and an equatable value
- **Output:** True if the list contains the specified value. False otherwise
- **Purity:** Pure
- **Example:**

```
list_contains([1, 2, 3], 2) // returns true
```

### Index Of

- **Signature:** `list_indexOf(a: List, b: Equatable): Number`
- **Input:** A list and an equatable value
- **Output:** The index of the first occurrence of the value in the list, or -1 if the value is not found
- **Purity:** Pure
- **Example:**

```
list_indexOf([10, 20, 30], 20) // returns 1
```

## Higher-Order Functions

### Map

- **Signature:** `list_map(a: List, b: Function): List`
- **Input:** A list and a function that takes an element of the list as input and returns a new value
- **Output:** A new list with the function applied to each element of the input list
- **Purity:** Pure
- **Example:**

```
list_map([1, 2, 3], double) // returns [2, 4, 6]
```

### Filter

- **Signature:** `list_filter(a: List, b: Function): List`
- **Input:** A list and a function that takes an element of the list as input and returns a boolean
- **Output:** A new list containing only the elements of the input list for which the function returns true
- **Purity:** Pure
- **Example:**

```
list_filter([1, 2, 3, 4], isEven) // returns [2, 4]
```

### Count

- **Signature:** `list_count(a: List, b: Function): Number`
- **Input:** A list and a predicate function
- **Output:** The number of elements matching the predicate
- **Purity:** Pure
- **Example:**

```
list_count([1, 2, 3, 4], num_isEven) // returns 2
```

### Reduce

- **Signature:** `list_reduce(a: List, b: Any, c: Function): Any`
- **Input:** A list, an initial value, and a function that takes the current value and an element of the list as input and returns a new value
- **Output:** The result of applying the function to each element of the list, starting with the initial value
- **Purity:** Pure
- **Example:**

```
list_reduce([1, 2, 3], 0, num_add) // returns 6
```

### All

- **Signature:** `list_all(a: List, b: Function): Boolean`
- **Input:** A list and a function that takes an element of the list as input and returns a boolean
- **Output:** True if the function returns true for all elements of the list. False otherwise
- **Purity:** Pure
- **Example:**

```
list_all([2, 4, 6], num_isEven) // returns true
```

### None

- **Signature:** `list_none(a: List, b: Function): Boolean`
- **Input:** A list and a function that takes an element of the list as input and returns a boolean
- **Output:** True if the function returns false for all elements of the list. False otherwise
- **Purity:** Pure
- **Example:**

```
list_none([1, 3, 5], num_isEven) // returns true
```

### Any

- **Signature:** `list_any(a: List, b: Function): Boolean`
- **Input:** A list and a function that takes an element of the list as input and returns a boolean
- **Output:** True if the function returns true for at least one element of the list. False otherwise
- **Purity:** Pure
- **Example:**

```
list_any([1, 2, 3], num_isEven) // returns true
```

### Zip

- **Signature:** `list_zip(a: List, b: List, c: Function): List`
- **Input:** Two lists and a function that takes an element from each list as input and returns a new value
- **Output:** A new list with the function applied to each pair of elements from the input lists
- **Purity:** Pure
- **Example:**

```
list_zip([1, 2], [3, 4], num_add) // returns [4, 6]
```

> **Note:** When the lists have different lengths, the function is applied to pairs where both elements exist. Remaining elements from the longer list are included unmodified. For example, `list_zip([1, 2, 3], [10, 20], num_add)` returns `[11, 22, 3]`.

### Sort

- **Signature:** `list_sort(a: List, b: Function): List`
- **Input:** A list and a function that takes two elements of the list as input and compares them
- **Output:** A new list with the elements sorted according to the function
- **Purity:** Pure
- **Example:**

```
list_sort([3, 1, 2], num_compare) // returns [1, 2, 3]
```
