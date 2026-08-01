---
title: Dynamic Typing
tags:
  - design
  - typing
sources:
  - lib/compiler/library/casting/
  - lib/compiler/runtime/
---

# Dynamic Typing

**TLDR**: Primal uses dynamic typing with runtime type checking. You write code without type annotations, and types are verified when functions execute.

## No Type Annotations

In Primal, you never write type annotations in your source code. Parameters and return values are not declared with types:

```
// No types needed - just define your function
add(a, b) = a + b

greet(name) = str_concat("Hello, ", name)
```

This keeps the syntax clean and simple, making Primal easy to learn for beginners.

## Runtime Type Checking

While you do not write types, Primal still enforces them. The difference is that type checks happen at runtime when functions are called, not at compile time.

When you call a core function, Primal verifies that arguments match expected types:

```
str_length("hello")  // works: "hello" is a String
str_length(42)       // error: 42 is not a String
```

The `str_length` function expects a String argument. Passing a Number causes a runtime error.

## How Type Errors Appear

Type errors in Primal appear as runtime exceptions with descriptive messages. For example:

```
list_at("hello", 0)
// Error: Expected argument 1 to be List, got String

num_add("1", 2)
// Error: Expected argument 1 to be Number, got String
```

These errors include:

- Which argument was wrong
- What type was expected
- What type was actually received

Since errors only appear at runtime, you might not discover a type mismatch until that particular code path executes.

## Manual Type Checking

For cases where you need to handle multiple types, Primal provides `is_*` functions to check types manually:

```
// Check if a value is a specific type
is_number(42)        // returns true
is_number("42")      // returns false

is_string("hello")   // returns true
is_list([1, 2, 3])   // returns true
is_map({"a": 1})     // returns true
```

You can use these in conditionals to create flexible functions:

```
// A function that handles both numbers and strings
double(x) =
  if (is_number(x))
    x * 2
  else if (is_string(x))
    str_concat(x, x)
  else
    error_throw("type", "Expected number or string")
```

## Handling Potential Errors

Use the `try` function to gracefully handle type errors:

```
// Provide a fallback value if the operation fails
try(num_div(10, 0), 0)  // returns 0 instead of throwing

// Handle potential type mismatches
safeLength(x) = try(str_length(x), 0)
```

## Practical Examples

### Type-Safe Wrapper

Create a wrapper that validates input before processing:

```
parseNumber(input) =
  if (is_string(input))
    to_number(input)
  else if (is_number(input))
    input
  else
    error_throw("type", "Cannot parse to number")
```

### Processing Mixed Data

When working with data that might have different types:

```
stringify(value) =
  if (is_list(value))
    list_join(list_map(value, to_string), ", ")
  else
    to_string(value)
```

### Defensive Programming

Check types before operations that might fail:

```
safeDivide(a, b) =
  if (!is_number(a) || !is_number(b))
    error_throw("type", "Both arguments must be numbers")
  else if (b == 0)
    error_throw("math", "Cannot divide by zero")
  else
    a / b
```

## Trade-offs

Dynamic typing in Primal offers:

**Advantages:**

- Simpler syntax with no type annotations
- Faster prototyping and experimentation
- More flexible function signatures

**Considerations:**

- Type errors appear at runtime rather than compile time
- Testing becomes more important to catch type mismatches
- Use `is_*` functions for explicit type validation when needed

For more information on available types, see [[lang/design/type-hierarchy]].
