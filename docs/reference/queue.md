# Queue

## Creation

### New
- **Signature:** `queue.new(a: List): Queue`
- **Input:** One list
- **Output:** A queue with the first element at the front

## Operations

### Enqueue
- **Signature:** `queue.enqueue(a: Queue, b: Any): Queue`
- **Input:** A queue and a value
- **Output:** A new queue with the element added to the end

### Dequeue
- **Signature:** `queue.dequeue(a: Queue): Queue`
- **Input:** One queue
- **Output:** A new queue with the front element removed

### Peek
- **Signature:** `queue.peek(a: Queue): Any`
- **Input:** One queue
- **Output:** The element at the front of the queue

### Reverse
- **Signature:** `queue.reverse(a: Queue): Queue`
- **Input:** One queue
- **Output:** A new queue with the elements in reverse order

## Properties

### Is Empty
- **Signature:** `queue.isEmpty(a: Queue): Boolean`
- **Input:** One queue
- **Output:** True if the queue is empty, false otherwise

### Is Not Empty
- **Signature:** `queue.isNotEmpty(a: Queue): Boolean`
- **Input:** One queue
- **Output:** True if the queue is not empty, false otherwise

### Length
- **Signature:** `queue.length(a: Queue): Number`
- **Input:** One queue
- **Output:** The number of elements in the queue
