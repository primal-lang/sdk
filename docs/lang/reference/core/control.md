---
title: Control
tags:
  - reference
  - control-flow
sources:
  - lib/compiler/library/control/
---

# Control

**TLDR**: Control flow constructs including conditional expressions (if-else), local variable bindings (let), and error handling (try).

Number of functions: 2

## Control Flow

### If-Else

- **Syntax:**

```
if (a:Boolean)
    b:Any
else
    c:Any
```

- **Input:** One conditional argument (a) and two arguments of any type (b and c). The conditional argument must evaluate to a boolean. The other two arguments must evaluate to the same type
- **Output:** If the condition is true, it returns the first argument. Otherwise it returns the second argument
- **Purity:** Pure
- **Example:**

```
if (true)
    "yes"
else
    "no"
// returns "yes"
```

### Let

- **Syntax:** `let name1 = expr1, name2 = expr2, ... in body`
- **Input:** One or more bindings and a body expression
- **Output:** The result of evaluating the body with bindings in scope
- **Purity:** Pure
- **Description:** Let expressions introduce local bindings that are only visible within the body. Bindings are evaluated sequentially (call-by-value), so later bindings can reference earlier ones. Let bindings can shadow function names but cannot shadow function parameters.
- **Example:**

```
let
    a = 5,
    b = 1
in
    a + b // returns 6
```

### Try-Catch

- **Signature:** `try(a: Any, b: Any): Any`
- **Input:** Two arguments, which must evaluate to the same type
- **Output:** It returns the first argument unless it evaluates to an error, in which case, it returns the second argument
- **Purity:** Pure
- **Example:**

```
try(num.div(10, 0), "Division by zero") // returns "Division by zero"
```
