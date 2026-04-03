# Timestamp

## Creation

### Now

- **Signature:** `time.now(): Timestamp`
- **Input:** None
- **Output:** A timestamp representing the current date and time
- **Example:**

```
time.now() // returns the current timestamp
```

### From ISO

- **Signature:** `time.fromIso(a: String): Timestamp`
- **Input:** One ISO 8601 string
- **Output:** A timestamp parsed from the string
- **Example:**

```
time.fromIso("2024-01-15T10:30:00Z") // returns a timestamp
```

## Conversion

### To ISO

- **Signature:** `time.toIso(a: Timestamp): String`
- **Input:** One timestamp
- **Output:** The ISO 8601 string representation
- **Example:**

```
time.toIso(time.now()) // returns "2024-01-15T10:30:00.000Z"
```

### Epoch

- **Signature:** `time.epoch(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The number of milliseconds elapsed since the Unix epoch
- **Example:**

```
time.epoch(time.now()) // returns 1705312200000
```

## Components

### Year

- **Signature:** `time.year(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The year component of the timestamp
- **Example:**

```
time.year(time.fromIso("2024-01-15T10:30:00Z")) // returns 2024
```

### Month

- **Signature:** `time.month(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The month component of the timestamp (1-12)
- **Example:**

```
time.month(time.fromIso("2024-01-15T10:30:00Z")) // returns 1
```

### Day

- **Signature:** `time.day(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The day component of the timestamp (1-31)
- **Example:**

```
time.day(time.fromIso("2024-01-15T10:30:00Z")) // returns 15
```

### Hour

- **Signature:** `time.hour(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The hour component of the timestamp (0-23)
- **Example:**

```
time.hour(time.fromIso("2024-01-15T10:30:00Z")) // returns 10
```

### Minute

- **Signature:** `time.minute(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The minute component of the timestamp (0-59)
- **Example:**

```
time.minute(time.fromIso("2024-01-15T10:30:00Z")) // returns 30
```

### Second

- **Signature:** `time.second(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The second component of the timestamp (0-59)
- **Example:**

```
time.second(time.fromIso("2024-01-15T10:30:00Z")) // returns 0
```

### Millisecond

- **Signature:** `time.millisecond(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The millisecond component of the timestamp (0-999)
- **Example:**

```
time.millisecond(time.fromIso("2024-01-15T10:30:00.500Z")) // returns 500
```

## Comparison

### Compare

- **Signature:** `time.compare(a: Timestamp, b: Timestamp): Number`
- **Input:** Two timestamps
- **Output:** 1 if the first timestamp is greater, -1 if smaller, 0 if equal
- **Example:**

```
time.compare(time.fromIso("2024-02-01T00:00:00Z"), time.fromIso("2024-01-01T00:00:00Z")) // returns 1
```
