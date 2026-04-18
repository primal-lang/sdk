---
title: Timestamp
tags: [reference, time]
sources: [lib/compiler/library/timestamp/]
---

# Timestamp

**TLDR**: Functions for creating, converting, formatting, and comparing timestamps with support for extracting date/time components and ISO 8601 formatting.

Number of functions: 22

## Creation

### Now

- **Signature:** `time.now(): Timestamp`
- **Input:** None
- **Output:** A timestamp representing the current date and time
- **Purity:** Impure
- **Example:**

```
time.now() // returns the current timestamp
```

### From ISO

- **Signature:** `time.fromIso(a: String): Timestamp`
- **Input:** One ISO 8601 string
- **Output:** A timestamp parsed from the string
- **Constraints:** Throws an error if the string is not a valid ISO 8601 timestamp
- **Purity:** Pure
- **Example:**

```
time.fromIso("2024-01-15T10:30:00Z") // returns a timestamp
```

### From Epoch

- **Signature:** `time.fromEpoch(a: Number): Timestamp`
- **Input:** One number representing milliseconds since the Unix epoch
- **Output:** A timestamp created from the epoch value
- **Purity:** Pure
- **Example:**

```
time.fromEpoch(1705312200000) // returns a timestamp for 2024-01-15T10:30:00.000Z
```

## Conversion

### To ISO

- **Signature:** `time.toIso(a: Timestamp): String`
- **Input:** One timestamp
- **Output:** The ISO 8601 string representation
- **Purity:** Pure
- **Example:**

```
time.toIso(time.now()) // returns "2024-01-15T10:30:00.000Z"
```

### To Epoch

