# Logic

## Functions

### And

- **Signature:** `bool.and(a: Boolean, b: Boolean): Boolean`
- **Input:** Two booleans
- **Output:** True if both arguments are true, false otherwise
- **Purity:** Pure
- **Example:**

```
bool.and(true, false) // returns false
```

### Or

- **Signature:** `bool.or(a: Boolean, b: Boolean): Boolean`
- **Input:** Two booleans
- **Output:** True if at least one argument is true, false otherwise
- **Purity:** Pure
- **Example:**

```
bool.or(true, false) // returns true
```

### Xor

- **Signature:** `bool.xor(a: Boolean, b: Boolean): Boolean`
- **Input:** Two booleans
- **Output:** True if exactly one argument is true, false otherwise
- **Purity:** Pure
- **Example:**

```
bool.xor(true, false) // returns true
```

### Not

- **Signature:** `bool.not(a: Boolean): Boolean`
- **Input:** One boolean
- **Output:** True if the argument is false, false if the argument is true
- **Purity:** Pure
- **Example:**

```
bool.not(true) // returns false
```
