# Logic

## Functions

### And (Short-Circuit)

- **Signature:** `bool.and(a: Boolean, b: Boolean): Boolean`
- **Input:** Two booleans
- **Output:** True if both arguments are true, false otherwise
- **Evaluation:** Short-circuit (lazy) - the second argument is only evaluated if the first is true
- **Purity:** Pure
- **Example:**

```
bool.and(true, false) // returns false
bool.and(false, error.throw(-1, "Not evaluated")) // returns false (no error thrown)
```

### And (Strict)

- **Signature:** `bool.andStrict(a: Boolean, b: Boolean): Boolean`
- **Input:** Two booleans
- **Output:** True if both arguments are true, false otherwise
- **Evaluation:** Strict (eager) - both arguments are always evaluated
- **Purity:** Pure
- **Example:**

```
bool.andStrict(true, false) // returns false
```

### Or (Short-Circuit)

- **Signature:** `bool.or(a: Boolean, b: Boolean): Boolean`
- **Input:** Two booleans
- **Output:** True if at least one argument is true, false otherwise
- **Evaluation:** Short-circuit (lazy) - the second argument is only evaluated if the first is false
- **Purity:** Pure
- **Example:**

```
bool.or(true, false) // returns true
bool.or(true, error.throw(-1, "Not evaluated")) // returns true (no error thrown)
```

### Or (Strict)

- **Signature:** `bool.orStrict(a: Boolean, b: Boolean): Boolean`
- **Input:** Two booleans
- **Output:** True if at least one argument is true, false otherwise
- **Evaluation:** Strict (eager) - both arguments are always evaluated
- **Purity:** Pure
- **Example:**

```
bool.orStrict(true, false) // returns true
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
