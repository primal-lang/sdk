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

**TLDR**: Primal has 13 built-in types organized into three categories: primitives (Boolean, Number, String), collections (List, Map, Set, Stack, Queue, Vector), and system types (File, Directory, Timestamp, Function).

## Overview

Every value in Primal has exactly one type. The type system is flat with no inheritance hierarchy, meaning types do not have subtypes or parent types. Values can be converted between types using `to.*` functions and checked using `is.*` functions.

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

num.add(1, 2)       // returns 3
num.mul(3.5, 2)     // returns 7
num.isEven(4)       // returns true
num.isInteger(3.0)  // returns true
```

### String

Represents sequences of characters.

```
"hello"              // simple string
"line1\nline2"       // with escape sequence
""                   // empty string

str.length("hello")       // returns 5
str.concat("a", "b")      // returns "ab"
str.split("a,b,c", ",")   // returns ["a", "b", "c"]
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

list.at([10, 20, 30], 1)     // returns 20
list.length([1, 2, 3])       // returns 3
list.map([1, 2, 3], double)  // returns [2, 4, 6]
```

### Map

A collection of key-value pairs with unique keys. Keys must be strings.

```
{"name": "Alice", "age": 30}   // map literal
{}                              // empty map

map.get({"a": 1}, "a")          // returns 1
map.set({"a": 1}, "b", 2)       // returns {"a": 1, "b": 2}
map.keys({"x": 1, "y": 2})      // returns ["x", "y"]
```

### Set

An unordered collection of unique elements.

```
set.new([1, 2, 3])              // create from list
set.new([1, 1, 2, 2, 3])        // duplicates removed: {1, 2, 3}

set.contains(set.new([1, 2]), 1)    // returns true
set.add(set.new([1, 2]), 3)         // returns {1, 2, 3}
set.union(set.new([1, 2]), set.new([2, 3]))  // returns {1, 2, 3}
```

### Stack

A last-in, first-out (LIFO) collection.

```
stack.new([1, 2, 3])           // create stack

stack.push(stack.new([1, 2]), 3)   // returns stack with 3 on top
stack.peek(stack.new([1, 2, 3]))   // returns 3 (top element)
stack.pop(stack.new([1, 2, 3]))    // returns stack with top removed
```

### Queue

A first-in, first-out (FIFO) collection.

```
queue.new([1, 2, 3])           // create queue

queue.enqueue(queue.new([1, 2]), 3)  // adds 3 to back
queue.peek(queue.new([1, 2, 3]))     // returns 1 (front element)
queue.dequeue(queue.new([1, 2, 3]))  // removes front element
```

### Vector

A fixed-size, indexed collection optimized for mathematical operations.

```
vector.new([1.0, 2.0, 3.0])    // create vector

vector.at(vector.new([1, 2, 3]), 0)   // returns 1
vector.length(vector.new([1, 2, 3]))  // returns 3
```

## System Types

System types represent external resources and runtime constructs.

### File

Represents a file on the filesystem.

```
file.fromPath("data.txt")           // create file reference
file.read(file.fromPath("data.txt")) // read file contents
file.exists(file.fromPath("data.txt")) // check if file exists
```

### Directory

Represents a directory on the filesystem.

```
directory.fromPath("/home/user")        // create directory reference
directory.list(directory.fromPath(".")) // list directory contents
```

### Timestamp

Represents a point in time.

```
time.now()                   // current timestamp
time.year(time.now())        // extract year
time.format(time.now(), "yyyy-MM-dd")  // format as string
```

### Function

Functions are first-class values and can be passed as arguments or stored in variables.

```
double(x) = x * 2
list.map([1, 2, 3], double)  // pass function as argument

// Core functions are also values
list.map([1, 2, 3], num.abs)  // use core function directly
```

## Type Checking

Use `is.*` functions to check a value's type at runtime:

```
is.boolean(true)       // returns true
is.number(42)          // returns true
is.string("hello")     // returns true
is.list([1, 2, 3])     // returns true
is.map({"a": 1})       // returns true
is.set(set.new([1]))   // returns true
is.stack(stack.new([]))    // returns true
is.queue(queue.new([]))    // returns true
is.vector(vector.new([]))  // returns true
is.file(file.fromPath("x"))       // returns true
is.directory(directory.fromPath("."))  // returns true
is.timestamp(time.now())   // returns true
is.function(num.add)       // returns true
```

Additional checks for number subtypes:

```
is.integer(3)      // returns true
is.integer(3.5)    // returns false
is.decimal(3.5)    // returns true
is.infinite(num.infinity())  // returns true
```

## Type Conversions

Use `to.*` functions to convert between types:

### To Primitives

```
to.number("42")        // returns 42
to.number(true)        // returns 1
to.integer(3.7)        // returns 3 (truncates)
to.decimal("3.14")     // returns 3.14

to.string(42)          // returns "42"
to.string(true)        // returns "true"
to.string([1, 2, 3])   // returns "[1, 2, 3]"

to.boolean(1)          // returns true
to.boolean(0)          // returns false
to.boolean("true")     // returns true
```

### Between Collections

```
to.list(set.new([1, 2, 3]))    // set to list
to.list(stack.new([1, 2, 3]))  // stack to list
to.list(queue.new([1, 2, 3]))  // queue to list
to.list(vector.new([1, 2, 3])) // vector to list
```

## Practical Examples

### Generic Processing

Write functions that work with any type:

```
describe(value) =
  if (is.number(value))
    "a number"
  else if (is.string(value))
    "a string"
  else if (is.list(value))
    str.concat("a list with ", to.string(list.length(value)), " elements")
  else
    "something else"
```

### Collection Conversion Pipeline

Convert between collection types as needed:

```
// Remove duplicates from a list using set
removeDuplicates(items) = to.list(set.new(items))

// Process items: [1, 2, 2, 3, 1] becomes [1, 2, 3]
```

### Safe Type Coercion

Convert with fallback for invalid input:

```
safeToNumber(value) =
  if (is.number(value))
    value
  else if (is.string(value))
    try(to.number(value), 0)
  else
    0
```

For more on how types are checked at runtime, see [[lang/design/dynamic-typing]].
