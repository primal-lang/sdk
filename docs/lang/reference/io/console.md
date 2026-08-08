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
- **Output:** Reads a line from the standard input and returns it as a string. Once the input has ended, it returns the empty string, and every call after that returns the empty string too.
- **Purity:** Impure
- **Example:**

```
console_read() // waits for input and returns the entered string
```

> **Note:** A blank line and an ended input both read as the empty string, so a program that reads in a loop needs its own way to stop, such as a sentinel line.

> **Note:** This function is not implemented on the web platform.
