# Operators

## Comparison Operators

### Equality

- **Symbol:** `==`
- **Input:** Two arguments of any type
- **Output:** True if equal, false otherwise
- **Purity:** Pure
- **Example:**

```
5 == 5 // returns true
```

### Inequality

- **Symbol:** `!=`
- **Input:** Two arguments of any type
- **Output:** True if not equal, false otherwise
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
- **Purity:** Pure
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
- **Purity:** Pure
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
- **Purity:** Pure
- **Example:**

```
10 / 2 // returns 5
```

### Modulo

- **Symbol:** `%`
- **Input:** Two numbers
- **Output:** The remainder of division
- **Purity:** Pure
- **Example:**

```
10 % 3 // returns 1
```

## Logical Operators

### And

- **Symbol:** `&`
- **Input:** Two boolean arguments
- **Output:** True only if both arguments are true, false otherwise
- **Purity:** Pure
- **Example:**

```
true & false // returns false
```

### Or

- **Symbol:** `|`
- **Input:** Two boolean arguments
- **Output:** True if at least one argument is true, false otherwise
- **Purity:** Pure
- **Example:**

```
true | false // returns true
```

### Not

- **Symbol:** `!`
- **Input:** One boolean argument
- **Output:** True if argument is false; false if argument is true
- **Purity:** Pure
- **Example:**

```
!true // returns false
```
