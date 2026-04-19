---
title: Debug
tags:
  - reference
  - debugging
sources:
  - lib/compiler/library/debug/
---

# Debug

**TLDR**: Function for printing values with type information to the console for debugging purposes.

Number of functions: 1

## Debug

- **Signature:** `debug(a: Any): Any`
- **Input:** An argument of any type.
- **Output:** Prints the value with type information to the console and returns the value.
- **Purity:** Impure
- **Example:**

```
debug([1, 2, 3]) // prints "[1, 2, 3] : List" and returns [1, 2, 3]
```
