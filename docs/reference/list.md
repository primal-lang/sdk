# List

## Constructor

`[Any, Any, Any, ...]: List`

Creates a list from comma-separated elements.

## Indexing

`List[Number]: Any`

Returns the element at the specified index position.

## list.at

`list.at(a: List, b: Number): Any`

Retrieves the element at the given index.

## list.sublist

`list.sublist(a: List, b: Number, c: Number): List`

Returns a new list spanning from start to end indices.

## list.set

`list.set(a: List, b: Number, c: Any): List`

Creates a new list with a value assigned at the specified index.

## list.join

`list.join(a: List, b: String): String`

Concatenates list elements into a string with a separator.

## list.length

`list.length(a: List): Number`

Returns the count of elements in the list.

## list.concat

`list.concat(a: List, b: List): List`

Combines two lists into a single new list.

## list.isEmpty

`list.isEmpty(a: List): Boolean`

Returns true if the list contains no elements.

## list.isNotEmpty

`list.isNotEmpty(a: List): Boolean`

Returns true if the list contains at least one element.

## list.contains

`list.contains(a: List, b: Any): Boolean`

Returns true if a value exists in the list.

## list.first

`list.first(a: List): Any`

Returns the first element of the list.

## list.last

`list.last(a: List): Any`

Returns the last element of the list.

## list.init

`list.init(a: List): List`

Returns a new list excluding the last element.

## list.rest

`list.rest(a: List): List`

Returns a new list excluding the first element.

## list.take

`list.take(a: List, b: Number): List`

Returns a new list containing the first n elements.

## list.drop

`list.drop(a: List, b: Number): List`

Returns a new list excluding the first n elements.

## list.insertStart

`list.insertStart(a: List, b: Any): List`

Returns a new list with a value added at the beginning.

## list.insertEnd

`list.insertEnd(a: List, b: Any): List`

Returns a new list with a value added at the end.

## list.remove

`list.remove(a: List, b: Any): List`

Returns a new list with all occurrences of a value removed.

## list.removeAt

`list.removeAt(a: List, b: Number): List`

Returns a new list with the element at the index removed.

## list.reverse

`list.reverse(a: List): List`

Returns a new list with elements in reverse order.

## list.filled

`list.filled(b: Number, c: Any): List`

Creates a list with a value repeated a specified number of times.

## list.indexOf

`list.indexOf(a: List, b: Any): Number`

Returns the position of the first occurrence or -1 if absent.

## list.swap

`list.swap(a: List, b: Number, c: Number): List`

Returns a new list with two elements at given indices exchanged.

## list.map

`list.map(a: List, b: Function): List`

Applies a function to each element, returning a transformed list.

## list.filter

`list.filter(a: List, b: Function): List`

Returns a new list containing only elements satisfying a condition.

## list.reduce

`list.reduce(a: List, b: Any, c: Function): Any`

Accumulates a single value by applying a function across elements.

## list.all

`list.all(a: List, b: Function): Boolean`

Returns true if a condition holds for every element.

## list.none

`list.none(a: List, b: Function): Boolean`

Returns true if a condition is false for all elements.

## list.any

`list.any(a: List, b: Function): Boolean`

Returns true if a condition is true for at least one element.

## list.zip

`list.zip(a: List, b: List, c: Function): List`

Pairs elements from two lists and applies a function to each pair.

## list.sort

`list.sort(a: List, b: Function): List`

Returns a new list with elements ordered by a comparison function.
