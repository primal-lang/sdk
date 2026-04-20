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

- **Signature:** `debug(a: String, b: Any): Any`
- **Input:** A label string and a value of any type.
- **Output:** Prints the label and value to the console in the format `[debug] label: value` and returns the fully-evaluated value. For collections, all nested elements are recursively evaluated before printing and returning.
- **Purity:** Impure
- **Example:**

```
debug("myList", [1, 2, 3]) // prints "[debug] myList: [1, 2, 3]" and returns [1, 2, 3]
```
