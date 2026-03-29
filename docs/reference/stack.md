# Stack

## Creation

### New
- **Signature:** `stack.new(a: List): Stack`
- **Input:** One list
- **Output:** A stack with the last element at the top

## Operations

### Push
- **Signature:** `stack.push(a: Stack, b: Any): Stack`
- **Input:** A stack and a value
- **Output:** A new stack with the element added to the top

### Pop
- **Signature:** `stack.pop(a: Stack): Stack`
- **Input:** One stack
- **Output:** A new stack with the top element removed

### Peek
- **Signature:** `stack.peek(a: Stack): Any`
- **Input:** One stack
- **Output:** The element at the top of the stack

### Reverse
- **Signature:** `stack.reverse(a: Stack): Stack`
- **Input:** One stack
- **Output:** A new stack with the elements in reverse order

## Properties

### Is Empty
- **Signature:** `stack.isEmpty(a: Stack): Boolean`
- **Input:** One stack
- **Output:** True if the stack is empty, false otherwise

### Is Not Empty
- **Signature:** `stack.isNotEmpty(a: Stack): Boolean`
- **Input:** One stack
- **Output:** True if the stack is not empty, false otherwise

### Length
- **Signature:** `stack.length(a: Stack): Number`
- **Input:** One stack
- **Output:** The number of elements in the stack
