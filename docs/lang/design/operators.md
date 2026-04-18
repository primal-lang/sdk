---
title: Operators
tags: [design, operators]
sources: []
---

# Operators

**TLDR**: Primal provides infix operators for arithmetic, comparison, logical operations, and collection access. All operators desugar to function calls, and logical operators support short-circuit evaluation.

## Operators as Function Calls

Every operator in Primal is syntactic sugar for a function call. When the compiler sees an operator expression, it transforms it into the corresponding function invocation:

| Expression | Desugars To                              |
| ---------- | ---------------------------------------- |
| `a + b`    | `num.add(a, b)` or `string.concat(a, b)` |
| `a - b`    | `num.sub(a, b)`                          |
| `a * b`    | `num.mul(a, b)`                          |
| `a / b`    | `num.div(a, b)`                          |
| `a % b`    | `num.mod(a, b)`                          |
| `a == b`   | `compare.eq(a, b)`                       |
| `a != b`   | `compare.neq(a, b)`                      |
| `a > b`    | `compare.gt(a, b)`                       |
| `a < b`    | `compare.lt(a, b)`                       |
| `a >= b`   | `compare.gte(a, b)`                      |
| `a <= b`   | `compare.lte(a, b)`                      |

This design keeps the language simple: operators are just convenient syntax, not special constructs.

## Arithmetic Operators

### Addition: `+`

Adds numbers or concatenates strings and collections:

```
3 + 4              // returns 7
"Hello, " + "world" // returns "Hello, world"
[1, 2] + [3, 4]    // returns [1, 2, 3, 4]
```

### Subtraction: `-`

Subtracts numbers or removes elements from sets:

```
10 - 3             // returns 7
{1, 2, 3} - {2}    // returns {1, 3}
```

### Multiplication: `*`

Multiplies two numbers:

```
3 * 4              // returns 12
2.5 * 4            // returns 10
```

### Division: `/`

Divides two numbers. Throws `DivisionByZeroError` if the divisor is zero:

```
10 / 2             // returns 5
7 / 2              // returns 3.5
10 / 0             // throws DivisionByZeroError
```

### Modulo: `%`

Returns the remainder after division. Throws `DivisionByZeroError` if the divisor is zero:

```
10 % 3             // returns 1
15 % 5             // returns 0
10 % 0             // throws DivisionByZeroError
```

## Comparison Operators

All comparison operators return a Boolean value.

### Equality: `==` and `!=`

Test whether two values are equal or not equal:

```
5 == 5             // returns true
5 != 3             // returns true
"abc" == "abc"     // returns true
[1, 2] == [1, 2]   // returns true (element-wise comparison)
```

### Ordering: `<`, `>`, `<=`, `>=`

Compare values for ordering:

```
3 < 5              // returns true
5 > 3              // returns true
5 <= 5             // returns true
5 >= 5             // returns true
"apple" < "banana" // returns true (lexicographic)
```

## Logical Operators

### And: `&&` (Short-Circuit)

Returns `true` only if both operands are `true`. The second operand is evaluated only if the first is `true`:

```
true && true       // returns true
true && false      // returns false
false && expensive() // returns false (expensive() not called)
```

The keyword `and` is an alias for `&&`:

```
true and false     // returns false
```

### Or: `||` (Short-Circuit)

Returns `true` if at least one operand is `true`. The second operand is evaluated only if the first is `false`:

```
true || false      // returns true
false || true      // returns true
true || expensive() // returns true (expensive() not called)
```

The keyword `or` is an alias for `||`:

```
false or true      // returns true
```

### Not: `!`

Negates a Boolean value:

```
!true              // returns false
!false             // returns true
!(5 > 3)           // returns false
```

The keyword `not` is an alias for `!`:

```
not true           // returns false
```

### Strict Evaluation: `&` and `|`

For cases where you need both operands evaluated regardless of the first result, use the strict variants:

```
true & false       // returns false (both evaluated)
false | true       // returns true (both evaluated)
```

## Collection Indexing: `[]`

Access elements in lists and maps using bracket notation:

### List Indexing

```
[10, 20, 30][0]    // returns 10
[10, 20, 30][1]    // returns 20
["a", "b", "c"][2] // returns "c"
```

Indices are zero-based. Accessing an out-of-bounds index throws an error.

### Map Access

```
{"name": "Alice", "age": 30}["name"]  // returns "Alice"
{"x": 1, "y": 2}["y"]                 // returns 2
```

Accessing a non-existent key throws an error. Use `map.get` with a default value for safe access.

## Operator Precedence

Operators follow standard mathematical precedence (highest to lowest):

1. `!`, `not` (unary negation)
2. `*`, `/`, `%` (multiplicative)
3. `+`, `-` (additive)
4. `<`, `>`, `<=`, `>=` (relational)
5. `==`, `!=` (equality)
6. `&&`, `and` (logical and)
7. `||`, `or` (logical or)

Use parentheses to override precedence:

```
2 + 3 * 4          // returns 14 (multiplication first)
(2 + 3) * 4        // returns 20 (addition first)
true || false && false   // returns true (&& binds tighter)
(true || false) && false // returns false
```

## Practical Examples

### Arithmetic Expressions

```
// Calculate total price with tax
totalPrice(price, quantity, taxRate) =
  let subtotal = price * quantity,
      tax = subtotal * taxRate
  in subtotal + tax

// Compute average
average(numbers) =
  list.reduce(numbers, 0, num.add) / list.length(numbers)
```

### Conditional Logic

```
// Check if a number is in range
inRange(value, minimum, maximum) =
  value >= minimum && value <= maximum

// Validate user input
isValidAge(age) =
  age >= 0 && age <= 150

// Check multiple conditions
canVote(age, isCitizen, isRegistered) =
  age >= 18 && isCitizen && isRegistered
```

### Short-Circuit Patterns

```
// Safe division using short-circuit
safeDivide(a, b) =
  if (b != 0 && a / b > 0) a / b else 0

// Default value pattern
getOrDefault(maybeValue, default) =
  if (maybeValue != null) maybeValue else default

// Guard against empty list
firstOrZero(numbers) =
  if (list.isNotEmpty(numbers)) list.first(numbers) else 0
```

### String Operations

```
// Build a greeting
greet(firstName, lastName) =
  "Hello, " + firstName + " " + lastName + "!"

// Create a formatted message
formatCount(count, singular, plural) =
  let noun = if (count == 1) singular else plural
  in string.toString(count) + " " + noun
```

### Collection Access

```
// Get first element safely
getFirst(items) =
  if (list.length(items) > 0) items[0] else null

// Look up a value in a map
lookup(data, key, default) =
  if (map.containsKey(data, key)) data[key] else default

// Process nested data
getName(user) = user["profile"]["name"]
```
