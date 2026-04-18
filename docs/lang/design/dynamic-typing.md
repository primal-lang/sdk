---
title: Dynamic Typing
tags: [design, typing]
sources: []
---

# Dynamic Typing

**TLDR**: Primal uses dynamic typing with runtime type checking. You write code without type annotations, and types are verified when functions execute.

## No Type Annotations

In Primal, you never write type annotations in your source code. Parameters and return values are not declared with types:

```
// No types needed - just define your function
add(a, b) = a + b

greet(name) = str.concat("Hello, ", name)
```

This keeps the syntax clean and simple, making Primal easy to learn for beginners.

## Runtime Type Checking

While you do not write types, Primal still enforces them. The difference is that type checks happen at runtime when functions are called, not at compile time.

When you call a core function, Primal verifies that arguments match expected types:

```
str.length("hello")  // works: "hello" is a String
str.length(42)       // error: 42 is not a String
```

The `str.length` function expects a String argument. Passing a Number causes a runtime error.

## How Type Errors Appear

Type errors in Primal appear as runtime exceptions with descriptive messages. For example:

```
list.at("hello", 0)
// Error: Expected argument 1 to be List, got String

num.add("1", 2)
// Error: Expected argument 1 to be Number, got String
```

These errors include:

- Which argument was wrong
- What type was expected
- What type was actually received

Since errors only appear at runtime, you might not discover a type mismatch until that particular code path executes.

## Manual Type Checking

For cases where you need to handle multiple types, Primal provides `is.*` functions to check types manually:

```
// Check if a value is a specific type
is.number(42)        // returns true
is.number("42")      // returns false

is.string("hello")   // returns true
is.list([1, 2, 3])   // returns true
is.map({"a": 1})     // returns true
```

You can use these in conditionals to create flexible functions:

```
// A function that handles both numbers and strings
double(x) =
  if (is.number(x))
    x * 2
  else if (is.string(x))
    str.concat(x, x)
  else
    error.throw("type", "Expected number or string")
```

## Handling Potential Errors

Use the `try` function to gracefully handle type errors:

```
// Provide a fallback value if the operation fails
try(num.div(10, 0), 0)  // returns 0 instead of throwing

// Handle potential type mismatches
safeLength(x) = try(str.length(x), 0)
```

## Practical Examples

### Type-Safe Wrapper

Create a wrapper that validates input before processing:

```
parseNumber(input) =
  if (is.string(input))
    to.number(input)
  else if (is.number(input))
    input
  else
    error.throw("type", "Cannot parse to number")
```

### Processing Mixed Data

When working with data that might have different types:

```
stringify(value) =
  if (is.list(value))
    list.join(list.map(value, to.string), ", ")
  else
    to.string(value)
```

### Defensive Programming

Check types before operations that might fail:

```
safeDivide(a, b) =
  if (!is.number(a) || !is.number(b))
    error.throw("type", "Both arguments must be numbers")
  else if (b == 0)
    error.throw("math", "Cannot divide by zero")
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
- Use `is.*` functions for explicit type validation when needed

For more information on available types, see [[lang/design/type-hierarchy]].
