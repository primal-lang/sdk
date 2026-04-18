---
title: First-Class Functions
tags: [design, functions]
sources:
  - lib/compiler/library/list/
---

# First-Class Functions

**TLDR**: Functions in Primal are first-class values. They can be passed as arguments to other functions, returned from functions, and stored in data structures. This enables powerful patterns like map, filter, and reduce.

## What Are First-Class Functions?

In Primal, functions are values just like numbers, strings, or lists. You can:

- Pass a function as an argument to another function
- Return a function from a function
- Store functions in lists or maps

This flexibility is fundamental to functional programming and enables concise, expressive code.

## Passing Functions as Arguments

The most common use of first-class functions is passing them to higher-order functions like `list.map`, `list.filter`, and `list.reduce`.

### Map: Transform Each Element

`list.map` applies a function to every element in a list, returning a new list of results:

```
double(n) = n * 2

main() = list.map([1, 2, 3], double)  // returns [2, 4, 6]
```

The `double` function is passed directly to `list.map`. There are no special brackets or syntax; `double` is simply a value that happens to be a function.

### Filter: Select Elements

`list.filter` keeps only the elements for which a function returns true:

```
isPositive(n) = n > 0

main() = list.filter([-1, 0, 1, 2], isPositive)  // returns [1, 2]
```

### Reduce: Combine Elements

`list.reduce` combines all elements into a single value using a function:

```
add(a, b) = a + b

main() = list.reduce([1, 2, 3, 4], 0, add)  // returns 10
```

The function receives two arguments: the accumulated value and the current element. Starting from `0`, this example computes `0 + 1 + 2 + 3 + 4`.

## Combining Higher-Order Functions

These functions compose naturally. Here is a practical example that processes a list of numbers:

```
square(n) = n * n
isEven(n) = num.mod(n, 2) == 0
add(a, b) = a + b

sumOfEvenSquares(numbers) =
    let squares = list.map(numbers, square) in
    let evens = list.filter(squares, isEven) in
    list.reduce(evens, 0, add)

main() = sumOfEvenSquares([1, 2, 3, 4, 5])  // returns 20 (4 + 16)
```

## Returning Functions from Functions

Functions can create and return other functions. This is useful for creating specialized versions of general functions:

```
multiplier(factor) = (n) => n * factor

main() =
    let triple = multiplier(3) in
    let quadruple = multiplier(4) in
    [triple(5), quadruple(5)]  // returns [15, 20]
```

The `multiplier` function returns a new function that multiplies its input by the given factor. Each call to `multiplier` creates a distinct function with its own captured `factor` value.

## User-Defined Higher-Order Functions

You can write your own functions that accept functions as arguments:

```
// Apply a function twice
applyTwice(f, x) = f(f(x))

double(n) = n * 2

main() = applyTwice(double, 3)  // returns 12 (3 * 2 * 2)
```

Here is a more practical example that processes pairs of values:

```
// Apply a function to both elements of a pair
mapPair(pair, f) =
    [f(list.at(pair, 0)), f(list.at(pair, 1))]

square(n) = n * n

main() = mapPair([3, 4], square)  // returns [9, 16]
```

## Functions with Multiple Arguments

When using functions like `list.reduce` or `list.zip`, you need functions that take multiple arguments:

```
subtract(a, b) = a - b

main() = list.reduce([10, 3, 2], 0, subtract)  // returns -15 (0 - 10 - 3 - 2)
```

For `list.zip`, the function receives one element from each list:

```
combine(a, b) = a * b

main() = list.zip([1, 2, 3], [10, 20, 30], combine)  // returns [10, 40, 90]
```

## Practical Patterns

### Finding and Checking

Use functions with `list.any`, `list.all`, and `list.none`:

```
isNegative(n) = n < 0

hasNegative(numbers) = list.any(numbers, isNegative)
allPositive(numbers) = list.none(numbers, isNegative)
```

### Counting

Use `list.count` with a predicate function:

```
countEvens(numbers) = list.count(numbers, num.isEven)

main() = countEvens([1, 2, 3, 4, 5, 6])  // returns 3
```

### Sorting

Use `list.sort` with a comparison function:

```
// Sort numbers in descending order
descending(a, b) = num.compare(b, a)

main() = list.sort([3, 1, 4, 1, 5], descending)  // returns [5, 4, 3, 1, 1]
```

## Why First-Class Functions Matter

First-class functions enable you to:

- Write generic operations that work with any transformation
- Separate "what to do" from "how to iterate"
- Build complex behavior by composing simple functions
- Create reusable abstractions without repetitive code

This is a core principle of functional programming: instead of writing loops that repeat similar patterns, you write small functions and combine them using higher-order functions like map, filter, and reduce.
