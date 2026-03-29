# Console

## Output

### Write

- **Signature:** `console.write(a: Any): Any`
- **Input:** One argument of any type
- **Output:** The argument, after writing it to standard output
- **Example:**

```
console.write("hello") // prints "hello" and returns "hello"
```

### Write Line

- **Signature:** `console.writeLn(a: Any): Any`
- **Input:** One argument of any type
- **Output:** The argument, after writing it followed by a newline to standard output
- **Example:**

```
console.writeLn("hello") // prints "hello\n" and returns "hello"
```

## Input

### Read

- **Signature:** `console.read(): String`
- **Input:** None
- **Output:** A line read from standard input as a string

Note: This function is not available on the web platform.

- **Example:**

```
console.read() // waits for input and returns the entered string
```
