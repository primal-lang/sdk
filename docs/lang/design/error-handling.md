---
title: Error Handling
tags:
  - design
  - error-handling
sources:
  - lib/compiler/library/error/
  - lib/compiler/library/control/
---

# Error Handling

**TLDR**: Primal provides a simple yet effective error handling model using `error_throw` to raise errors and `try` to catch them, enabling you to write robust code that gracefully handles failure cases.

## Overview

In Primal, errors are values that can be thrown and caught. Unlike exceptions in some languages, Primal's error handling is expression-based, meaning error handling constructs return values and can be used anywhere an expression is expected.

The error handling model consists of two core mechanisms:

- **Throwing errors** with `error_throw(code, message)`
- **Catching errors** with `try(expression, fallback)`

## Throwing Errors

Use `error_throw` to raise an error with a custom code and message:

```
error_throw(code, message)
```

The code can be any value (commonly a number or string), and the message should be a descriptive string explaining what went wrong.

### Examples

```
// Throwing a simple error
error_throw(404, "Resource not found")

// Using error codes for different scenarios
validateAge(age) =
  if (age < 0) error_throw("INVALID_AGE", "Age cannot be negative")
  else if (age > 150) error_throw("INVALID_AGE", "Age is unrealistically high")
  else age
```

## Catching Errors

Use `try` to catch errors and provide a fallback value:

```
try(expression, fallback)
```

If the expression evaluates successfully, its result is returned. If the expression throws an error, the fallback value is returned instead.

### Examples

```
// Catching a division by zero error
try(num_div(10, 0), 0) // returns 0

// Providing a default value when parsing fails
try(json_decode(input), {})

// Safe list access with a default
safeGet(items, index) = try(list_at(items, index), "not found")
```

## Built-in Error Types

Many core functions throw errors when given invalid input. Here are common scenarios where errors occur:

### Arithmetic Errors

| Operation           | Error Condition                                          |
| ------------------- | -------------------------------------------------------- |
| `num_div(a, b)`     | Division by zero                                         |
| `num_mod(a, b)`     | Division by zero                                         |
| `num_sqrt(a)`       | Negative number                                          |
| `num_pow(a, b)`     | Negative base with fractional exponent, or overflow      |
| `num_log(a)`        | Non-positive number                                      |
| `num_logBase(a, b)` | Non-positive number, non-positive base, or base equals 1 |

### Collection Errors

| Operation                        | Error Condition                 |
| -------------------------------- | ------------------------------- |
| `list_at(list, index)`           | Index out of bounds or negative |
| `list_first(list)`               | Empty list                      |
| `list_last(list)`                | Empty list                      |
| `list_sublist(list, start, end)` | Invalid indices                 |
| `list_chunk(list, size)`         | Size is zero or negative        |
| `map_at(map, key)`               | Key not found                   |
| `stack_pop(stack)`               | Empty stack                     |
| `stack_peek(stack)`              | Empty stack                     |
| `queue_dequeue(queue)`           | Empty queue                     |
| `queue_peek(queue)`              | Empty queue                     |

### Vector Errors

| Operation             | Error Condition                                     |
| --------------------- | --------------------------------------------------- |
| `vector_new(list)`    | List contains non-numeric elements                  |
| `vector_add(a, b)`    | Vectors have different lengths                      |
| `vector_normalize(v)` | Zero magnitude                                      |
| `vector_angle(a, b)`  | Different lengths, empty vectors, or zero magnitude |

## Best Practices

### Use Descriptive Error Messages

Error messages should clearly explain what went wrong and, when possible, suggest how to fix the issue:

```
// Good: Descriptive message
error_throw("INVALID_EMAIL", "Email must contain an @ symbol")

// Avoid: Vague message
error_throw(1, "error")
```

### Use Consistent Error Codes

Choose a consistent format for error codes throughout your program. Common approaches include:

- **String codes**: `"INVALID_INPUT"`, `"NOT_FOUND"`, `"PERMISSION_DENIED"`
- **Numeric codes**: `400`, `404`, `500` (HTTP-style)

```
// Define error codes as functions for consistency
errorNotFound() = error_throw("NOT_FOUND", "The requested item was not found")
errorInvalidInput(field) = error_throw("INVALID_INPUT", str_concat("Invalid value for: ", field))
```

### Validate Early

Check inputs at the beginning of your functions to catch errors early:

```
calculateDiscount(price, percentage) =
  if (price < 0) error_throw("INVALID_PRICE", "Price cannot be negative")
  else if (percentage < 0) error_throw("INVALID_PERCENTAGE", "Percentage cannot be negative")
  else if (percentage > 100) error_throw("INVALID_PERCENTAGE", "Percentage cannot exceed 100")
  else price * (1 - percentage / 100)
```

### Provide Sensible Defaults

When catching errors, choose fallback values that make sense for your use case:

```
// Return an empty list when the source might fail
safeParse(jsonString) = try(json_decode(jsonString), [])

// Return a neutral value for numeric operations
safeSquareRoot(n) = try(num_sqrt(n), 0)
```

### Chain Operations Safely

When performing multiple operations that might fail, use nested `try` expressions or validate step by step:

```
// Process user data with multiple potential failure points
processUser(userData) =
  let parsed = try(json_decode(userData), {})
  in let name = try(map_at(parsed, "name"), "Anonymous")
  in let age = try(map_at(parsed, "age"), 0)
  in {"name": name, "age": age}
```

## Practical Examples

### Safe Division Function

```
safeDivide(a, b) = try(num_div(a, b), 0)

main() = safeDivide(10, 0) // returns 0 instead of throwing an error
```

### Input Validation

```
validateUsername(username) =
  if (str_length(username) < 3)
    error_throw("USERNAME_TOO_SHORT", "Username must be at least 3 characters")
  else if (str_length(username) > 20)
    error_throw("USERNAME_TOO_LONG", "Username cannot exceed 20 characters")
  else
    username

createUser(username) =
  let validName = try(validateUsername(username), "default_user")
  in {"username": validName}
```

### Processing a List with Error Recovery

```
// Parse each item, using a default if parsing fails
parseItems(items) =
  list_map(items, (item) => try(json_decode(item), {}))

// Filter out items that would cause errors
safeFilter(items) =
  list_filter(items, (item) => try(let check = list_at(item, 0) in true, false))
```

### Configuration Loading

```
loadConfig(path) =
  let content = try(file_read(path), "{}")
  in let config = try(json_decode(content), {})
  in let port = try(map_at(config, "port"), 8080)
  in let host = try(map_at(config, "host"), "localhost")
  in {"port": port, "host": host}
```

## See Also

- [[lang/reference/core/error]] - Error function reference
- [[lang/reference/core/control]] - Control flow including `try`
