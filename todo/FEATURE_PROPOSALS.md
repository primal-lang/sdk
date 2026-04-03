# Feature Proposals for Primal

This document contains proposed new features for the Primal language, based on analysis of the current implementation and documentation.

---

## 1. Function Composition Operator

Compose functions with `>>` (left-to-right) or `<<` (right-to-left):

```
double(x) = x * 2
square(x) = x * x
doubleSquare = double >> square  // first double, then square
main = doubleSquare(3)           // returns 36
```

**Rationale:** Fits naturally with functional programming paradigm. Reduces need for intermediate variables and makes data flow explicit.

---

## 2. Partial Application

Apply some arguments now, get a function expecting the rest:

```
add(a, b) = a + b
addFive = add(5, _)    // _ is placeholder
main = addFive(3)      // returns 8
```

**Rationale:** Enables point-free style and better reuse of existing functions with higher-order functions like `map` and `filter`.

---

## 3. Where Clauses

Local definitions after the main expression (Haskell-style):

```
circleArea(r) = pi * r * r where
  pi = 3.14159

quadratic(a, b, c) = (root1, root2) where
  discriminant = b * b - 4 * a * c
  root1 = (-b + num.sqrt(discriminant)) / (2 * a)
  root2 = (-b - num.sqrt(discriminant)) / (2 * a)
```

**Rationale:** Allows defining helper values/functions without polluting global scope. More readable than deeply nested expressions.

---

## 4. Guards in Function Definitions

Multiple conditional bodies for one function:

```
abs(n)
  | n >= 0 = n
  | else   = -n

grade(score)
  | score >= 90 = "A"
  | score >= 80 = "B"
  | score >= 70 = "C"
  | score >= 60 = "D"
  | else        = "F"
```

**Rationale:** Cleaner alternative to nested if-else chains. Common in functional languages and improves readability.

---

## 5. List Comprehensions

Declarative list construction:

```
squares = [x * x | x <- [1, 2, 3, 4, 5]]           // [1, 4, 9, 16, 25]
evens = [x | x <- list.range(1, 10), num.isEven(x)] // [2, 4, 6, 8, 10]
pairs = [(x, y) | x <- [1, 2], y <- ["a", "b"]]    // [(1,"a"), (1,"b"), (2,"a"), (2,"b")]
```

**Rationale:** Concise syntax for common list operations. Combines mapping and filtering in readable form.

---

## 6. Tuples

Fixed-size heterogeneous collections:

```
point = (3, 4)
person = ("Alice", 30, true)
x = tuple.first(point)       // 3
name = tuple.at(person, 0)   // "Alice"
(a, b) = point               // destructuring
```

**Rationale:** Lightweight alternative to maps for fixed structures. Useful for returning multiple values from functions.

---

## 7. Symbols (Atoms)

Lightweight unique identifiers (like Ruby/Elixir):

```
status = :pending
result = if (status == :pending) "waiting" else "done"

// Useful for map keys
config = { :host: "localhost", :port: 8080 }
```

**Rationale:** More efficient than strings for identifiers that are compared frequently. Self-documenting code.

---

## 8. Regular Expression Literals

First-class regex syntax:

```
pattern = /[a-z]+\d+/
matched = regex.match("hello123", pattern)   // true
groups = regex.find("abc123def456", /\d+/)   // ["123", "456"]
replaced = regex.replace("hello123", /\d+/, "XXX")  // "helloXXX"
```

**Rationale:** Currently `str.match` exists but requires string patterns. Literal syntax is clearer and allows compile-time validation.

---

## 9. Binary, Hex, and Octal Number Literals

```
binary = 0b1010      // 10
hex = 0xFF           // 255
octal = 0o77         // 63
```

**Rationale:** Common in programming for bit manipulation, colors, permissions. Easy to implement in lexer.

---

## 10. Default Parameter Values

```
greet(name, greeting = "Hello") = greeting + ", " + name
main = greet("Alice")                  // "Hello, Alice"
alt = greet("Alice", "Hi")             // "Hi, Alice"

range(start, end, step = 1) = ...
```

**Rationale:** Reduces need for function overloading. Makes APIs more flexible without breaking existing code.

---

## 11. Named Arguments

```
createUser(name, age, active) = { "name": name, "age": age, "active": active }
user = createUser(age: 30, name: "Bob", active: true)
```

**Rationale:** Improves readability at call sites. Allows arguments in any order when named.

---

## 12. Memoization Annotation

Automatic caching of pure function results:

```
@memo
fib(n) = if (n <= 1) n else fib(n - 1) + fib(n - 2)
main = fib(50)   // now fast!

@memo(maxSize: 100)
expensiveCalc(x) = ...
```

**Rationale:** Common optimization for recursive functions. Primal's immutability makes memoization safe.

---

## 13. Sequence / Do Expressions

Execute expressions in order (for side effects):

```
main = do
  console.writeLn("Enter name:")
  name = console.read()
  console.writeLn("Hello, " + name)
  name
end
```

**Rationale:** Provides imperative-style sequencing while maintaining expression orientation. Essential for I/O operations.

---

## 14. Lazy Sequences / Generators

Infinite or on-demand sequences:

