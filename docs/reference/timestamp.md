# Timestamp

## Creation

### Now
- **Signature:** `time.now(): Timestamp`
- **Input:** None
- **Output:** A timestamp representing the current date and time

### From ISO
- **Signature:** `time.fromIso(a: String): Timestamp`
- **Input:** One ISO 8601 string
- **Output:** A timestamp parsed from the string

## Conversion

### To ISO
- **Signature:** `time.toIso(a: Timestamp): String`
- **Input:** One timestamp
- **Output:** The ISO 8601 string representation

### Epoch
- **Signature:** `time.epoch(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The number of milliseconds elapsed since the Unix epoch

## Components

### Year
- **Signature:** `time.year(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The year component of the timestamp

### Month
- **Signature:** `time.month(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The month component of the timestamp (1-12)

### Day
- **Signature:** `time.day(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The day component of the timestamp (1-31)

### Hour
- **Signature:** `time.hour(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The hour component of the timestamp (0-23)

### Minute
- **Signature:** `time.minute(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The minute component of the timestamp (0-59)

### Second
- **Signature:** `time.second(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The second component of the timestamp (0-59)

### Millisecond
- **Signature:** `time.millisecond(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The millisecond component of the timestamp (0-999)

## Comparison

### Compare
- **Signature:** `time.compare(a: Timestamp, b: Timestamp): Number`
- **Input:** Two timestamps
- **Output:** 1 if the first timestamp is greater, -1 if smaller, 0 if equal
