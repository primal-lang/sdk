---
title: Comparison
tags: [reference, operators]
sources: [lib/compiler/library/comparison/]
---

# Comparison

**TLDR**: Functions for comparing values including equality, inequality, and ordering operations on equatable and ordered types.

Number of functions: 6

## Functions

### Equal

- **Signature:** `comp.eq(a: Equatable, b: Equatable): Boolean`
- **Input:** Two arguments of equatable type
- **Output:** True if the two arguments are equal, false otherwise
- **Purity:** Pure
- **Example:**

```
comp.eq(5, 5) // returns true
```

### Not Equal

- **Signature:** `comp.neq(a: Equatable, b: Equatable): Boolean`
- **Input:** Two arguments of equatable type
- **Output:** True if the two arguments are not equal, false otherwise
- **Purity:** Pure
- **Example:**

```
comp.neq(5, 3) // returns true
```

### Greater Than

- **Signature:** `comp.gt(a: Ordered, b: Ordered): Boolean`
- **Input:** Two arguments of ordered type
- **Output:** True if the first argument is greater than the second, false otherwise
- **Purity:** Pure
- **Example:**

```
comp.gt(5, 3) // returns true
```

### Less Than

- **Signature:** `comp.lt(a: Ordered, b: Ordered): Boolean`
- **Input:** Two arguments of ordered type
- **Output:** True if the first argument is less than the second, false otherwise
- **Purity:** Pure
- **Example:**

```
comp.lt(3, 5) // returns true
```

### Greater Than or Equal

- **Signature:** `comp.ge(a: Ordered, b: Ordered): Boolean`
- **Input:** Two arguments of ordered type
- **Output:** True if the first argument is greater than or equal to the second, false otherwise
- **Purity:** Pure
- **Example:**

```
comp.ge(5, 5) // returns true
```

### Less Than or Equal

- **Signature:** `comp.le(a: Ordered, b: Ordered): Boolean`
- **Input:** Two arguments of ordered type
- **Output:** True if the first argument is less than or equal to the second, false otherwise
- **Purity:** Pure
- **Example:**

```
comp.le(3, 5) // returns true
```
