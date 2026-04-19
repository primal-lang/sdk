---
title: Queue
tags:
  - reference
  - data-structures
sources:
  - lib/compiler/library/queue/
---

# Queue

**TLDR**: Functions for creating and manipulating first-in-first-out (FIFO) data structures with enqueue, dequeue, and peek operations.

Number of functions: 8

## Creation

### New

- **Signature:** `queue.new(a: List): Queue`
- **Input:** A list of elements
- **Output:** A queue containing the list of elements with the first element at the beginning of the queue
- **Purity:** Pure
- **Example:**

```
queue.new([1, 2, 3]) // returns a queue with 1 at the front
```

## Operations

### Enqueue

- **Signature:** `queue.enqueue(a: Queue, b: Any): Queue`
- **Input:** A queue and an element
- **Output:** A new queue with the element added to the end
- **Purity:** Pure
- **Example:**

```
queue.enqueue(queue.new([1, 2]), 3) // returns a queue [1, 2, 3]
```

### Dequeue

- **Signature:** `queue.dequeue(a: Queue): Queue`
- **Input:** A queue
- **Output:** A new queue with the element at the beginning removed
- **Constraints:** Throws an error if the queue is empty
- **Purity:** Pure
- **Example:**

```
queue.dequeue(queue.new([1, 2, 3])) // returns a queue [2, 3]
```

### Peek

- **Signature:** `queue.peek(a: Queue): Any`
- **Input:** A queue
- **Output:** The element at the beginning of the queue
- **Constraints:** Throws an error if the queue is empty
- **Purity:** Pure
- **Example:**

```
queue.peek(queue.new([1, 2, 3])) // returns 1
```

### Reverse

- **Signature:** `queue.reverse(a: Queue): Queue`
- **Input:** A queue
- **Output:** A new queue with the elements in reverse order
- **Purity:** Pure
- **Example:**

```
queue.reverse(queue.new([1, 2, 3])) // returns a queue [3, 2, 1]
```

## Properties

### Is Empty

- **Signature:** `queue.isEmpty(a: Queue): Boolean`
- **Input:** A queue
- **Output:** True if the queue is empty, false otherwise
- **Purity:** Pure
- **Example:**

```
queue.isEmpty(queue.new([])) // returns true
```

### Is Not Empty

- **Signature:** `queue.isNotEmpty(a: Queue): Boolean`
- **Input:** A queue
- **Output:** True if the queue is not empty, false otherwise
- **Purity:** Pure
- **Example:**

```
queue.isNotEmpty(queue.new([1, 2])) // returns true
```

### Length

- **Signature:** `queue.length(a: Queue): Number`
- **Input:** A queue
- **Output:** The number of elements in the queue
- **Purity:** Pure
- **Example:**

```
queue.length(queue.new([1, 2, 3])) // returns 3
```
