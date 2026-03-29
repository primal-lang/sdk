# List

## Construction

### Constructor
- **Syntax:** `[Any, Any, Any, ...]: List`
- **Output:** A list created from comma-separated elements

### Indexing
- **Syntax:** `List[Number]: Any`
- **Output:** The element at the specified index position

### Filled
- **Signature:** `list.filled(b: Number, c: Any): List`
- **Input:** A number and a value
- **Output:** A list with the value repeated the specified number of times

## Access

### At
- **Signature:** `list.at(a: List, b: Number): Any`
- **Input:** A list and an index
- **Output:** The element at the given index

### First
- **Signature:** `list.first(a: List): Any`
- **Input:** One list
- **Output:** The first element of the list

### Last
- **Signature:** `list.last(a: List): Any`
- **Input:** One list
- **Output:** The last element of the list

### Sublist
- **Signature:** `list.sublist(a: List, b: Number, c: Number): List`
- **Input:** A list, a start index, and an end index
- **Output:** A new list spanning from start to end indices

### Init
- **Signature:** `list.init(a: List): List`
- **Input:** One list
- **Output:** A new list excluding the last element

### Rest
- **Signature:** `list.rest(a: List): List`
- **Input:** One list
- **Output:** A new list excluding the first element

### Take
- **Signature:** `list.take(a: List, b: Number): List`
- **Input:** A list and a number
- **Output:** A new list containing the first n elements

### Drop
- **Signature:** `list.drop(a: List, b: Number): List`
- **Input:** A list and a number
- **Output:** A new list excluding the first n elements

## Modification

### Set
- **Signature:** `list.set(a: List, b: Number, c: Any): List`
- **Input:** A list, an index, and a value
- **Output:** A new list with the value assigned at the specified index

### Concat
- **Signature:** `list.concat(a: List, b: List): List`
- **Input:** Two lists
- **Output:** The two lists combined into a single new list

### Insert Start
- **Signature:** `list.insertStart(a: List, b: Any): List`
- **Input:** A list and a value
- **Output:** A new list with the value added at the beginning

### Insert End
- **Signature:** `list.insertEnd(a: List, b: Any): List`
- **Input:** A list and a value
- **Output:** A new list with the value added at the end

### Remove
- **Signature:** `list.remove(a: List, b: Any): List`
- **Input:** A list and a value
- **Output:** A new list with all occurrences of the value removed

### Remove At
- **Signature:** `list.removeAt(a: List, b: Number): List`
- **Input:** A list and an index
- **Output:** A new list with the element at the index removed

### Reverse
- **Signature:** `list.reverse(a: List): List`
- **Input:** One list
- **Output:** A new list with elements in reverse order

### Swap
- **Signature:** `list.swap(a: List, b: Number, c: Number): List`
- **Input:** A list and two indices
- **Output:** A new list with the elements at the given indices exchanged

### Join
- **Signature:** `list.join(a: List, b: String): String`
- **Input:** A list and a separator string
- **Output:** The list elements concatenated into a string with the separator

## Properties

### Length
- **Signature:** `list.length(a: List): Number`
- **Input:** One list
- **Output:** The count of elements in the list

### Is Empty
- **Signature:** `list.isEmpty(a: List): Boolean`
- **Input:** One list
- **Output:** True if the list contains no elements, false otherwise

### Is Not Empty
- **Signature:** `list.isNotEmpty(a: List): Boolean`
- **Input:** One list
- **Output:** True if the list contains at least one element, false otherwise

### Contains
- **Signature:** `list.contains(a: List, b: Any): Boolean`
- **Input:** A list and a value
- **Output:** True if the value exists in the list, false otherwise

### Index Of
- **Signature:** `list.indexOf(a: List, b: Any): Number`
- **Input:** A list and a value
- **Output:** The position of the first occurrence, or -1 if absent

## Higher-Order Functions

### Map
- **Signature:** `list.map(a: List, b: Function): List`
- **Input:** A list and a function
- **Output:** A new list with the function applied to each element

### Filter
- **Signature:** `list.filter(a: List, b: Function): List`
- **Input:** A list and a function
- **Output:** A new list containing only elements satisfying the condition

### Reduce
- **Signature:** `list.reduce(a: List, b: Any, c: Function): Any`
- **Input:** A list, an initial value, and a function
- **Output:** A single value accumulated by applying the function across elements

### All
- **Signature:** `list.all(a: List, b: Function): Boolean`
- **Input:** A list and a function
- **Output:** True if the condition holds for every element, false otherwise

### None
- **Signature:** `list.none(a: List, b: Function): Boolean`
- **Input:** A list and a function
- **Output:** True if the condition is false for all elements, false otherwise

### Any
- **Signature:** `list.any(a: List, b: Function): Boolean`
- **Input:** A list and a function
- **Output:** True if the condition is true for at least one element, false otherwise

### Zip
- **Signature:** `list.zip(a: List, b: List, c: Function): List`
- **Input:** Two lists and a function
- **Output:** A new list from pairing elements and applying the function to each pair

### Sort
- **Signature:** `list.sort(a: List, b: Function): List`
- **Input:** A list and a comparison function
- **Output:** A new list with elements ordered by the comparison function
