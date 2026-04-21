---
title: Introspection
tags:
  - reference
  - types
sources:
  - lib/compiler/library/introspection/
---

# Introspection

**TLDR**: Functions for inspecting values at runtime, including type checking and function metadata retrieval.

Number of functions: 4

## Type Inspection

### Type Of

- **Signature:** `type.of(a: Any): String`
- **Input:** An argument of any type
- **Output:** The canonical runtime type name as a string
- **Purity:** Pure
- **Example:**

```
type.of([1, 2, 3]) // returns "List"
```

## Function Inspection

### Function Name

- **Signature:** `function.name(a: Function): String`
- **Input:** A function value
- **Output:** The function's intrinsic name as a string
- **Purity:** Pure
- **Example:**

```
function.name(num.add) // returns "num.add"
```

### Function Arity

- **Signature:** `function.arity(a: Function): Number`
- **Input:** A function value
- **Output:** The number of parameters accepted by the function
- **Purity:** Pure
- **Example:**

```
function.arity(num.add) // returns 2
```

### Function Parameters

- **Signature:** `function.parameters(a: Function): List`
- **Input:** A function value
- **Output:** The function parameter names as a list of strings, in declaration order
- **Purity:** Pure
- **Example:**

```
function.parameters(num.add) // returns ["a", "b"]
```