- **Signature:** `timestamp.toEpoch(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The number of milliseconds elapsed since the Unix epoch
- **Purity:** Pure
- **Example:**

```
timestamp.toEpoch(time.now()) // returns 1705312200000
```

### Format

- **Signature:** `time.format(a: Timestamp, b: String): String`
- **Input:** One timestamp and one format pattern string
- **Output:** The formatted date/time string
- **Purity:** Pure
- **Supported Patterns:**
  - `yyyy` - 4-digit year (e.g., 2024)
  - `yy` - 2-digit year (e.g., 24)
  - `MM` - 2-digit month (01-12)
  - `M` - month (1-12)
  - `dd` - 2-digit day (01-31)
  - `d` - day (1-31)
  - `HH` - 2-digit hour, 24-hour format (00-23)
  - `H` - hour, 24-hour format (0-23)
  - `hh` - 2-digit hour, 12-hour format (01-12)
  - `h` - hour, 12-hour format (1-12)
  - `mm` - 2-digit minute (00-59)
  - `m` - minute (0-59)
  - `ss` - 2-digit second (00-59)
  - `s` - second (0-59)
  - `SSS` - 3-digit millisecond (000-999)
  - `a` - AM/PM marker
  - `'...'` - literal text (use `''` for a literal single quote)
- **Example:**

```
time.format(time.fromIso("2024-01-15T14:30:45.123Z"), "yyyy-MM-dd") // returns "2024-01-15"
time.format(time.fromIso("2024-01-15T14:30:45.123Z"), "HH:mm:ss") // returns "14:30:45"
time.format(time.fromIso("2024-01-15T14:30:45.123Z"), "h:mm a") // returns "2:30 PM"
time.format(time.fromIso("2024-01-15T14:30:45.123Z"), "'Date': yyyy-MM-dd") // returns "Date: 2024-01-15"
```

## Components

### Year

- **Signature:** `time.year(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The year component of the timestamp
- **Purity:** Pure
- **Example:**

```
time.year(time.fromIso("2024-01-15T10:30:00Z")) // returns 2024
```

### Month

- **Signature:** `time.month(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The month component of the timestamp (1-12)
- **Purity:** Pure
- **Example:**

```
time.month(time.fromIso("2024-01-15T10:30:00Z")) // returns 1
```

### Day

- **Signature:** `time.day(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The day component of the timestamp (1-31)
- **Purity:** Pure
- **Example:**

```
time.day(time.fromIso("2024-01-15T10:30:00Z")) // returns 15
```

### Day of Week

- **Signature:** `time.dayOfWeek(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The day of the week (1-7, where Monday = 1 and Sunday = 7)
- **Purity:** Pure
- **Example:**

```
time.dayOfWeek(time.fromIso("2024-01-15T10:30:00Z")) // returns 1 (Monday)
```

### Day of Year

- **Signature:** `time.dayOfYear(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The day of the year (1-366)
- **Purity:** Pure
- **Example:**

```
time.dayOfYear(time.fromIso("2024-01-15T10:30:00Z")) // returns 15
time.dayOfYear(time.fromIso("2024-12-31T10:30:00Z")) // returns 366 (leap year)
```

### Hour

- **Signature:** `time.hour(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The hour component of the timestamp (0-23)
- **Purity:** Pure
- **Example:**

```
time.hour(time.fromIso("2024-01-15T10:30:00Z")) // returns 10
```

### Minute

- **Signature:** `time.minute(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The minute component of the timestamp (0-59)
- **Purity:** Pure
- **Example:**

```
time.minute(time.fromIso("2024-01-15T10:30:00Z")) // returns 30
```

### Second

- **Signature:** `time.second(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The second component of the timestamp (0-59)
- **Purity:** Pure
- **Example:**

```
time.second(time.fromIso("2024-01-15T10:30:00Z")) // returns 0
```

### Millisecond

- **Signature:** `time.millisecond(a: Timestamp): Number`
- **Input:** One timestamp
- **Output:** The millisecond component of the timestamp (0-999)
- **Purity:** Pure
- **Example:**

```
time.millisecond(time.fromIso("2024-01-15T10:30:00.500Z")) // returns 500
```

## Comparison

### Compare

- **Signature:** `time.compare(a: Timestamp, b: Timestamp): Number`
- **Input:** Two timestamps
- **Output:** 1 if the first timestamp is greater, -1 if smaller, 0 if equal
- **Purity:** Pure
- **Example:**

```
time.compare(time.fromIso("2024-02-01T00:00:00Z"), time.fromIso("2024-01-01T00:00:00Z")) // returns 1
```

### Is Before

- **Signature:** `time.isBefore(a: Timestamp, b: Timestamp): Boolean`
- **Input:** Two timestamps
- **Output:** True if the first timestamp occurs before the second, false otherwise
- **Purity:** Pure
- **Example:**

```
time.isBefore(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2024-02-01T00:00:00Z")) // returns true
time.isBefore(time.fromIso("2024-02-01T00:00:00Z"), time.fromIso("2024-01-01T00:00:00Z")) // returns false
```

### Is After

- **Signature:** `time.isAfter(a: Timestamp, b: Timestamp): Boolean`
- **Input:** Two timestamps
- **Output:** True if the first timestamp occurs after the second, false otherwise
- **Purity:** Pure
- **Example:**

```
time.isAfter(time.fromIso("2024-02-01T00:00:00Z"), time.fromIso("2024-01-01T00:00:00Z")) // returns true
time.isAfter(time.fromIso("2024-01-01T00:00:00Z"), time.fromIso("2024-02-01T00:00:00Z")) // returns false
```

## Arithmetic

### Time Add

- **Signature:** `time.add(timestamp: Timestamp, duration: Duration): Timestamp`
- **Input:** One timestamp and one duration
- **Output:** A new timestamp with the duration added
- **Purity:** Pure
- **Example:**

```
time.add(time.fromIso("2025-01-01T00:00:00Z"), duration.fromDays(7))  // January 8th
```

### Time Subtract

- **Signature:** `time.subtract(timestamp: Timestamp, duration: Duration): Timestamp`
- **Input:** One timestamp and one duration
- **Output:** A new timestamp with the duration subtracted
- **Purity:** Pure
- **Example:**

```
time.subtract(time.fromIso("2025-01-08T00:00:00Z"), duration.fromDays(7))  // January 1st
```

### Time Between

- **Signature:** `time.between(a: Timestamp, b: Timestamp): Duration`
- **Input:** Two timestamps
- **Output:** The absolute duration between the two timestamps (always non-negative)
- **Note:** Argument order doesn't matter; returns the same result either way
- **Purity:** Pure
- **Example:**

```
start() = time.fromIso("2025-01-01T00:00:00Z")
end() = time.fromIso("2025-01-08T00:00:00Z")
time.between(start(), end())  // 7 days
time.between(end(), start())  // 7 days (same result)
```

## Utility

### Is Leap Year

- **Signature:** `time.isLeapYear(a: Number): Boolean`
- **Input:** One number representing a year
- **Output:** True if the year is a leap year, false otherwise
- **Purity:** Pure
- **Example:**

```
time.isLeapYear(2024) // returns true
time.isLeapYear(2023) // returns false
time.isLeapYear(2000) // returns true (divisible by 400)
time.isLeapYear(1900) // returns false (divisible by 100 but not 400)
```
