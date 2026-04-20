---
title: Tuples
tags:
  - roadmap
  - types
sources: []
---

# Tuples

**TLDR**: Tuples are fixed-size, ordered collections of heterogeneous values using parentheses syntax `(a, b, c)`, supporting positional access, destructuring in function parameters and bindings, and multi-value function returns.

This proposal introduces tuples and records with destructuring to Primal, providing a lightweight way to model structured data without forcing everything through maps. It also opens the door to cleaner function returns and helper composition.

## 1. Tuple Literals

A tuple is an ordered, fixed-size collection of values. Using parentheses keeps the syntax minimal:

```primal
point() = (10, 20)
person() = ("Alice", 30, true)
```

## 2. Named Records

Records add semantic meaning by labeling fields. A lightweight syntax using `{field: value}` (distinct from maps which use `{key -> value}`):

```primal
point() = {x: 10, y: 20}
person() = {name: "Alice", age: 30, active: true}
```

## 3. Accessing Elements

**Positional (tuples):**

```primal
x() = first(point())      // 10
y() = second(point())     // 20
// or index-based:
x() = point().0           // 10
```

**Named (records):**

```primal
name() = person().name    // "Alice"
age() = person().age      // 30
```

## 4. Destructuring in Function Parameters

This is where the real power emerges — unpacking directly in signatures:

```primal
// Tuple destructuring
distance((x1, y1), (x2, y2)) = sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))

// Record destructuring
greet({name, age}) = concat("Hello, ", name, "! You are ", str(age))
```

## 5. Destructuring in Bindings

Allow unpacking in local bindings (if Primal adds `let` or similar):

```primal
// Hypothetical let-binding syntax
result() = let (x, y) = getCoordinates() in x + y

// Or inline with a where-clause style
hypotenuse() = sqrt(x*x + y*y) where (x, y) = getPoint()
```

## 6. Multi-Value Function Returns

Functions can cleanly return multiple values:

```primal
divmod(a, b) = (div(a, b), mod(a, b))

// Caller destructures
main() = let (quotient, remainder) = divmod(17, 5) in
       concat("Q: ", str(quotient), " R: ", str(remainder))
```

## 7. Nested Destructuring

For composability with complex data:

```primal
// Nested tuple
swap((a, (b, c))) = ((b, c), a)

// Nested record
fullName({name: {first, last}}) = concat(first, " ", last)
```

## 8. Partial/Wildcard Destructuring

Ignore unused fields with `_`:

```primal
getX((x, _)) = x
getName({name, _}) = name   // ignore other fields
```

## Summary

| Feature           | Syntax Example      |
| ----------------- | ------------------- |
| Tuple literal     | `(1, 2, 3)`         |
| Record literal    | `{x: 10, y: 20}`    |
| Tuple access      | `t.0` or `first(t)` |
| Record access     | `r.name`            |
| Param destructure | `f((a, b)) = ...`   |
| Return multiple   | `= (x, y)`          |
| Wildcard          | `(a, _)`            |

This keeps Primal's minimalist philosophy while enabling cleaner APIs, safer data modeling, and more expressive function composition.

# More

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** Medium

Add fixed-size heterogeneous collections:

```
point() = (3, 4)
person() = ("Alice", 30, true)

x() = tuple.first(point())
name() = tuple.at(person(), 0)
```

**Why it belongs:** Lists are currently used for many things, but they do not communicate "fixed-size structured value". Tuples would be a lightweight way to return multiple values and model small product data.

**Design notes:**

- Tuples should be distinct from lists in printing, equality, and type checks.
- They should support indexing and equality out of the box.
- If records are added later, tuples remain useful for positional data.
- This is a runtime/data-model addition, not just syntax sugar.
