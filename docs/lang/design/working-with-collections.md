---
title: Working with Collections
tags:
  - design
  - collections
sources:
  - lib/compiler/library/list/
  - lib/compiler/library/map/
  - lib/compiler/library/set/
  - lib/compiler/library/stack/
  - lib/compiler/library/queue/
  - lib/compiler/library/vector/
---

# Working with Collections

**TLDR**: Primal provides six collection types (List, Map, Set, Stack, Queue, Vector) each suited for different use cases. Master the common patterns of map, filter, and reduce to transform data efficiently using functional pipelines.

## Overview

Collections are fundamental to functional programming. Primal provides immutable collections that return new instances when modified, making your code easier to reason about and free from side effects.

## Collection Types at a Glance

| Type       | Purpose                    | Ordered | Unique      | Access Pattern |
| ---------- | -------------------------- | ------- | ----------- | -------------- |
| **List**   | General-purpose sequences  | Yes     | No          | Index-based    |
| **Map**    | Key-value associations     | No      | Keys unique | Key-based      |
| **Set**    | Unique element collections | No      | Yes         | Membership     |
| **Stack**  | LIFO (last-in-first-out)   | Yes     | No          | Top only       |
| **Queue**  | FIFO (first-in-first-out)  | Yes     | No          | Front/back     |
| **Vector** | Mathematical operations    | Yes     | No          | Index-based    |

## List

Lists are the most versatile collection type, supporting indexed access, iteration, and higher-order operations.

### Creating Lists

```
// Literal syntax
[1, 2, 3]
["apple", "banana", "cherry"]

// Create a list with repeated values
list_filled(5, 0) // returns [0, 0, 0, 0, 0]
```

### Accessing Elements

```
numbers = [10, 20, 30, 40, 50]

numbers[0]              // returns 10 (indexing)
list_at(numbers, 2)     // returns 30
list_first(numbers)     // returns 10
list_last(numbers)      // returns 50
list_sublist(numbers, 1, 4) // returns [20, 30, 40]
```

### Modifying Lists

All operations return new lists, leaving the original unchanged:

```
items = [1, 2, 3]

list_insertStart(items, 0)   // returns [0, 1, 2, 3]
list_insertEnd(items, 4)     // returns [1, 2, 3, 4]
list_set(items, 1, 99)       // returns [1, 99, 3]
list_remove(items, 2)        // returns [1, 3]
list_concat(items, [4, 5])   // returns [1, 2, 3, 4, 5]
```

### When to Use List

- Ordered sequences where position matters
- Data that needs transformation (map, filter, reduce)
- When you need indexed access
- General-purpose data storage

## Map

Maps store key-value pairs, providing fast lookup by key.

### Creating Maps

```
// Literal syntax
{"name": "Alice", "age": 30}
{1: "one", 2: "two", 3: "three"}
```

### Accessing Values

```
person = {"name": "Alice", "age": 30, "city": "Paris"}

person["name"]                 // returns "Alice"
map_at(person, "age")          // returns 30
map_keys(person)               // returns ["name", "age", "city"]
map_values(person)             // returns ["Alice", 30, "Paris"]
map_entries(person)            // returns [["name", "Alice"], ["age", 30], ["city", "Paris"]]
```

### Modifying Maps

```
config = {"debug": false, "port": 8080}

map_set(config, "host", "localhost")  // returns {"debug": false, "port": 8080, "host": "localhost"}
map_merge(config, {"debug": true})    // returns {"debug": true, "port": 8080}
map_containsKey(config, "port")       // returns true
```

### When to Use Map

- Associative data (records, configurations)
- Fast lookups by key
- When data has named fields
- JSON-like structured data

## Set

Sets store unique elements with fast membership testing and set operations.

### Creating Sets

```
// From a list (duplicates are removed)
set_new([1, 2, 2, 3, 3, 3]) // returns {1, 2, 3}
```

### Set Operations

```
a = set_new([1, 2, 3, 4])
b = set_new([3, 4, 5, 6])

set_union(a, b)        // returns {1, 2, 3, 4, 5, 6}
set_intersection(a, b) // returns {3, 4}
set_difference(a, b)   // returns {1, 2}

set_contains(a, 3)     // returns true
set_isSubset(set_new([1, 2]), a)  // returns true
```

### When to Use Set

- Eliminating duplicates
- Fast membership testing
- Mathematical set operations (union, intersection, difference)
- Tracking unique items

## Stack

Stacks follow LIFO (last-in, first-out) order, like a stack of plates.

### Stack Operations

```
s = stack_new([1, 2, 3]) // 3 is at the top

stack_peek(s)     // returns 3 (top element)
stack_push(s, 4)  // returns stack with 4 at top
stack_pop(s)      // returns stack with 3 removed
```

### When to Use Stack

- Undo/redo functionality
- Expression evaluation
- Backtracking algorithms
- Reversing sequences

## Queue

Queues follow FIFO (first-in, first-out) order, like a line of people.

### Queue Operations

```
q = queue_new([1, 2, 3]) // 1 is at the front

queue_peek(q)       // returns 1 (front element)
queue_enqueue(q, 4) // returns queue with 4 at back
queue_dequeue(q)    // returns queue with 1 removed
```

### When to Use Queue

- Task scheduling
- Breadth-first search
- Event processing
- Order preservation (process in arrival order)

## Vector

Vectors are specialized for mathematical operations with numeric data.

### Vector Operations

