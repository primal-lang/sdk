## Table of Contents

7. [Syntax Sugar & Ergonomics](#syntax-sugar--ergonomics)
   - [Case Expressions](#40-case-expressions)
   - [When Expressions](#41-when-expressions)
   - [With Expressions](#42-with-expressions)
   - [Placeholder Arguments](#43-placeholder-arguments)
   - [Method Chaining Syntax](#44-method-chaining-syntax)
   - [From-End Indexing](#49-from-end-indexing)
   - [Native Set / Vector Literal Syntax](#50-native-set--vector-literal-syntax)

---

### 40. Case Expressions

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
Multi-way conditional expressions that are more readable than deeply nested `if ... else ...` chains. This proposal has a very attractive MVP because the simplest form can desugar directly to nested `if` calls.

**Proposed Syntax:**

```primal
// Condition-only form
grade(score) = case
  | score >= 90 -> "A"
  | score >= 80 -> "B"
  | score >= 70 -> "C"
  | else -> "F"

// Subject form
describe(n) = case n of
  | 0 -> "zero"
  | 1 -> "one"
  | 2 -> "two"
  | _ -> "many"

// Another condition-only example
classify(x, y) = case
  | x == 0 & y == 0 -> "origin"
  | x == 0          -> "y-axis"
  | y == 0          -> "x-axis"
  | x > 0 & y > 0 -> "quadrant I"
  | else          -> "other"

// Future-friendly tagged-data form
parseResult(r) = case r of
  | [#ok, value] -> value
  | [#error, _] -> defaultValue
  | _ -> defaultValue
```

**Use Cases:**

- Replacing nested if-else
- State machines
- Input classification
- Readable conditionals

**Implementation Notes:**

- The condition-only form can desugar directly to nested `if(condition) then else ...`.
- The `case value of` form can start as chained equality tests before full pattern matching exists.
- Default arms should use `_` or `else`; they should be required unless the compiler can prove exhaustiveness.
- Destructuring and real pattern matching should be treated as a second phase, not part of the MVP.

---

### 41. When Expressions

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Conditional expression for when you only care about the true case (like Ruby's unless/when).

**Proposed Syntax:**

```primal
// when: execute if condition true, return nothing otherwise
when(condition, value)

// Usage
result = when(score > 90, "Excellent!")
// If score > 90: "Excellent!"
// Otherwise: nothing (or unit)

// unless: opposite of when
unless(condition, value)
result = unless(list.isEmpty(lst), list.first(lst))

// when with multiple conditions
result = when {
  | score > 90 -> "A"
  | score > 80 -> "B"
}
// Returns first matching, or nothing

// when-let: bind and check
whenLet(maybeValue, (v) -> process(v))
// If maybeValue is some(x), calls process(x)
// If nothing, returns nothing

// Example
result = whenLet(map.get(data, "name"), (name) ->
  "Hello, " + name
)

// unless-let
unlessLet(errorValue, (e) -> logError(e))

// when-some (for multiple optionals)
result = whenSome(
  [map.get(m, "x"), map.get(m, "y")],
  ([x, y]) -> x + y
)
// Only executes if all are some

// when in pipeline
data
  |> process
  |> when(condition, transform)
  |> finalize
```

**Use Cases:**

- Optional execution
- Null checks
- Conditional transformation
- Guard clauses

**Implementation Notes:**

- Simple desugaring
- Works with Maybe/Option type
- Pipeline friendly

---

### 42. With Expressions

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
Local sequential bindings inside an expression. This is one of the most useful missing pieces in an expression-oriented language because it removes repetition without forcing helper values into the global namespace.

**Proposed Syntax:**

```primal
// Basic with expression
result = with {
  x = 10
  y = 20
  z = x + y
} in x * y * z

// With for computed temporary values
quadraticRoots(a, b, c) = with {
  discriminant = b * b - 4 * a * c
  sqrtD = num.sqrt(discriminant)
  denom = 2 * a
} in [(-b + sqrtD) / denom, (-b - sqrtD) / denom]

distance2D(point) = with {
  x = point[0]
  y = point[1]
} in num.sqrt(x * x + y * y)
```

**Use Cases:**

- Complex calculations with intermediates
- Avoiding repeated expressions
- Keeping helper names out of the global scope
- Readable complex expressions

**Implementation Notes:**

- The MVP should support sequential value bindings only.
- Each binding is visible to later bindings and to the final body.
- This is not just parser sugar in the current compiler; it needs an internal local-binding form or an equivalent semantic transformation.
- Local helper functions and destructuring can be layered on later, but the first version should stay small and predictable.

---

### 43. Placeholder Arguments

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
A compact shorthand for anonymous functions. This is excellent syntax once Primal has anonymous functions or an equivalent internal lambda form, but it should be treated as sugar rather than a standalone feature.

**Proposed Syntax:**

```primal
list.map(numbers, _ + 1)
list.filter(numbers, num.isEven(_))

list.reduce(numbers, 0, _1 + _2)
list.sort(names, str.compare(_1, _2))
list.zip(as, bs, [_1, _2])

// Multiple uses of same placeholder = same argument
list.map(numbers, _ * _)                  // x -> x * x

// Explicit argument positions for multi-argument cases
list.reduce(numbers, 1, _1 * _2)
```

**Use Cases:**

- Concise lambdas
- Point-free style
- Readable transformations
- Quick predicates

**Implementation Notes:**

- `_` creates a single-argument anonymous function; `_1`, `_2`, ... create explicit positional arguments.
- Placeholder scope should be the smallest enclosing placeholder expression.
- This proposal is best shipped after anonymous functions; otherwise it becomes a one-off syntax feature with no general lambda model.
- The parser should reject ambiguous cases rather than guessing what the user meant.

---

### 44. Method Chaining Syntax

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
Fluent call chains can make transformation pipelines easier to read, but this feature is less trivial in Primal than it first appears. The current language already uses dots inside identifiers (`list.map`, `str.uppercase`), so `x.f(y)` is not just a small parser rewrite.

**Proposed Syntax:**

```primal
numbers.filter(isEven).map(double)

result = numbers
  .filter(num.isEven)
  .map(num.inc)
  .take(10)

// Standard-library aliases
"hello".uppercase()                       // str.uppercase("hello")
"hello".length()                          // str.length("hello")
42.abs()                                  // num.abs(42)
[1, 2, 3].reverse()                       // list.reverse([1, 2, 3])

// Mixed style
list.map(numbers, double)                 // traditional
numbers.map(double)                       // chained
```

**Use Cases:**

- Data transformation pipelines
- Fluent interfaces
- More linear reading order
- Lower cognitive load for nested calls

**Implementation Notes:**

- This requires either:
  - removing `.` from ordinary identifiers and introducing real postfix access parsing, or
  - special parser logic that distinguishes `list.map` as a single identifier from `value.map(...)` as chaining syntax.
- Bare method names like `map` and `uppercase` also require a resolution strategy from receiver type to namespace (`List -> list.*`, `String -> str.*`, `Number -> num.*`).
- Because of this, a pipeline operator may be a simpler first step than full method chaining.
- If adopted, the first version should probably target standard-library receivers only, not arbitrary user-defined dispatch.

---

### 49. From-End Indexing

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Negative indexes count backward from the end for strings and lists. This is unusually well aligned with the current parser because `xs[-1]` already parses today; only runtime semantics reject it.

**Proposed Syntax:**

```primal
[10, 20, 30][-1]                         // 30
[10, 20, 30][-2]                         // 20
"hello"[-1]                              // "o"
"hello"[-5]                              // "h"

last(xs) = xs[-1]
secondLast(xs) = xs[-2]
```

**Use Cases:**

- Last-element access
- Tail-oriented string work
- Cleaner indexing in small scripts
- Removing the need for repeated `length - 1` calculations

**Implementation Notes:**

- For lists and strings, negative index `-1` maps to `length - 1`.
- `-length` is the first element; smaller values remain out of bounds.
- The `@` / `[]` runtime function already centralizes indexing, so this is mostly a change in `element_at`.
- This keeps the surface area small by improving an existing form rather than inventing a new one.

---

### 50. Native Set / Vector Literal Syntax

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Literal syntax for `Set` and `Vector` values. Both runtime types already exist, but users currently have to call `set.new([...])` and `vector.new([...])`. Literal sugar would make them feel like first-class language constructs.

**Proposed Syntax:**

```primal
// Set literals
s1 = set{1, 2, 3}
s2 = set{1, 2, 2, 3}                     // duplicates collapsed
s3 = set{}

// Vector literals
v1 = vec[1, 2, 3]
v2 = vec[3, 4]

set.contains(s1, 2)                      // true
vector.magnitude(v2)                     // 5
vector.add(vec[1, 2], vec[3, 4])         // vec[4, 6]
```

**Use Cases:**

- Mathematical code
- Geometry and graphics
- Membership-heavy logic
- Cleaner examples and teaching material

**Implementation Notes:**

- `set{...}` can desugar to `set.new([...])`.
- `vec[...]` can desugar to `vector.new([...])`.
- This proposal is cheap because `SetNode` and `VectorNode` already exist in the runtime.
- Prefix forms avoid conflicts with existing map `{...}` and list `[...]` literals, and they are simpler than introducing `<...>` tokenization.

---

## Summary

This document proposes 50 new features for the Primal programming language, organized into 7 categories:

| Category                | Count | High Impact                                           |
| ----------------------- | ----- | ----------------------------------------------------- |
| Data Types & Structures | 11    | Matrices, Trees, Bytes                                |
| Functional Patterns     | 8     | Trampolining, Lenses, Transducers                     |
| Effects & Control Flow  | 6     | Validation, Async, Algebraic Effects                  |
| Type System             | 6     | Newtypes, Row Polymorphism                            |
| Language Primitives     | 8     | Namespace Blocks, Symbols, Debug/Trace                |
| Testing & Verification  | 4     | Property-Based Testing, Doctests                      |
| Syntax Sugar            | 7     | Case Expressions, With Expressions, From-End Indexing |

**Recommended Priority (High Fit + High Impact + Low/Medium Complexity):**

1. Namespace Blocks - near-zero runtime cost and solves real organization pain
2. Debug/Trace Expressions - immediate developer productivity
3. Bytes / Binary Data - fills a real gap around files, hashing, and I/O
4. Validation Type - essential for real applications
5. Case Expressions - cleaner conditionals with a straightforward desugaring story
6. With Expressions - local bindings without polluting the global namespace
7. Trampolining - enables deep recursion safely
8. Symbols/Atoms - efficient tags and keys, especially for tagged data
9. From-End Indexing - high-value improvement to an existing form
10. Doctests / Executable Examples - especially strong for Primal's educational focus

`Placeholder Arguments` and `Method Chaining` remain attractive, but they both become much cleaner once Primal also has anonymous functions and/or a pipeline operator.
