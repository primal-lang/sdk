---
title: Arithmetic
tags:
  - reference
  - math
sources:
  - lib/compiler/library/arithmetic/
---

# Arithmetic

**TLDR**: Mathematical functions for basic operations, rounding, constraints, trigonometry, random number generation, and numeric property checking.

Number of functions: 38

## Basic Operations

### Absolute Value

- **Signature:** `num.abs(a: Number): Number`
- **Input:** One number
- **Output:** The absolute value of the number
- **Purity:** Pure
- **Example:**

```
num.abs(-5) // returns 5
```

### Negation

- **Signature:** `num.negative(a: Number): Number`
- **Input:** One number
- **Output:** The negative of the absolute value of the number. Always returns a non-positive number.
- **Purity:** Pure
- **Example:**

```
num.negative(3) // returns -3
```

### Increment

- **Signature:** `num.inc(a: Number): Number`
- **Input:** One number
- **Output:** The number incremented by one
- **Purity:** Pure
- **Example:**

```
num.inc(4) // returns 5
```

### Decrement

- **Signature:** `num.dec(a: Number): Number`
- **Input:** One number
- **Output:** The number decremented by one
- **Purity:** Pure
- **Example:**

```
num.dec(4) // returns 3
```

### Sign

- **Signature:** `num.sign(a: Number): Number`
- **Input:** A number
- **Output:** 1 if the number is positive. -1 if the number is negative. 0 if the number is zero.
- **Purity:** Pure
- **Example:**

```
num.sign(-7) // returns -1
```

### Fraction

- **Signature:** `num.fraction(a: Number): Number`
- **Input:** A number
- **Output:** The fractional part of the number
- **Purity:** Pure
- **Example:**

```
num.fraction(3.75) // returns 0.75
```

### Infinity

- **Signature:** `num.infinity(): Number`
- **Input:** None
- **Output:** Positive infinity
- **Purity:** Pure
- **Example:**

```
num.infinity() // returns infinity
```

## Arithmetic Operations

### Addition

