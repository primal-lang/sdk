---
title: Operators
tags: [reference, operators]
sources:
  - lib/compiler/library/operators/
---

# Operators

**TLDR**: Built-in infix operators for comparison, arithmetic, and logical operations including equality, addition, subtraction, multiplication, division, and boolean logic.

Number of functions: 16

## Comparison Operators

### Equality

- **Symbol:** `==`
- **Input:** Two arguments of equatable type
- **Output:** True if equal, false otherwise
- **Supported combinations:**
  - `Boolean == Boolean`
  - `Number == Number`
  - `String == String`
  - `Timestamp == Timestamp`
  - `Duration == Duration`
  - `File == File` (compares absolute paths)
  - `Directory == Directory` (compares absolute paths)
  - `List == List` (element-wise)
  - `Vector == Vector` (element-wise)
  - `Stack == Stack` (element-wise)
  - `Queue == Queue` (element-wise)
  - `Set == Set`
  - `Map == Map` (key-wise and value-wise)
- **Purity:** Pure
- **Example:**

```
5 == 5 // returns true
```

### Inequality

- **Symbol:** `!=`
- **Input:** Two arguments of equatable type
- **Output:** True if not equal, false otherwise
- **Supported combinations:**
  - `Boolean != Boolean`
  - `Number != Number`
  - `String != String`
  - `Timestamp != Timestamp`
  - `Duration != Duration`
  - `File != File` (compares absolute paths)
  - `Directory != Directory` (compares absolute paths)
  - `List != List` (element-wise)
  - `Vector != Vector` (element-wise)
  - `Stack != Stack` (element-wise)
  - `Queue != Queue` (element-wise)
  - `Set != Set`
  - `Map != Map` (key-wise and value-wise)
- **Purity:** Pure
- **Example:**

```
5 != 3 // returns true
```

### Greater Than

- **Symbol:** `>`
- **Input:** Two arguments of the same type
- **Output:** True if first argument exceeds the second, false otherwise
- **Supported combinations:**
  - `Number > Number`
  - `String > String` (lexicographic)
  - `Timestamp > Timestamp`
  - `Duration > Duration`
- **Purity:** Pure
- **Example:**

```
5 > 3 // returns true
```

### Less Than

- **Symbol:** `<`
- **Input:** Two arguments of the same type
- **Output:** True if first argument is less than second, false otherwise
- **Supported combinations:**
  - `Number < Number`
  - `String < String` (lexicographic)
  - `Timestamp < Timestamp`
  - `Duration < Duration`
- **Purity:** Pure
- **Example:**

```
3 < 5 // returns true
```

### Greater Than or Equal

- **Symbol:** `>=`
- **Input:** Two arguments of the same type
- **Output:** True if first argument is greater than or equal to second, false otherwise
- **Supported combinations:**
  - `Number >= Number`
  - `String >= String` (lexicographic)
  - `Timestamp >= Timestamp`
  - `Duration >= Duration`
- **Purity:** Pure
- **Example:**

```
5 >= 5 // returns true
```

### Less Than or Equal

- **Symbol:** `<=`
- **Input:** Two arguments of the same type
- **Output:** True if first argument is less than or equal to second, false otherwise
- **Supported combinations:**
  - `Number <= Number`
  - `String <= String` (lexicographic)
  - `Timestamp <= Timestamp`
  - `Duration <= Duration`
- **Purity:** Pure
- **Example:**

```
3 <= 5 // returns true
```

## Arithmetic Operators

### Addition

- **Symbol:** `+`
- **Input:** Two arguments of addable type
- **Output:** The combined result
- **Supported combinations:**
  - `Number + Number`
  - `String + String`
  - `Duration + Duration`
  - `Vector + Vector`
  - `Any + List`
  - `List + Any`
  - `List + List`
  - `Set + Set` (union)
  - `Set + Any` (add element)
  - `Any + Set` (add element)
- **Purity:** Pure
- **Example:**

```
3 + 4 // returns 7
```

### Subtraction

- **Symbol:** `-`
- **Input:** Two arguments of subtractable type
- **Output:** The result of the subtraction
- **Supported combinations:**
  - `Number - Number`
  - `Duration - Duration` (throws `NegativeDurationError` if result would be negative)
  - `Vector - Vector`
  - `Set - Set` (set difference)
  - `Set - Any` (remove element)
- **Purity:** Pure
- **Example:**

```
10 - 3 // returns 7
```

### Multiplication

- **Symbol:** `*`
- **Input:** Two numbers
- **Output:** The product of the numbers
- **Purity:** Pure
- **Example:**

```
3 * 4 // returns 12
```

### Division

- **Symbol:** `/`
- **Input:** Two numbers
- **Output:** The quotient
- **Errors:** Throws `DivisionByZeroError` if the divisor is zero
- **Purity:** Pure
- **Example:**

```
10 / 2 // returns 5
```

### Modulo

- **Symbol:** `%`
- **Input:** Two numbers
- **Output:** The remainder of division
- **Errors:** Throws `DivisionByZeroError` if the divisor is zero
- **Purity:** Pure
- **Example:**

```
10 % 3 // returns 1
```

## Logical Operators

### And (Short-Circuit)

- **Symbols:** `&&`, `and`
- **Input:** Two boolean arguments
- **Output:** True only if both arguments are true, false otherwise
- **Evaluation:** Short-circuit (lazy) - the second operand is only evaluated if the first is true
- **Purity:** Pure
- **Example:**

```
true && false  // returns false
true and false // returns false
false && error.throw(-1, "Not evaluated") // returns false (no error thrown)
```

### And (Strict)

- **Symbol:** `&`
- **Input:** Two boolean arguments
- **Output:** True only if both arguments are true, false otherwise
- **Evaluation:** Strict (eager) - both operands are always evaluated
- **Purity:** Pure
- **Example:**

```
true & false // returns false
false & true // returns false (both operands evaluated)
```

### Or (Short-Circuit)

- **Symbols:** `||`, `or`
- **Input:** Two boolean arguments
- **Output:** True if at least one argument is true, false otherwise
- **Evaluation:** Short-circuit (lazy) - the second operand is only evaluated if the first is false
- **Purity:** Pure
- **Example:**

```
true || false  // returns true
true or false  // returns true
true || error.throw(-1, "Not evaluated") // returns true (no error thrown)
```

### Or (Strict)

- **Symbol:** `|`
- **Input:** Two boolean arguments
- **Output:** True if at least one argument is true, false otherwise
- **Evaluation:** Strict (eager) - both operands are always evaluated
- **Purity:** Pure
- **Example:**

```
true | false  // returns true
false | true  // returns true (both operands evaluated)
```

### Not

- **Symbols:** `!`, `not`
- **Input:** One boolean argument
- **Output:** True if argument is false; false if argument is true
- **Purity:** Pure
- **Example:**

```
!true    // returns false
not true // returns false
```
