# Stack

## Creation

### New

- **Signature:** `stack.new(a: List): Stack`
- **Input:** One list
- **Output:** A stack with the last element at the top
- **Example:**

```
stack.new([1, 2, 3]) // returns a stack with 3 at the top
```

## Operations

### Push

- **Signature:** `stack.push(a: Stack, b: Any): Stack`
- **Input:** A stack and a value
- **Output:** A new stack with the element added to the top
- **Example:**

```
stack.push(stack.new([1, 2]), 3) // returns a stack with 3 at the top
```

### Pop

- **Signature:** `stack.pop(a: Stack): Stack`
- **Input:** One stack
- **Output:** A new stack with the top element removed
- **Example:**

```
stack.pop(stack.new([1, 2, 3])) // returns a stack with 2 at the top
```

### Peek

- **Signature:** `stack.peek(a: Stack): Any`
- **Input:** One stack
- **Output:** The element at the top of the stack
- **Example:**

```
stack.peek(stack.new([1, 2, 3])) // returns 3
```

### Reverse

- **Signature:** `stack.reverse(a: Stack): Stack`
- **Input:** One stack
- **Output:** A new stack with the elements in reverse order
- **Example:**

```
stack.reverse(stack.new([1, 2, 3])) // returns a stack with 1 at the top
```

## Properties

### Is Empty

- **Signature:** `stack.isEmpty(a: Stack): Boolean`
- **Input:** One stack
- **Output:** True if the stack is empty, false otherwise
- **Example:**

```
stack.isEmpty(stack.new([])) // returns true
```

### Is Not Empty

- **Signature:** `stack.isNotEmpty(a: Stack): Boolean`
- **Input:** One stack
- **Output:** True if the stack is not empty, false otherwise
- **Example:**

```
stack.isNotEmpty(stack.new([1, 2])) // returns true
```

### Length

- **Signature:** `stack.length(a: Stack): Number`
- **Input:** One stack
- **Output:** The number of elements in the stack
- **Example:**

```
stack.length(stack.new([1, 2, 3])) // returns 3
```
