---
title: Console
tags:
  - reference
  - io
sources:
  - lib/compiler/library/console/
---

# Console

**TLDR**: Functions for reading from standard input and writing to standard output for interactive console applications.

Number of functions: 3

## Output

### Write

- **Signature:** `console_write(a: Any): Any`
- **Input:** An argument of any type.
- **Output:** It writes the argument in the standard output and returns it.
- **Purity:** Impure
- **Example:**

```
console_write("hello") // prints "hello" and returns "hello"
```

### Write Line

- **Signature:** `console_writeLn(a: Any): Any`
- **Input:** An argument of any type.
- **Output:** It writes the argument in the standard output, followed by a newline, and returns it.
- **Purity:** Impure
- **Example:**

```
console_writeLn("hello") // prints "hello\n" and returns "hello"
```

## Input

### Read

- **Signature:** `console_read(): String`
- **Input:** None.
- **Output:** Reads a line from the standard input and returns it as a string.
- **Purity:** Impure
- **Example:**

```
console_read() // waits for input and returns the entered string
```

> **Note:** This function is not implemented on the web platform.
