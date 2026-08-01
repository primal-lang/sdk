---
title: Stack
tags:
  - reference
  - data-structures
sources:
  - lib/compiler/library/stack/
---

# Stack

**TLDR**: Functions for creating and manipulating last-in-first-out (LIFO) data structures with push, pop, and peek operations.

Number of functions: 8

## Creation

### New

- **Signature:** `stack_new(a: List): Stack`
- **Input:** A list of elements
- **Output:** A stack containing the list of elements with the last element at the top of the stack
- **Purity:** Pure
- **Example:**

```
stack_new([1, 2, 3]) // returns a stack with 3 at the top
```

## Operations

### Push

- **Signature:** `stack_push(a: Stack, b: Any): Stack`
- **Input:** A stack and an element
- **Output:** A new stack with the element added to the top
- **Purity:** Pure
- **Example:**

```
stack_push(stack_new([1, 2]), 3) // returns a stack with 3 at the top
```

### Pop

- **Signature:** `stack_pop(a: Stack): Stack`
- **Input:** A stack
- **Output:** A new stack with the top element removed
- **Constraints:** Throws an error if the stack is empty
- **Purity:** Pure
- **Example:**

```
stack_pop(stack_new([1, 2, 3])) // returns a stack with 2 at the top
```

### Peek

- **Signature:** `stack_peek(a: Stack): Any`
- **Input:** A stack
- **Output:** The element at the top of the stack
- **Constraints:** Throws an error if the stack is empty
- **Purity:** Pure
- **Example:**

```
stack_peek(stack_new([1, 2, 3])) // returns 3
```

### Reverse

- **Signature:** `stack_reverse(a: Stack): Stack`
- **Input:** A stack
- **Output:** A new stack with the elements in reverse order
- **Purity:** Pure
- **Example:**

```
stack_reverse(stack_new([1, 2, 3])) // returns a stack with 1 at the top
```

## Properties

### Is Empty

- **Signature:** `stack_isEmpty(a: Stack): Boolean`
- **Input:** A stack
- **Output:** True if the stack is empty, false otherwise
- **Purity:** Pure
- **Example:**

```
stack_isEmpty(stack_new([])) // returns true
```

### Is Not Empty

- **Signature:** `stack_isNotEmpty(a: Stack): Boolean`
- **Input:** A stack
- **Output:** True if the stack is not empty, false otherwise
- **Purity:** Pure
- **Example:**

```
stack_isNotEmpty(stack_new([1, 2])) // returns true
```

### Length

- **Signature:** `stack_length(a: Stack): Number`
- **Input:** A stack
- **Output:** The number of elements in the stack
- **Purity:** Pure
- **Example:**

```
stack_length(stack_new([1, 2, 3])) // returns 3
```