- **Signature:** `num.add(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The sum of the numbers
- **Purity:** Pure
- **Example:**

```
num.add(3, 4) // returns 7
```

### Sum

- **Signature:** `num.sum(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The sum of the numbers
- **Purity:** Pure
- **Example:**

```
num.sum(3, 4) // returns 7
```

### Subtraction

- **Signature:** `num.sub(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The difference of the numbers
- **Purity:** Pure
- **Example:**

```
num.sub(10, 3) // returns 7
```

### Multiplication

- **Signature:** `num.mul(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The product of the numbers
- **Purity:** Pure
- **Example:**

```
num.mul(3, 4) // returns 12
```

### Division

- **Signature:** `num.div(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The division of the numbers
- **Constraints:** Throws an error if the divisor is zero
- **Purity:** Pure
- **Example:**

```
num.div(10, 2) // returns 5
```

### Modulo

- **Signature:** `num.mod(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The remainder of the division of the numbers
- **Constraints:** Throws an error if the divisor is zero
- **Purity:** Pure
- **Example:**

```
num.mod(10, 3) // returns 1
```

### Power

- **Signature:** `num.pow(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The first number raised to the power of the second number
- **Constraints:** Throws an error if the base is negative and the exponent is fractional, or if the result is not a finite number (e.g., overflow to infinity)
- **Purity:** Pure
- **Example:**

```
num.pow(2, 3) // returns 8
```

### Square Root

- **Signature:** `num.sqrt(a: Number): Number`
- **Input:** One number
- **Output:** The square root of the number
- **Constraints:** Throws an error if the number is negative
- **Purity:** Pure
- **Example:**

```
num.sqrt(9) // returns 3
```

## Rounding

### Round

- **Signature:** `num.round(a: Number): Number`
- **Input:** One number
- **Output:** The number rounded to the nearest integer
- **Purity:** Pure
- **Example:**

```
num.round(3.6) // returns 4
```

### Floor

- **Signature:** `num.floor(a: Number): Number`
- **Input:** One number
- **Output:** The largest integer less than or equal to the number
- **Purity:** Pure
- **Example:**

```
num.floor(3.9) // returns 3
```

### Ceiling

- **Signature:** `num.ceil(a: Number): Number`
- **Input:** One number
- **Output:** The smallest integer greater than or equal to the number
- **Purity:** Pure
- **Example:**

```
num.ceil(3.1) // returns 4
```

### Truncate

- **Signature:** `num.truncate(a: Number): Number`
- **Input:** A number
- **Output:** The integer part of the number, discarding any fractional part
- **Purity:** Pure
- **Example:**

```
num.truncate(3.7) // returns 3
```

### Round To

- **Signature:** `num.roundTo(a: Number, b: Number): Number`
- **Input:** A number and the number of decimal places
- **Output:** The number rounded to the specified decimal places
- **Constraints:** Throws an error if the number of decimal places is negative
- **Purity:** Pure
- **Example:**

```
num.roundTo(3.14159, 2) // returns 3.14
```

## Constraints

### Minimum

- **Signature:** `num.min(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The smallest of the numbers
- **Purity:** Pure
- **Example:**

```
num.min(3, 7) // returns 3
```

### Maximum

- **Signature:** `num.max(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The largest of the numbers
- **Purity:** Pure
- **Example:**

```
num.max(3, 7) // returns 7
```

### Clamp

- **Signature:** `num.clamp(a: Number, b: Number, c: Number): Number`
- **Input:** Three numbers
- **Output:** The first number clamped to be in the range of the second and third number
- **Constraints:** Throws an error if the min bound is greater than the max bound
- **Purity:** Pure
- **Example:**

```
num.clamp(15, 0, 10) // returns 10
```

## Trigonometry

### Sine

- **Signature:** `num.sin(a: Number): Number`
- **Input:** A number (in radians)
- **Output:** The sine of the number
- **Purity:** Pure
- **Example:**

```
num.sin(0) // returns 0
```

### Cosine

- **Signature:** `num.cos(a: Number): Number`
- **Input:** A number (in radians)
- **Output:** The cosine of the number
- **Purity:** Pure
- **Example:**

```
num.cos(0) // returns 1
```

### Tangent

- **Signature:** `num.tan(a: Number): Number`
- **Input:** A number (in radians)
- **Output:** The tangent of the number
- **Purity:** Pure
- **Example:**

```
num.tan(0) // returns 0
```

### Logarithm

- **Signature:** `num.log(a: Number): Number`
- **Input:** A number
- **Output:** The natural logarithm of the number
- **Constraints:** Throws an error if the number is not positive
- **Purity:** Pure
- **Example:**

```
num.log(1) // returns 0
```

### Logarithm Base

- **Signature:** `num.logBase(a: Number, b: Number): Number`
- **Input:** Two numbers (value and base)
- **Output:** The logarithm of the value with the specified base
- **Constraints:** Throws an error if the number is not positive, if the base is not positive, or if the base is 1
- **Purity:** Pure
- **Example:**

```
num.logBase(8, 2) // returns 3
```

### To Radians

- **Signature:** `num.asRadians(a: Number): Number`
- **Input:** An angle in degrees
- **Output:** The angle converted to radians
- **Purity:** Pure
- **Example:**

```
num.asRadians(180) // returns 3.14159...
```

### To Degrees

- **Signature:** `num.asDegrees(a: Number): Number`
- **Input:** An angle in radians
- **Output:** The angle converted to degrees
- **Purity:** Pure
- **Example:**

```
num.asDegrees(3.14159) // returns 180
```

## Properties

### Is Negative

- **Signature:** `num.isNegative(a: Number): Boolean`
- **Input:** A number
- **Output:** True if the number is negative. False otherwise.
- **Purity:** Pure
- **Example:**

```
num.isNegative(-3) // returns true
```

### Is Positive

- **Signature:** `num.isPositive(a: Number): Boolean`
- **Input:** A number
- **Output:** True if the number is positive. False otherwise.
- **Purity:** Pure
- **Example:**

```
num.isPositive(5) // returns true
```

### Is Zero

- **Signature:** `num.isZero(a: Number): Boolean`
- **Input:** A number
- **Output:** True if the number is zero. False otherwise.
- **Purity:** Pure
- **Example:**

```
num.isZero(0) // returns true
```

### Is Even

- **Signature:** `num.isEven(a: Number): Boolean`
- **Input:** A number
- **Output:** True if the number is even. False otherwise.
- **Purity:** Pure
- **Example:**

```
num.isEven(4) // returns true
```

### Is Odd

- **Signature:** `num.isOdd(a: Number): Boolean`
- **Input:** A number
- **Output:** True if the number is odd. False otherwise.
- **Purity:** Pure
- **Example:**

```
num.isOdd(3) // returns true
```

## Random

### Integer Random

- **Signature:** `num.integerRandom(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** A random integer between the two numbers (inclusive)
- **Constraints:** Throws an error if the second number is less than the first, or if the range overflows
- **Purity:** Impure
- **Example:**

```
num.integerRandom(1, 10) // returns a random integer from 1 to 10
```

### Decimal Random

- **Signature:** `num.decimalRandom(): Number`
- **Input:** None
- **Output:** A random decimal number between 0 and 1
- **Purity:** Impure
- **Example:**

```
num.decimalRandom() // returns a random decimal
```

## Comparison

### Compare

- **Signature:** `num.compare(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** 1 if the first number is bigger than the second. -1 if it is the smaller. 0 if they are equal.
- **Purity:** Pure
- **Example:**

```
num.compare(5, 3) // returns 1
```
