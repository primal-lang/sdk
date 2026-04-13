# Control

Number of functions: 2

## Control Flow

### If-Else

- **Syntax:** `if (a: Boolean) b: Any else c: Any`
- **Input:** A boolean condition and two branch arguments
- **Output:** The first branch argument if the condition is true, the second branch argument otherwise
- **Purity:** Pure
- **Example:**

```
if (true) "yes" else "no" // returns "yes"
```

### Let

- **Syntax:** `let name1 = expr1, name2 = expr2, ... in body`
- **Input:** One or more bindings and a body expression
- **Output:** The result of evaluating the body with bindings in scope
- **Purity:** Pure
- **Description:** Let expressions introduce local bindings that are only visible within the body. Bindings are evaluated sequentially (call-by-value), so later bindings can reference earlier ones. Let bindings can shadow function names but cannot shadow function parameters.
- **Examples:**

```
let x = 5 in x + 1 // returns 6
```

```
let a = 1, b = a + 1 in a + b // returns 3
```

```
let square = num.mul in square(4, 4) // returns 16 (binding a function)
```

```
let x = 1 in let y = x + 1 in x + y // returns 3 (nested let)
```

### Try

- **Signature:** `try(a: Any, b: Any): Any`
- **Input:** Two arguments
- **Output:** The first argument unless it produces an error, in which case the second argument
- **Purity:** Pure
- **Example:**

```
try(num.div(10, 0), 0) // returns 0
```
