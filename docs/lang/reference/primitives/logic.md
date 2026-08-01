---
title: Logic
tags:
  - reference
  - operators
sources:
  - lib/compiler/library/logic/
---

# Logic

**TLDR**: Boolean logic functions including and, or, xor, and not operations with both short-circuit (lazy) and strict (eager) evaluation variants.

Number of functions: 6

## Functions

### And (Short-Circuit)

- **Signature:** `bool_and(a: Boolean, b: Boolean): Boolean`
- **Input:** Two boolean arguments
- **Output:** True if both arguments are true. False otherwise.
- **Evaluation:** Short-circuit (lazy) - the second argument is only evaluated if the first is true
- **Purity:** Pure
- **Example:**

```
bool_and(true, false) // returns false
```

### And (Strict)

- **Signature:** `bool_andStrict(a: Boolean, b: Boolean): Boolean`
- **Input:** Two boolean arguments
- **Output:** True if both arguments are true. False otherwise.
- **Evaluation:** Strict (eager) - both arguments are always evaluated
- **Purity:** Pure
- **Example:**

```
bool_andStrict(true, false) // returns false
```

### Or (Short-Circuit)

- **Signature:** `bool_or(a: Boolean, b: Boolean): Boolean`
- **Input:** Two boolean arguments
- **Output:** True if at least one argument is true. False otherwise.
- **Evaluation:** Short-circuit (lazy) - the second argument is only evaluated if the first is false
- **Purity:** Pure
- **Example:**

```
bool_or(true, false) // returns true
```

### Or (Strict)

- **Signature:** `bool_orStrict(a: Boolean, b: Boolean): Boolean`
- **Input:** Two boolean arguments
- **Output:** True if at least one argument is true. False otherwise.
- **Evaluation:** Strict (eager) - both arguments are always evaluated
- **Purity:** Pure
- **Example:**

```
bool_orStrict(true, false) // returns true
```

### Xor

- **Signature:** `bool_xor(a: Boolean, b: Boolean): Boolean`
- **Input:** Two boolean arguments
- **Output:** True if exactly one argument is true. False otherwise.
- **Purity:** Pure
- **Example:**

```
bool_xor(true, false) // returns true
```

### Not

- **Signature:** `bool_not(a: Boolean): Boolean`
- **Input:** One boolean argument
- **Output:** True if the argument is false. False if the argument is true.
- **Purity:** Pure
- **Example:**

```
bool_not(true) // returns false
```
