---
title: Vector
tags:
  - reference
  - data-structures
sources:
  - lib/compiler/library/vector/
---

# Vector

**TLDR**: Functions for creating and manipulating mathematical vectors with support for arithmetic operations, normalization, dot product, and distance calculations.

Number of functions: 9

## Creation

### New

- **Signature:** `vector_new(a: List): Vector`
- **Input:** A list of numbers
- **Output:** A vector containing the list of numbers
- **Constraints:** Throws an error if any element in the list is not a number
- **Purity:** Pure
- **Example:**

```
vector_new([1, 2, 3]) // returns <1, 2, 3>
```

## Operations

### Add

- **Signature:** `vector_add(a: Vector, b: Vector): Vector`
- **Input:** Two vectors
- **Output:** A vector that is the sum of the two input vectors
- **Constraints:** Throws an error if the vectors have different lengths
- **Purity:** Pure
- **Example:**

```
vector_add(vector_new([1, 2]), vector_new([3, 4])) // returns <4, 6>
```

### Subtract

- **Signature:** `vector_sub(a: Vector, b: Vector): Vector`
- **Input:** Two vectors
- **Output:** A vector that is the difference of the two input vectors
- **Constraints:** Throws an error if the vectors have different lengths
- **Purity:** Pure
- **Example:**

```
vector_sub(vector_new([5, 7]), vector_new([2, 3])) // returns <3, 4>
```

### Normalize

- **Signature:** `vector_normalize(a: Vector): Vector`
- **Input:** A vector
- **Output:** A vector with the same direction but with a magnitude of 1
- **Constraints:** Throws an error if the vector has zero magnitude. Returns the vector unchanged if it is empty
- **Purity:** Pure
- **Example:**

```
vector_normalize(vector_new([3, 4])) // returns <0.6, 0.8>
```

### Scale

- **Signature:** `vector_scale(a: Vector, b: Number): Vector`
- **Input:** A vector and a scalar
- **Output:** A vector scaled by the given scalar
- **Purity:** Pure
- **Example:**

```
vector_scale(vector_new([1, 2]), 3) // returns <3, 6>
```

## Properties

### Magnitude

- **Signature:** `vector_magnitude(a: Vector): Number`
- **Input:** A vector
- **Output:** The magnitude of the input vector
- **Purity:** Pure
- **Example:**

```
vector_magnitude(vector_new([3, 4])) // returns 5
```

### Angle

- **Signature:** `vector_angle(a: Vector, b: Vector): Number`
- **Input:** Two vectors
- **Output:** The angle between the two input vectors in radians
- **Constraints:** Throws an error if the vectors have different lengths, if either vector is empty, or if either vector has zero magnitude
- **Purity:** Pure
- **Example:**

```
vector_angle(vector_new([1, 0]), vector_new([0, 1])) // returns 1.5708...
```

### Dot

- **Signature:** `vector_dot(a: Vector, b: Vector): Number`
- **Input:** Two vectors
- **Output:** The dot product of the two vectors
- **Constraints:** Throws an error if the vectors have different lengths
- **Purity:** Pure
- **Example:**

```
vector_dot(vector_new([1, 2]), vector_new([3, 4])) // returns 11
```

### Distance

- **Signature:** `vector_distance(a: Vector, b: Vector): Number`
- **Input:** Two vectors
- **Output:** The Euclidean distance between the two vectors
- **Constraints:** Throws an error if the vectors have different lengths
- **Purity:** Pure
- **Example:**

```
vector_distance(vector_new([0, 0]), vector_new([3, 4])) // returns 5
```
