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

- **Signature:** `type_of(a: Any): String`
- **Input:** An argument of any type
- **Output:** The canonical runtime type name as a string
- **Purity:** Pure
- **Example:**

```
type_of([1, 2, 3]) // returns "List"
```

## Function Inspection

### Function Name

- **Signature:** `function_name(a: Function): String`
- **Input:** A function value
- **Output:** The function's intrinsic name as a string
- **Purity:** Pure
- **Example:**

```
function_name(num_add) // returns "num_add"
```

### Function Arity

- **Signature:** `function_arity(a: Function): Number`
- **Input:** A function value
- **Output:** The number of parameters accepted by the function
- **Purity:** Pure
- **Example:**

```
function_arity(num_add) // returns 2
```

### Function Parameters

- **Signature:** `function_parameters(a: Function): List`
- **Input:** A function value
- **Output:** The function parameter names as a list of strings, in declaration order
- **Purity:** Pure
- **Example:**

```
function_parameters(num_add) // returns ["a", "b"]
```
