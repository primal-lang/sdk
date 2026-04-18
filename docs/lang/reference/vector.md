---
title: Vector
tags: [reference, data-structures]
sources: [lib/compiler/library/vector/]
---

# Vector

**TLDR**: Functions for creating and manipulating mathematical vectors with support for arithmetic operations, normalization, dot product, and distance calculations.

Number of functions: 9

## Creation

### New

- **Signature:** `vector.new(a: List): Vector`
- **Input:** One list of numbers
- **Output:** A vector created from the list
- **Constraints:** Throws an error if any element in the list is not a number
- **Purity:** Pure
- **Example:**

```
vector.new([1, 2, 3]) // returns a vector <1, 2, 3>
```

## Operations

### Add

- **Signature:** `vector.add(a: Vector, b: Vector): Vector`
- **Input:** Two vectors
- **Output:** The sum of the two vectors
- **Constraints:** Throws an error if the vectors have different lengths
- **Purity:** Pure
- **Example:**

```
vector.add(vector.new([1, 2]), vector.new([3, 4])) // returns <4, 6>
```

### Subtract

- **Signature:** `vector.sub(a: Vector, b: Vector): Vector`
- **Input:** Two vectors
- **Output:** The difference of the two vectors
- **Constraints:** Throws an error if the vectors have different lengths
- **Purity:** Pure
- **Example:**

```
vector.sub(vector.new([5, 7]), vector.new([2, 3])) // returns <3, 4>
```

### Normalize

- **Signature:** `vector.normalize(a: Vector): Vector`
- **Input:** One vector
- **Output:** A vector with the same direction but with a magnitude of 1
- **Constraints:** Throws an error if the vector has zero magnitude. Returns the vector unchanged if it is empty
- **Purity:** Pure
- **Example:**

```
vector.normalize(vector.new([3, 4])) // returns <0.6, 0.8>
```

### Scale

- **Signature:** `vector.scale(a: Vector, b: Number): Vector`
- **Input:** One vector and one number (scalar)
- **Output:** A new vector with each component multiplied by the scalar
- **Purity:** Pure
- **Example:**

```
vector.scale(vector.new([1, 2, 3]), 2) // returns <2, 4, 6>
```

## Properties

### Magnitude

- **Signature:** `vector.magnitude(a: Vector): Number`
- **Input:** One vector
- **Output:** The magnitude of the vector
- **Purity:** Pure
- **Example:**

```
vector.magnitude(vector.new([3, 4])) // returns 5
```

### Angle

- **Signature:** `vector.angle(a: Vector, b: Vector): Number`
- **Input:** Two vectors
- **Output:** The angle between the two vectors in radians
- **Constraints:** Throws an error if the vectors have different lengths, if either vector is empty, or if either vector has zero magnitude
- **Purity:** Pure
- **Example:**

```
vector.angle(vector.new([1, 0]), vector.new([0, 1])) // returns 1.5708...
```

### Dot

- **Signature:** `vector.dot(a: Vector, b: Vector): Number`
- **Input:** Two vectors
- **Output:** The dot product (scalar product) of the two vectors
- **Constraints:** Throws an error if the vectors have different lengths
- **Purity:** Pure
- **Example:**

```
vector.dot(vector.new([1, 2, 3]), vector.new([4, 5, 6])) // returns 32
```

### Distance

- **Signature:** `vector.distance(a: Vector, b: Vector): Number`
- **Input:** Two vectors
- **Output:** The Euclidean distance between the two vectors
- **Constraints:** Throws an error if the vectors have different lengths
- **Purity:** Pure
- **Example:**

```
vector.distance(vector.new([0, 0]), vector.new([3, 4])) // returns 5
```
