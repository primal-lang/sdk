# Arithmetic

## Basic Operations

### Absolute Value

- **Signature:** `num.abs(a: Number): Number`
- **Input:** One number
- **Output:** The absolute value of the number

```
num.abs(a: Number): Number
```

### Negation

- **Signature:** `num.negative(a: Number): Number`
- **Input:** One number
- **Output:** The negative value of the number

### Increment

- **Signature:** `num.inc(a: Number): Number`
- **Input:** One number
- **Output:** The number incremented by one

### Decrement

- **Signature:** `num.dec(a: Number): Number`
- **Input:** One number
- **Output:** The number decremented by one

### Sign

- **Signature:** `num.sign(a: Number): Number`
- **Input:** One number
- **Output:** 1 for positive, -1 for negative, or 0 for zero

### Fraction

- **Signature:** `num.fraction(a: Number): Number`
- **Input:** One number
- **Output:** The fractional part of the number

### Infinity

- **Signature:** `num.infinity(): Number`
- **Input:** None
- **Output:** Positive infinity

## Arithmetic Operations

### Addition

- **Signature:** `num.add(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The sum of the numbers

### Sum

- **Signature:** `num.sum(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The sum of the numbers

### Subtraction

- **Signature:** `num.sub(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The difference between the numbers

### Multiplication

- **Signature:** `num.mul(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The product of the numbers

### Division

- **Signature:** `num.div(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The quotient of the numbers

### Modulo

- **Signature:** `num.mod(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The remainder of dividing the numbers

### Power

- **Signature:** `num.pow(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The first number raised to the power of the second

### Square Root

- **Signature:** `num.sqrt(a: Number): Number`
- **Input:** One number
- **Output:** The square root of the number

## Rounding

### Round

- **Signature:** `num.round(a: Number): Number`
- **Input:** One number
- **Output:** The number rounded to the nearest integer

### Floor

- **Signature:** `num.floor(a: Number): Number`
- **Input:** One number
- **Output:** The largest integer less than or equal to the number

### Ceiling

- **Signature:** `num.ceil(a: Number): Number`
- **Input:** One number
- **Output:** The smallest integer greater than or equal to the number

## Constraints

### Minimum

- **Signature:** `num.min(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The smaller of the two numbers

### Maximum

- **Signature:** `num.max(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** The larger of the two numbers

### Clamp

- **Signature:** `num.clamp(a: Number, b: Number, c: Number): Number`
- **Input:** Three numbers
- **Output:** The first number constrained within the range defined by the second and third numbers

## Trigonometry

### Sine

- **Signature:** `num.sin(a: Number): Number`
- **Input:** One number in radians
- **Output:** The sine of the number

### Cosine

- **Signature:** `num.cos(a: Number): Number`
- **Input:** One number in radians
- **Output:** The cosine of the number

### Tangent

- **Signature:** `num.tan(a: Number): Number`
- **Input:** One number in radians
- **Output:** The tangent of the number

### Logarithm

- **Signature:** `num.log(a: Number): Number`
- **Input:** One number
- **Output:** The natural logarithm of the number

### To Radians

- **Signature:** `num.asRadians(a: Number): Number`
- **Input:** One number in degrees
- **Output:** The angle converted to radians

### To Degrees

- **Signature:** `num.asDegrees(a: Number): Number`
- **Input:** One number in radians
- **Output:** The angle converted to degrees

## Properties

### Is Negative

- **Signature:** `num.isNegative(a: Number): Boolean`
- **Input:** One number
- **Output:** True if the number is negative, false otherwise

### Is Positive

- **Signature:** `num.isPositive(a: Number): Boolean`
- **Input:** One number
- **Output:** True if the number is positive, false otherwise

### Is Zero

- **Signature:** `num.isZero(a: Number): Boolean`
- **Input:** One number
- **Output:** True if the number is zero, false otherwise

### Is Even

- **Signature:** `num.isEven(a: Number): Boolean`
- **Input:** One number
- **Output:** True if the number is even, false otherwise

### Is Odd

- **Signature:** `num.isOdd(a: Number): Boolean`
- **Input:** One number
- **Output:** True if the number is odd, false otherwise

## Random

### Integer Random

- **Signature:** `num.integerRandom(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** A random integer between the two numbers (inclusive)

### Decimal Random

- **Signature:** `num.decimalRandom(): Number`
- **Input:** None
- **Output:** A random decimal number between 0 and 1

## Comparison

### Compare

- **Signature:** `num.compare(a: Number, b: Number): Number`
- **Input:** Two numbers
- **Output:** 1 if the first number is larger, -1 if smaller, or 0 if equal
