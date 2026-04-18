---
title: Error
tags: [reference, error-handling]
sources: [lib/compiler/library/error/]
---

# Error

**TLDR**: Function for throwing custom errors with an error code and message that can be caught using the try function.

Number of functions: 1

## Functions

### Throw

- **Signature:** `error.throw(a: Any, b: String): Error`
- **Input:** An error code and a message string
- **Output:** An error that wraps the provided code and message
- **Purity:** Impure
- **Example:**

```
error.throw(404, "not found") // throws an error with code 404 and message "not found"
```
