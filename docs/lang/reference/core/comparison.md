---
title: Comparison
tags:
  - reference
  - operators
sources:
  - lib/compiler/library/comparison/
---

# Comparison

**TLDR**: Functions for comparing values including equality, inequality, and ordering operations on equatable and ordered types.

Number of functions: 6

## Functions

### Equality

- **Signature:** `comp_eq(a: Equatable, b: Equatable): Boolean`
- **Input:** Two equatable arguments (numbers, strings, booleans, timestamps, durations, lists, maps, sets, vectors, stacks, or queues)
- **Output:** True if they are equal. False otherwise
- **Purity:** Pure
- **Example:**

```
comp_eq(5, 5) // returns true
```

### Inequality

- **Signature:** `comp_neq(a: Equatable, b: Equatable): Boolean`
- **Input:** Two equatable arguments (numbers, strings, booleans, timestamps, durations, lists, maps, sets, vectors, stacks, or queues)
- **Output:** True if they are not equal. False otherwise
- **Purity:** Pure
- **Example:**

```
comp_neq(5, 3) // returns true
```

### Greater Than

- **Signature:** `comp_gt(a: Ordered, b: Ordered): Boolean`
- **Input:** Two numbers, two strings, two timestamps, or two durations
- **Output:** True if the first argument is greater than the second one. False otherwise
- **Purity:** Pure
- **Example:**

```
comp_gt(5, 3) // returns true
```

### Less Than

- **Signature:** `comp_lt(a: Ordered, b: Ordered): Boolean`
- **Input:** Two numbers, two strings, two timestamps, or two durations
- **Output:** True if the first argument is less than the second one. False otherwise
- **Purity:** Pure
- **Example:**

```
comp_lt(3, 5) // returns true
```

### Greater Than or Equal

- **Signature:** `comp_ge(a: Ordered, b: Ordered): Boolean`
- **Input:** Two numbers, two strings, two timestamps, or two durations
- **Output:** True if the first argument is greater than or equal to the second one. False otherwise
- **Purity:** Pure
- **Example:**

```
comp_ge(5, 5) // returns true
```

### Less Than or Equal

- **Signature:** `comp_le(a: Ordered, b: Ordered): Boolean`
- **Input:** Two numbers, two strings, two timestamps, or two durations
- **Output:** True if the first argument is less than or equal to the second one. False otherwise
- **Purity:** Pure
- **Example:**

```
comp_le(3, 5) // returns true
```