```
naturals = lazy.iterate(0, num.inc)      // 0, 1, 2, 3, ...
fibs = lazy.unfold((0, 1), (a, b) => (a, (b, a + b)))
first10 = lazy.take(naturals, 10)        // [0, 1, 2, ..., 9]
```

**Rationale:** Fits with Primal's lazy evaluation model. Enables working with infinite data structures.

---

## 15. Record Types

Named field structures:

```
record Person(name: String, age: Number)

alice = Person("Alice", 30)
name = alice.name              // "Alice"
older = alice with { age: 31 } // functional update
```

**Rationale:** Type-safe alternative to maps. Self-documenting structure with named fields.

---

## 16. Short-Circuit Operators

`&&` and `||` that don't evaluate second argument if unnecessary:

```
result = x != 0 && (10 / x > 2)   // safe, won't divide if x is 0
value = maybeNull || defaultValue  // returns defaultValue if maybeNull is falsy
```

**Rationale:** Current `&` and `|` evaluate both sides. Short-circuit versions are essential for safe conditional logic.

---

## 17. Assert / Contract Expressions

For debugging and documentation:

```
sqrt(n) =
  assert(n >= 0, "sqrt requires non-negative input")
  num.sqrt(n)

// Or as preconditions
divide(a, b)
  requires b != 0
  = a / b
```

**Rationale:** Helps catch bugs early. Documents function expectations. Can be disabled in production.

---

## 18. User-Defined Infix Operators

```
(a <+> b) = list.concat(a, b)
combined = [1, 2] <+> [3, 4]   // [1, 2, 3, 4]

(a |> f) = f(a)                // pipeline operator
result = 5 |> double |> square // 100
```

**Rationale:** Allows domain-specific syntax. Enables pipeline operator without special-casing.

---

## 19. Multiline / Raw Strings

```
query = """
  SELECT * FROM users
  WHERE age > 18
"""

path = r"C:\Users\name"        // no escape processing
regex = r"\d+\.\d+"            // easier regex patterns
```

**Rationale:** Improves readability for long strings. Raw strings simplify regex and file paths.

---

## 20. Doc Comments

```
/// Calculates the factorial of n.
/// @param n A non-negative integer
/// @returns n!
/// @example factorial(5) // returns 120
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)
```

**Rationale:** Enables automatic documentation generation. Improves code understanding in REPL.

---

## 21. Tail Call Optimization

Optimize recursive calls in tail position to prevent stack overflow:

```
// With TCO, this won't overflow for large n
factorial(n) = factorialHelper(n, 1) where
  factorialHelper(n, acc) = if (n <= 1) acc else factorialHelper(n - 1, n * acc)
```

**Rationale:** Critical for a language that uses recursion instead of loops. Enables practical recursive algorithms.

---

## 22. Maybe/Option Type

Handle absence of values safely:

```
safeDivide(a, b) = if (b == 0) none else some(a / b)

result = safeDivide(10, 2)     // some(5)
empty = safeDivide(10, 0)      // none

// Pattern matching with maybe
value = match result
  | some(x) => x
  | none    => 0
```

**Rationale:** Safer alternative to null/undefined. Makes potential absence explicit in types.

---

## 23. Bitwise Operators

```
a = 5 band 3      // bitwise AND: 1
b = 5 bor 3       // bitwise OR: 7
c = 5 bxor 3      // bitwise XOR: 6
d = bnot 5        // bitwise NOT: -6
e = 5 << 2        // left shift: 20
f = 20 >> 2       // right shift: 5
```

**Rationale:** Essential for low-level operations, flags, and algorithms. Common in most languages.

---

## 24. Type Aliases

Create named aliases for complex types:

```
type Point = (Number, Number)
type Handler = Function  // Function that handles events
type UserMap = Map       // Map with string keys and user values

origin: Point = (0, 0)
```

**Rationale:** Improves documentation. Makes complex types more readable.

---

## 25. Module-Level Constants

Special syntax for compile-time constants:

```
const PI = 3.14159265359
const MAX_SIZE = 1000
const APP_NAME = "MyApp"
```

**Rationale:** Documents intent that value should never change. Potential for compile-time optimization.

---

## Implementation Complexity Estimates

| Feature | Complexity | Impact |
|---------|------------|--------|
| Binary/Hex/Octal literals | Low | Medium |
| Multiline strings | Low | Medium |
| Short-circuit operators | Low | High |
| Default parameters | Medium | High |
| Where clauses | Medium | High |
| Guards | Medium | High |
| Tuples | Medium | Medium |
| Composition operator | Medium | Medium |
| Partial application | Medium | High |
| Named arguments | Medium | Medium |
| Doc comments | Medium | Medium |
| Symbols/Atoms | Medium | Low |
| Regex literals | Medium | Medium |
| List comprehensions | High | High |
| Record types | High | High |
| Memoization | High | Medium |
| TCO | High | High |
| Maybe/Option | High | High |
| Do expressions | High | High |
| Lazy sequences | High | Medium |
| User-defined operators | High | Low |

---

## Questions for Consideration

1. Which features align best with Primal's educational goals?
2. Should the focus be on features that are simpler to implement first?
3. Are there any features that would conflict with existing syntax?
4. What is the priority order for implementation?
