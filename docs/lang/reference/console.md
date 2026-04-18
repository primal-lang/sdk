---
title: Console
tags: [reference, io]
sources: [lib/compiler/library/console/]
---

# Console

**TLDR**: Functions for reading from standard input and writing to standard output for interactive console applications.

Number of functions: 3

## Output

### Write

- **Signature:** `console.write(a: Any): Any`
- **Input:** One argument of any type
- **Output:** The argument, after writing it to standard output
- **Purity:** Impure
- **Example:**

```
console.write("hello") // prints "hello" and returns "hello"
```

### Write Line

- **Signature:** `console.writeLn(a: Any): Any`
- **Input:** One argument of any type
- **Output:** The argument, after writing it followed by a newline to standard output
- **Purity:** Impure
- **Example:**

```
console.writeLn("hello") // prints "hello\n" and returns "hello"
```

## Input

### Read

- **Signature:** `console.read(): String`
- **Input:** None
- **Output:** A line read from standard input as a string
- **Purity:** Impure

Note: This function is not available on the web platform.

- **Example:**

```
console.read() // waits for input and returns the entered string
```
