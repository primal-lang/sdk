---
title: Error
tags:
  - reference
  - error-handling
sources:
  - lib/compiler/library/error/
---

# Error

**TLDR**: Function for throwing custom errors with an error code and message that can be caught using the try function.

Number of functions: 1

## Functions

### Throw Error

- **Signature:** `error.throw(a: Any, b: String): Error`
- **Input:** An error code and a message string
- **Output:** Throws an error that wraps the provided code and message. This function never returns normally.
- **Purity:** Impure
- **Example:**

```
error.throw(404, "Not Found") // throws an error with code 404 and message "Not Found"
```
