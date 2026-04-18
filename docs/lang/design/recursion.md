---
title: Recursion
tags: [design, recursion]
sources: []
---

# Recursion

**TLDR**: Primal has no loop constructs. Recursion is the fundamental mechanism for iteration, with higher-order functions like `list.map` and `list.reduce` providing declarative alternatives for common patterns.

## Overview

As a functional language inspired by lambda calculus, Primal does not include traditional loop constructs like `for` or `while`. Instead, repetitive computation is expressed through recursion, where a function calls itself with modified arguments until reaching a base case.

## Basic Recursion

### Factorial

The classic example of recursion is computing factorial:

```
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)
```

This function:

1. Checks if `n` is 1 or less (base case), returning 1
2. Otherwise, multiplies `n` by the factorial of `n - 1` (recursive case)

```
factorial(5) // returns 120 (5 * 4 * 3 * 2 * 1)
```

### Fibonacci

The Fibonacci sequence demonstrates recursion with multiple recursive calls:

```
fibonacci(n) = if (n <= 1) n else fibonacci(n - 1) + fibonacci(n - 2)
```

```
fibonacci(10) // returns 55
```

Note: This naive implementation has exponential time complexity. See the accumulator pattern below for a more efficient approach.

### Sum of a List

Recursion naturally processes list structures:

```
sum(items) = if (list.isEmpty(items)) 0
             else list.first(items) + sum(list.rest(items))
```

```
sum([1, 2, 3, 4, 5]) // returns 15
```

## Tail Recursion

A function is **tail recursive** when the recursive call is the last operation performed. Tail-recursive functions can potentially be optimized to use constant stack space.

### Non-Tail Recursive

```
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)
```

Here, `n * factorial(n - 1)` means multiplication happens after the recursive call returns, so it is not tail recursive.

### Tail Recursive with Accumulator

```
factorialTail(n, accumulator) = if (n <= 1) accumulator
                                 else factorialTail(n - 1, n * accumulator)

factorial(n) = factorialTail(n, 1)
```

Now the recursive call `factorialTail(n - 1, n * accumulator)` is the last operation. The result of the recursive call is directly returned without further computation.

## The Accumulator Pattern

The accumulator pattern transforms non-tail recursive functions into tail recursive ones by carrying the intermediate result as a parameter.

### Fibonacci with Accumulator

```
fibonacciHelper(n, previous, current) =
    if (n == 0) previous
    else fibonacciHelper(n - 1, current, previous + current)

fibonacci(n) = fibonacciHelper(n, 0, 1)
```

This version runs in linear time instead of exponential time.

### List Reversal

```
reverseHelper(items, accumulator) =
    if (list.isEmpty(items)) accumulator
    else reverseHelper(list.rest(items), list.insertStart(accumulator, list.first(items)))

reverse(items) = reverseHelper(items, [])
```

## Higher-Order Functions as Alternatives

For many common patterns, Primal's higher-order functions provide cleaner, more declarative alternatives to explicit recursion.

### Using list.map

Transform each element without explicit recursion:

```
// Explicit recursion
doubleAll(items) = if (list.isEmpty(items)) []
                   else list.insertStart(doubleAll(list.rest(items)),
                                         list.first(items) * 2)

// Using list.map
doubleAll(items) = list.map(items, (x) => x * 2)
```

```
doubleAll([1, 2, 3]) // returns [2, 4, 6]
```

### Using list.filter

Select elements matching a condition:

```
// Explicit recursion
evens(items) = if (list.isEmpty(items)) []
               else if (list.first(items) % 2 == 0)
                    list.insertStart(evens(list.rest(items)), list.first(items))
               else evens(list.rest(items))

// Using list.filter
evens(items) = list.filter(items, (x) => x % 2 == 0)
```

```
evens([1, 2, 3, 4, 5, 6]) // returns [2, 4, 6]
```

### Using list.reduce

Combine all elements into a single value:

```
// Explicit recursion
sum(items) = if (list.isEmpty(items)) 0
             else list.first(items) + sum(list.rest(items))

// Using list.reduce
sum(items) = list.reduce(items, 0, num.add)
```

```
sum([1, 2, 3, 4, 5]) // returns 15
```

The `list.reduce` function takes a list, an initial value, and a combining function. It processes each element, accumulating the result.

```
product(items) = list.reduce(items, 1, num.mul)
product([2, 3, 4]) // returns 24
```

## Divide and Conquer

Some problems are naturally solved by dividing them into smaller subproblems.

### Merge Sort

```
merge(left, right) =
    if (list.isEmpty(left)) right
    else if (list.isEmpty(right)) left
    else if (list.first(left) <= list.first(right))
         list.insertStart(merge(list.rest(left), right), list.first(left))
    else list.insertStart(merge(left, list.rest(right)), list.first(right))

mergeSort(items) =
    let length = list.length(items) in
    if (length <= 1) items
    else let mid = length / 2,
             left = list.take(items, mid),
             right = list.drop(items, mid)
         in merge(mergeSort(left), mergeSort(right))
```

### Binary Search

```
binarySearch(items, target, low, high) =
    if (low > high) -1
    else let mid = (low + high) / 2,
             midValue = list.at(items, mid)
         in if (midValue == target) mid
            else if (midValue < target) binarySearch(items, target, mid + 1, high)
            else binarySearch(items, target, low, mid - 1)

search(items, target) = binarySearch(items, target, 0, list.length(items) - 1)
```

## Common Patterns Summary

| Pattern            | When to Use                                      | Example                          |
| ------------------ | ------------------------------------------------ | -------------------------------- |
| Basic recursion    | Simple problems with clear base case             | `factorial`, `fibonacci`         |
| Accumulator        | When you need tail recursion or to carry state   | `factorialTail`, `reverseHelper` |
| `list.map`         | Transform each element uniformly                 | `doubleAll`, `toUpperCase`       |
| `list.filter`      | Select elements matching a condition             | `evens`, `positives`             |
| `list.reduce`      | Combine elements into a single value             | `sum`, `product`, `max`          |
| Divide and conquer | Problems that split into independent subproblems | `mergeSort`, `binarySearch`      |

## Recursion Limits

Primal enforces a maximum recursion depth of 1000 to prevent stack overflow. If your recursive function exceeds this limit, consider:

1. Using the accumulator pattern for tail recursion
2. Replacing explicit recursion with higher-order functions like `list.reduce`
3. Restructuring the algorithm to reduce recursion depth

## Related Topics

- [[lang/reference/list]] - List operations including `map`, `filter`, and `reduce`
- [[lang/reference/control]] - Control flow constructs like `if-else` and `let`
