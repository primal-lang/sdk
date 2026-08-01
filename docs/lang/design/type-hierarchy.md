---
title: Type Hierarchy
tags:
  - design
  - types
sources:
  - lib/compiler/models/type.dart
  - lib/compiler/library/casting/
---

# Type Hierarchy

**TLDR**: Primal has 14 built-in types organized into three categories: primitives (Boolean, Number, String), collections (List, Map, Set, Stack, Queue, Vector), and system types (File, Directory, Timestamp, Duration, Function).

## Overview

Every value in Primal has exactly one type. The type system is flat with no inheritance hierarchy, meaning types do not have subtypes or parent types. Values can be converted between types using `to_*` functions and checked using `is_*` functions.

## Primitive Types

Primitives are the basic building blocks for representing simple values.

### Boolean

Represents logical truth values.

```
true   // Boolean true
false  // Boolean false

!true           // returns false
true && false   // returns false
true || false   // returns true
```

### Number

Represents both integers and floating-point numbers. There is no separate integer type; all numbers are treated uniformly.

```
42       // integer
3.14     // decimal
-17      // negative
1.5e10   // scientific notation

num_add(1, 2)       // returns 3
num_mul(3.5, 2)     // returns 7
num_isEven(4)       // returns true
is_integer(3.0)     // returns true
```

### String

Represents sequences of characters.

```
"hello"              // simple string
"line1\nline2"       // with escape sequence
""                   // empty string

str_length("hello")       // returns 5
str_concat("a", "b")      // returns "ab"
str_split("a,b,c", ",")   // returns ["a", "b", "c"]
```

## Collection Types

Collections hold multiple values and provide different access patterns.

### List

An ordered, indexable sequence of elements. Lists are the most commonly used collection type.

```
[1, 2, 3]              // list of numbers
["a", "b", "c"]        // list of strings
[1, "mixed", true]     // mixed types allowed
[]                     // empty list

list_at([10, 20, 30], 1)     // returns 20
list_length([1, 2, 3])       // returns 3
list_map([1, 2, 3], double)  // returns [2, 4, 6]
```

### Map

A collection of key-value pairs with unique keys. Keys must be hashable: numbers, strings, booleans, timestamps or durations.

```
{"name": "Alice", "age": 30}   // map literal
{}                              // empty map

map_at({"a": 1}, "a")           // returns 1
map_set({"a": 1}, "b", 2)       // returns {"a": 1, "b": 2}
map_keys({"x": 1, "y": 2})      // returns ["x", "y"]
```

### Set

An unordered collection of unique elements.

```
set_new([1, 2, 3])              // create from list
set_new([1, 1, 2, 2, 3])        // duplicates removed: {1, 2, 3}

set_contains(set_new([1, 2]), 1)    // returns true
set_add(set_new([1, 2]), 3)         // returns {1, 2, 3}
set_union(set_new([1, 2]), set_new([2, 3]))  // returns {1, 2, 3}
```

### Stack

A last-in, first-out (LIFO) collection.

```
stack_new([1, 2, 3])           // create stack

stack_push(stack_new([1, 2]), 3)   // returns stack with 3 on top
stack_peek(stack_new([1, 2, 3]))   // returns 3 (top element)
stack_pop(stack_new([1, 2, 3]))    // returns stack with top removed
```

### Queue

A first-in, first-out (FIFO) collection.

```
queue_new([1, 2, 3])           // create queue

queue_enqueue(queue_new([1, 2]), 3)  // adds 3 to back
queue_peek(queue_new([1, 2, 3]))     // returns 1 (front element)
queue_dequeue(queue_new([1, 2, 3]))  // removes front element
```

### Vector

A fixed-size, indexed collection optimized for mathematical operations.

```
vector_new([1.0, 2.0, 3.0])    // create vector

vector_magnitude(vector_new([3, 4]))  // returns 5
vector_dot(vector_new([1, 2]), vector_new([3, 4]))  // returns 11
```

## System Types

System types represent external resources and runtime constructs.

### File

Represents a file on the filesystem.

```
file_fromPath("data.txt")           // create file reference
file_read(file_fromPath("data.txt")) // read file contents
file_exists(file_fromPath("data.txt")) // check if file exists
```

### Directory

Represents a directory on the filesystem.

```
directory_fromPath("/home/user")        // create directory reference
directory_list(directory_fromPath(".")) // list directory contents
```

### Timestamp

Represents a point in time.

```
time_now()                   // current timestamp
time_year(time_now())        // extract year
time_format(time_now(), "yyyy-MM-dd")  // format as string
```

### Duration

Represents a span of time.

```
duration_fromSeconds(30)     // 30 seconds
duration_fromHours(2)        // 2 hours
duration_from(1, 2, 30, 0, 0)  // 1 day, 2 hours, 30 minutes

duration_toMinutes(duration_fromSeconds(90))  // returns 1.5
duration_format(duration_fromHours(2), "HH:mm:ss")  // "02:00:00"
```

### Function

Functions are first-class values and can be passed as arguments or stored in variables.

```
double(x) = x * 2
list_map([1, 2, 3], double)  // pass function as argument

// Core functions are also values
list_map([1, 2, 3], num_abs)  // use core function directly
```

## Type Checking

Use `is_*` functions to check a value's type at runtime:

```
is_boolean(true)       // returns true
is_number(42)          // returns true
is_string("hello")     // returns true
is_list([1, 2, 3])     // returns true
is_map({"a": 1})       // returns true
is_set(set_new([1]))   // returns true
is_stack(stack_new([]))    // returns true
is_queue(queue_new([]))    // returns true
is_vector(vector_new([]))  // returns true
is_file(file_fromPath("x"))       // returns true
is_directory(directory_fromPath("."))  // returns true
is_timestamp(time_now())   // returns true
is_duration(duration_fromSeconds(1))  // returns true
is_function(num_add)       // returns true
```

Additional checks for number subtypes:

```
is_integer(3)      // returns true
is_integer(3.5)    // returns false
is_decimal(3.5)    // returns true
is_infinite(num_infinity())  // returns true
```

## Type Conversions

Use `to_*` functions to convert between types:

### To Primitives

```
to_number("42")        // returns 42
to_number(true)        // returns 1
to_integer(3.7)        // returns 3 (truncates)
to_decimal("3.14")     // returns 3.14

to_string(42)          // returns "42"
to_string(true)        // returns "true"
to_string([1, 2, 3])   // returns "[1, 2, 3]"

to_boolean(1)          // returns true
to_boolean(0)          // returns false
to_boolean("true")     // returns true
```

### Between Collections

```
to_list(set_new([1, 2, 3]))    // set to list
to_list(stack_new([1, 2, 3]))  // stack to list
to_list(queue_new([1, 2, 3]))  // queue to list
to_list(vector_new([1, 2, 3])) // vector to list
```

## Practical Examples

### Generic Processing

Write functions that work with any type:

```
describe(value) =
  if (is_number(value))
    "a number"
  else if (is_string(value))
    "a string"
  else if (is_list(value))
    str_concat("a list with ", to_string(list_length(value)), " elements")
  else
    "something else"
```

### Collection Conversion Pipeline

Convert between collection types as needed:

```
// Remove duplicates from a list using set
removeDuplicates(items) = to_list(set_new(items))

// Process items: [1, 2, 2, 3, 1] becomes [1, 2, 3]
```

### Safe Type Coercion

Convert with fallback for invalid input:

```
safeToNumber(value) =
  if (is_number(value))
    value
  else if (is_string(value))
    try(to_number(value), 0)
  else
    0
```

For more on how types are checked at runtime, see [[lang/design/dynamic-typing]].
