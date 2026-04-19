---
title: Let Expressions
tags:
  - design
  - bindings
sources:
  - lib/compiler/syntactic/expression_parser.dart
---

# Let Expressions

**TLDR**: Let expressions introduce local bindings with `let name = value in body`.

## Let Expressions

The `let` expression introduces local bindings that are only visible within its body:

```
let name = expression in body
```

The binding is evaluated first, then the body is evaluated with that binding in scope.

### Basic Usage

```
let x = 5 in x + 1           // returns 6
let name = "Alice" in "Hello, " + name   // returns "Hello, Alice"
```

### Multiple Bindings

You can introduce multiple bindings separated by commas:

```
let a = 1, b = 2 in a + b    // returns 3
```

Bindings are evaluated sequentially, so later bindings can reference earlier ones:

```
let x = 5, y = x + 1 in x + y    // returns 11
let base = 10, doubled = base * 2, tripled = base * 3
in doubled + tripled              // returns 50
```

### Nested Let Expressions

Let expressions can be nested for more complex scoping:

```
let x = 1 in
  let y = x + 1 in
    x + y    // returns 3
```

The inner `y` binding can see the outer `x` binding, but `x` cannot see `y`.

### Binding Functions

You can bind function references to local names:

```
let square = num.mul in square(4, 4)    // returns 16
let add = num.add in list.reduce([1, 2, 3], 0, add)    // returns 6
```

## Scoping Rules

### Visibility

Bindings are only visible within their scope:

```
let x = 10 in x + 1    // x is visible here
// x is not visible outside the let expression
```

### Shadowing

Let bindings can shadow function names from outer scope:

```
double(n) = n * 2

calculate() =
  let double = 100    // shadows the double function
  in double + 1       // returns 101, not a function call
```

However, let bindings **cannot** shadow function parameters:

```
process(x) =
  let x = 10 in x    // Error: cannot shadow parameter x
```

### Call-by-Value

Bindings are evaluated eagerly (call-by-value). The expression is evaluated once when the binding is created, not each time it is referenced:

```
let expensive = computeValue()
in expensive + expensive    // computeValue() is called only once
```

## Practical Examples

### Breaking Down Complex Calculations

```
// Calculate compound interest
compoundInterest(principal, rate, years) =
  let factor = 1 + rate,
      multiplier = num.pow(factor, years)
  in principal * multiplier

// Quadratic formula (positive root)
quadraticRoot(a, b, c) =
  let discriminant = b * b - 4 * a * c,
      sqrtDisc = num.sqrt(discriminant)
  in (-b + sqrtDisc) / (2 * a)
```

### Reusing Intermediate Values

```
// Calculate statistics
stats(numbers) =
  let total = list.reduce(numbers, 0, num.add),
      count = list.length(numbers),
      average = total / count
  in { "sum": total, "count": count, "average": average }
```

### Combining Let and Conditionals

```
// Safe division with default
safeDivide(a, b, default) =
  let result = if (b == 0) default else a / b
  in result

// Classify a number
classify(n) =
  let absValue = num.abs(n),
      isSmall = absValue < 10,
      isMedium = absValue < 100
  in if (isSmall) "small"
     else if (isMedium) "medium"
     else "large"
```
