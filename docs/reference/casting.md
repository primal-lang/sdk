# Casting

Number of functions: 22

## Conversion Functions

### To Number

- **Signature:** `to.number(a: Any): Number`
- **Input:** One argument of any type
- **Output:** The argument converted to a number
- **Purity:** Pure
- **Example:**

```
to.number("42") // returns 42
```

### To Integer

- **Signature:** `to.integer(a: Any): Number`
- **Input:** One argument of any type
- **Output:** The argument converted to an integer
- **Purity:** Pure
- **Example:**

```
to.integer(3.7) // returns 3
```

### To Decimal

- **Signature:** `to.decimal(a: Any): Number`
- **Input:** One argument of any type
- **Output:** The argument converted to a decimal number
- **Purity:** Pure
- **Example:**

```
to.decimal("3.14") // returns 3.14
```

### To String

- **Signature:** `to.string(a: Any): String`
- **Input:** One argument of any type
- **Output:** The argument converted to a string
- **Purity:** Pure
- **Example:**

```
to.string(42) // returns "42"
```

### To Boolean

- **Signature:** `to.boolean(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** The argument converted to a boolean
- **Purity:** Pure
- **Example:**

```
to.boolean(1) // returns true
```

### To List

- **Signature:** `to.list(a: Any): List`
- **Input:** One set, vector, stack, or queue
- **Output:** The argument converted to a list
- **Purity:** Pure
- **Example:**

```
to.list(set.new([1, 2, 3])) // returns [1, 2, 3]
```

## Type Checking Functions

### Is Number

- **Signature:** `is.number(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a number, false otherwise
- **Purity:** Pure
- **Example:**

```
is.number(42) // returns true
```

### Is Integer

- **Signature:** `is.integer(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is an integer, false otherwise
- **Purity:** Pure
- **Example:**

```
is.integer(3) // returns true
```

### Is Decimal

- **Signature:** `is.decimal(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a decimal number, false otherwise
- **Purity:** Pure
- **Example:**

```
is.decimal(3.14) // returns true
```

### Is Infinite

- **Signature:** `is.infinite(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is infinite, false otherwise
- **Purity:** Pure
- **Example:**

```
is.infinite(num.infinity()) // returns true
```

### Is String

- **Signature:** `is.string(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a string, false otherwise
- **Purity:** Pure
- **Example:**

```
is.string("hello") // returns true
```

### Is Boolean

- **Signature:** `is.boolean(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a boolean, false otherwise
- **Purity:** Pure
- **Example:**

```
is.boolean(true) // returns true
```

### Is Timestamp

- **Signature:** `is.timestamp(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a timestamp, false otherwise
- **Purity:** Pure
- **Example:**

```
is.timestamp(time.now()) // returns true
```

### Is Function

- **Signature:** `is.function(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a function, false otherwise
- **Purity:** Pure
- **Example:**

```
is.function(num.add) // returns true
```

### Is List

- **Signature:** `is.list(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a list, false otherwise
- **Purity:** Pure
- **Example:**

```
is.list([1, 2, 3]) // returns true
```

### Is Map

- **Signature:** `is.map(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a map, false otherwise
- **Purity:** Pure
- **Example:**

```
is.map({"a": 1}) // returns true
```

### Is Vector

- **Signature:** `is.vector(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a vector, false otherwise
- **Purity:** Pure
- **Example:**

```
is.vector(vector.new([1, 2])) // returns true
```

### Is Set

- **Signature:** `is.set(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a set, false otherwise
- **Purity:** Pure
- **Example:**

```
is.set(set.new([1, 2])) // returns true
```

### Is Stack

- **Signature:** `is.stack(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a stack, false otherwise
- **Purity:** Pure
- **Example:**

```
is.stack(stack.new([1, 2])) // returns true
```

### Is Queue

- **Signature:** `is.queue(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a queue, false otherwise
- **Purity:** Pure
- **Example:**

```
is.queue(queue.new([1, 2])) // returns true
```

### Is File

- **Signature:** `is.file(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a file, false otherwise
- **Purity:** Pure
- **Example:**

```
is.file(file.fromPath("data.txt")) // returns true
```

### Is Directory

- **Signature:** `is.directory(a: Any): Boolean`
- **Input:** One argument of any type
- **Output:** True if the argument is a directory, false otherwise
- **Purity:** Pure
- **Example:**

```
is.directory(directory.fromPath("/home/user")) // returns true
```
