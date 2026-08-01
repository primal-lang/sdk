---
title: Casting
tags:
  - reference
  - types
sources:
  - lib/compiler/library/casting/
---

# Casting

**TLDR**: Functions for converting values between types and checking runtime types including numbers, strings, booleans, collections, and file system objects.

Number of functions: 23

## Conversion Functions

### To Number

- **Signature:** `to_number(a: Any): Number`
- **Input:** An argument of any type
- **Output:** The argument converted to a number
- **Purity:** Pure
- **Example:**

```
to_number("42") // returns 42
```

### To Integer

- **Signature:** `to_integer(a: Any): Number`
- **Input:** An argument of any type
- **Output:** The argument converted to an integer
- **Purity:** Pure
- **Example:**

```
to_integer(3.7) // returns 3
```

### To Decimal

- **Signature:** `to_decimal(a: Any): Number`
- **Input:** An argument of any type
- **Output:** The argument converted to a decimal number
- **Purity:** Pure
- **Example:**

```
to_decimal("3.14") // returns 3.14
```

### To String

- **Signature:** `to_string(a: Any): String`
- **Input:** An argument of any type
- **Output:** The argument converted to a string
- **Purity:** Pure
- **Example:**

```
to_string(42) // returns "42"
```

### To Boolean

- **Signature:** `to_boolean(a: Any): Boolean`
- **Input:** A string, number, or boolean. Strings convert to true if non-empty after trimming. Numbers convert to true if non-zero. Booleans pass through unchanged. Other types throw an error.
- **Output:** The argument converted to a boolean
- **Purity:** Pure
- **Example:**

```
to_boolean(1) // returns true
```

### To List

- **Signature:** `to_list(a: Any): List`
- **Input:** A set, vector, stack, or queue. Other types throw an error.
- **Output:** The argument converted to a list
- **Purity:** Pure
- **Example:**

```
to_list(set_new([1, 2, 3])) // returns [1, 2, 3]
```

## Type Checking Functions

### Is Number

- **Signature:** `is_number(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a number. False otherwise
- **Purity:** Pure
- **Example:**

```
is_number(42) // returns true
```

### Is Integer

- **Signature:** `is_integer(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is an integer. False otherwise
- **Purity:** Pure
- **Example:**

```
is_integer(3) // returns true
```

### Is Decimal

- **Signature:** `is_decimal(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a decimal number. False otherwise
- **Purity:** Pure
- **Example:**

```
is_decimal(3.14) // returns true
```

### Is Infinite

- **Signature:** `is_infinite(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is infinite. False otherwise
- **Purity:** Pure
- **Example:**

```
is_infinite(num_infinity()) // returns true
```

### Is String

- **Signature:** `is_string(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a string. False otherwise
- **Purity:** Pure
- **Example:**

```
is_string("hello") // returns true
```

### Is Boolean

- **Signature:** `is_boolean(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a boolean. False otherwise
- **Purity:** Pure
- **Example:**

```
is_boolean(true) // returns true
```

### Is Timestamp

- **Signature:** `is_timestamp(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a timestamp. False otherwise
- **Purity:** Pure
- **Example:**

```
is_timestamp(time_now()) // returns true
```

### Is Function

- **Signature:** `is_function(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a function. False otherwise
- **Purity:** Pure
- **Example:**

```
is_function(num_add) // returns true
```

### Is List

- **Signature:** `is_list(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a list. False otherwise
- **Purity:** Pure
- **Example:**

```
is_list([1, 2, 3]) // returns true
```

### Is Map

- **Signature:** `is_map(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a map. False otherwise
- **Purity:** Pure
- **Example:**

```
is_map({"a": 1}) // returns true
```

### Is Vector

- **Signature:** `is_vector(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a vector. False otherwise
- **Purity:** Pure
- **Example:**

```
is_vector(vector_new([1, 2])) // returns true
```

### Is Set

- **Signature:** `is_set(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a set. False otherwise
- **Purity:** Pure
- **Example:**

```
is_set(set_new([1, 2])) // returns true
```

### Is Stack

- **Signature:** `is_stack(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a stack. False otherwise
- **Purity:** Pure
- **Example:**

```
is_stack(stack_new([1, 2])) // returns true
```

### Is Queue

- **Signature:** `is_queue(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a queue. False otherwise
- **Purity:** Pure
- **Example:**

```
is_queue(queue_new([1, 2])) // returns true
```

### Is File

- **Signature:** `is_file(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a file. False otherwise
- **Purity:** Pure
- **Example:**

```
is_file(file_fromPath("data.txt")) // returns true
```

### Is Directory

- **Signature:** `is_directory(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a directory. False otherwise
- **Purity:** Pure
- **Example:**

```
is_directory(directory_fromPath("/home")) // returns true
```

### Is Duration

- **Signature:** `is_duration(a: Any): Boolean`
- **Input:** An argument of any type
- **Output:** True if the argument is a duration. False otherwise
- **Purity:** Pure
- **Example:**

```
is_duration(duration_fromHours(2)) // returns true
```
