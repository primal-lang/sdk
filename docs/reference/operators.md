# Operators

## Comparison Operators

### Equality

- **Symbol:** `==`
- **Input:** Two arguments of any type
- **Output:** True if equal, false otherwise
- **Example:**

```
5 == 5 // returns true
```

### Inequality

- **Symbol:** `!=`
- **Input:** Two arguments of any type
- **Output:** True if not equal, false otherwise
- **Example:**

```
5 != 3 // returns true
```

### Greater Than

- **Symbol:** `>`
- **Input:** Two numbers
- **Output:** True if first number exceeds the second, false otherwise
- **Example:**

```
5 > 3 // returns true
```

### Less Than

- **Symbol:** `<`
- **Input:** Two numbers
- **Output:** True if first number is less than second, false otherwise
- **Example:**

```
3 < 5 // returns true
```

### Greater Than or Equal

- **Symbol:** `>=`
- **Input:** Two numbers
- **Output:** True if first number is greater than or equal to second, false otherwise
- **Example:**

```
5 >= 5 // returns true
```

### Less Than or Equal

- **Symbol:** `<=`
- **Input:** Two numbers
- **Output:** True if first number is less than or equal to second, false otherwise
- **Example:**

```
3 <= 5 // returns true
```

## Arithmetic Operators

### Addition

- **Symbol:** `+`
- **Input:** Two numbers
- **Output:** The sum of the numbers
- **Supported combinations:**
  - `Number + Number`
  - `String + String`
  - `Vector + Vector`
  - `Any + List`
  - `List + Any`
  - `List + List`
  - `Set + Set` (union)
  - `Set + Any` (add element)
  - `Any + Set` (add element)
- **Example:**

```
3 + 4 // returns 7
```

### Subtraction

- **Symbol:** `-`
- **Input:** Two numbers
- **Output:** The difference of the numbers
- **Supported combinations:**
  - `Number - Number`
  - `Vector - Vector`
  - `Set - Any` (remove element)
  - `Any - Set` (remove element)
- **Example:**

```
10 - 3 // returns 7
```

### Negation

- **Symbol:** `-`
- **Input:** One number
- **Output:** The negated number
- **Example:**

```
-5 // returns -5
```

### Multiplication

- **Symbol:** `*`
- **Input:** Two numbers
- **Output:** The product of the numbers
- **Example:**

```
3 * 4 // returns 12
```

### Division

- **Symbol:** `/`
- **Input:** Two numbers
- **Output:** The quotient
- **Example:**

```
10 / 2 // returns 5
```

### Modulo

- **Symbol:** `%`
- **Input:** Two numbers
- **Output:** The remainder of division
- **Example:**

```
10 % 3 // returns 1
```

## Logical Operators

### And

- **Symbol:** `&`
- **Input:** Two boolean arguments
- **Output:** True only if both arguments are true, false otherwise
- **Example:**

```
true & false // returns false
```

### Or

- **Symbol:** `|`
- **Input:** Two boolean arguments
- **Output:** True if at least one argument is true, false otherwise
- **Example:**

```
true | false // returns true
```

### Not

- **Symbol:** `!`
- **Input:** One boolean argument
- **Output:** True if argument is false; false if argument is true
- **Example:**

```
!true // returns false
```