```
v1 = vector_new([3, 4])
v2 = vector_new([1, 2])

vector_add(v1, v2)       // returns <4, 6>
vector_sub(v1, v2)       // returns <2, 2>
vector_scale(v1, 2)      // returns <6, 8>
vector_magnitude(v1)     // returns 5
vector_normalize(v1)     // returns <0.6, 0.8>
vector_dot(v1, v2)       // returns 11
vector_distance(v1, v2)  // returns 2.828...
```

### When to Use Vector

- Physics simulations
- Graphics and game development
- Mathematical computations
- Machine learning feature vectors

## Common Patterns: Map, Filter, Reduce

The three most powerful operations for working with collections are map, filter, and reduce. These form the foundation of functional data transformation.

### Map: Transform Each Element

Apply a function to every element, producing a new list of the same length:

```
double(n) = n * 2
list_map([1, 2, 3], double) // returns [2, 4, 6]

// Extract a field from each record
names = list_map(
  [{"name": "Alice"}, {"name": "Bob"}],
  (person) => person["name"]
) // returns ["Alice", "Bob"]
```

### Filter: Select Elements

Keep only elements that satisfy a condition:

```
list_filter([1, 2, 3, 4, 5, 6], num_isEven) // returns [2, 4, 6]

// Filter by a computed condition
adults = list_filter(
  [{"name": "Alice", "age": 30}, {"name": "Bob", "age": 15}],
  (person) => person["age"] >= 18
)
```

### Reduce: Combine Elements

Accumulate all elements into a single value:

```
// Sum all numbers
list_reduce([1, 2, 3, 4], 0, num_add) // returns 10

// Find the maximum
findMax(a, b) = if (a > b) a else b
list_reduce([3, 1, 4, 1, 5], 0, findMax) // returns 5

// Build a string
list_reduce(["a", "b", "c"], "", str_concat) // returns "abc"
```

## Transformation Pipelines

Chain operations together to build powerful data transformations. In Primal, you achieve this through nested function calls or let expressions.

### Pipeline with Let Expressions

```
processOrders(orders) =
  let validOrders = list_filter(orders, (o) => o["status"] == "confirmed")
  in let totals = list_map(validOrders, (o) => o["total"])
  in let grandTotal = list_reduce(totals, 0, num_add)
  in grandTotal

// Example usage
orders = [
  {"id": 1, "status": "confirmed", "total": 100},
  {"id": 2, "status": "pending", "total": 50},
  {"id": 3, "status": "confirmed", "total": 75}
]
processOrders(orders) // returns 175
```

### Nested Function Calls

```
// Count words longer than 3 characters
countLongWords(text) =
  list_length(
    list_filter(
      str_split(text, " "),
      (word) => str_length(word) > 3
    )
  )

countLongWords("the quick brown fox") // returns 2 (quick, brown)
```

## Practical Examples

### Grouping Data

```
// Group items by a key
groupBy(items, keyFunction) =
  list_reduce(items, {}, (groups, item) =>
    let key = keyFunction(item)
    in let existing = try(map_at(groups, key), [])
    in map_set(groups, key, list_insertEnd(existing, item))
  )

// Group people by age
people = [
  {"name": "Alice", "age": 30},
  {"name": "Bob", "age": 25},
  {"name": "Charlie", "age": 30}
]
groupBy(people, (p) => p["age"])
// returns {30: [{"name": "Alice", ...}, {"name": "Charlie", ...}], 25: [...]}
```

### Finding Elements

```
// Find the first element matching a condition
findFirst(items, predicate) =
  let matches = list_filter(items, predicate)
  in if (list_isEmpty(matches)) error_throw("NOT_FOUND", "No matching element")
     else list_first(matches)

// Safe version with default
findFirstOr(items, predicate, fallback) =
  try(findFirst(items, predicate), fallback)
```

### Frequency Count

```
// Count occurrences of each item
frequency(items) =
  list_reduce(items, {}, (counts, item) =>
    let current = try(map_at(counts, item), 0)
    in map_set(counts, item, current + 1)
  )

frequency(["a", "b", "a", "c", "a", "b"])
// returns {"a": 3, "b": 2, "c": 1}
```

### Flattening Nested Data

```
// Flatten one level of nesting
list_flatten([[1, 2], [3, 4], [5]]) // returns [1, 2, 3, 4, 5]

// Extract all tags from items
getAllTags(items) =
  list_distinct(
    list_flatten(
      list_map(items, (item) => item["tags"])
    )
  )
```

### Converting Between Types

```
// List to Set (removes duplicates)
set_new([1, 2, 2, 3]) // returns {1, 2, 3}

// Map entries to List
map_entries({"a": 1, "b": 2}) // returns [["a", 1], ["b", 2]]

// List to Map (list of pairs)
pairsToMap(pairs) =
  list_reduce(pairs, {}, (result, pair) =>
    map_set(result, pair[0], pair[1])
  )
```

## Choosing the Right Collection

| Use Case                        | Best Collection |
| ------------------------------- | --------------- |
| Ordered data with duplicates    | List            |
| Key-value lookups               | Map             |
| Unique values, membership tests | Set             |
| Last-in-first-out processing    | Stack           |
| First-in-first-out processing   | Queue           |
| Mathematical/numeric operations | Vector          |
| Unknown or general purpose      | List            |

## See Also

- [[lang/reference/collections/list]] - List function reference
- [[lang/reference/collections/map]] - Map function reference
- [[lang/reference/collections/set]] - Set function reference
- [[lang/reference/collections/stack]] - Stack function reference
- [[lang/reference/collections/queue]] - Queue function reference
- [[lang/reference/collections/vector]] - Vector function reference
