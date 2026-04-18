---
title: Function Definitions
tags: [design, functions]
sources:
  - lib/compiler/syntactic/function_definition.dart
---

# Function Definitions

**TLDR**: Functions in Primal are defined with a name, optional parameters, and a body expression. The body is a single expression that produces the function's result.

## Anatomy of a Function

Every function definition follows the pattern:

```
name(parameters) = body
```

Where:

- **name** identifies the function and must match the pattern `[a-zA-Z][\w.]*`
- **parameters** is a comma-separated list of parameter names (can be empty)
- **body** is a single expression that produces the result

## Naming Rules

Function names must:

- Start with a letter (uppercase or lowercase)
- Contain only letters, digits, underscores, or dots
- Match the regular expression `[a-zA-Z][\w.]*`

Parameter names follow the same pattern.

Valid names:

```
add
calculateTotal
user.getName
process2
my_function
```

Invalid names:

```
2fast      // cannot start with a digit
_hidden    // cannot start with underscore
add-nums   // hyphens not allowed
```

## Zero-Parameter Functions

Functions that take no arguments still require empty parentheses in their definition:

```
pi() = 3.14159
greeting() = "Hello, world!"
now() = timestamp.now()
```

To call a zero-parameter function, use empty parentheses:

```
circumference(radius) = 2 * pi() * radius
```

## Single Expression Body

The function body is always a single expression. There are no statements or explicit return keywords. The value of the expression becomes the function's result.

Simple expressions:

```
double(n) = n * 2
square(n) = n * n
```

Conditional expressions:

```
abs(n) = if (n >= 0) n else -n
max(a, b) = if (a > b) a else b
```

Complex expressions using let:

```
hypotenuse(a, b) =
  let squareA = a * a,
      squareB = b * b
  in num.sqrt(squareA + squareB)
```

## The main() Function

The `main` function is special. When present, it serves as the entry point when running a program:

```
main() = "Hello, world!"
```

The `main` function can accept parameters, which receive command-line arguments:

```
main(name) = "Hello, " + name + "!"
```

If no `main` function exists, the interpreter starts in interactive mode (REPL), where you can evaluate expressions directly.

## Recursion

Since Primal has no loops, recursion is the standard way to perform repetitive operations:

```
factorial(n) =
  if (n <= 1) 1
  else n * factorial(n - 1)

fibonacci(n) =
  if (n <= 1) n
  else fibonacci(n - 1) + fibonacci(n - 2)
```

## Practical Examples

### Basic Calculations

```
// Convert Celsius to Fahrenheit
toFahrenheit(celsius) = celsius * 9 / 5 + 32

// Calculate the area of a circle
circleArea(radius) = 3.14159 * radius * radius

// Check if a number is positive
isPositive(n) = n > 0
```

### Working with Lists

```
// Sum all numbers in a list
sum(numbers) = list.reduce(numbers, 0, num.add)

// Double every element
doubleAll(numbers) = list.map(numbers, double)
double(n) = n * 2

// Count even numbers
countEven(numbers) = list.count(numbers, num.isEven)
```

### String Processing

```
// Create a greeting
greet(name) = "Hello, " + name + "!"

// Check if string is empty
isBlank(text) = string.length(text) == 0

// Repeat a string n times
repeat(text, n) =
  if (n <= 0) ""
  else text + repeat(text, n - 1)
```

### Functions as Values

Functions are first-class values and can be passed as arguments or bound to names:

```
// Apply a function twice
applyTwice(function, value) = function(function(value))

// Using with a named function
increment(n) = n + 1
main() = applyTwice(increment, 5) // returns 7

// Binding a core function
sum(numbers) =
  let add = num.add
  in list.reduce(numbers, 0, add)
```
