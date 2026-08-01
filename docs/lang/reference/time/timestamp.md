---
title: Timestamp
tags:
  - reference
  - time
sources:
  - lib/compiler/library/timestamp/
---

# Timestamp

**TLDR**: Functions for creating, converting, formatting, and comparing timestamps with support for extracting date/time components and ISO 8601 formatting.

Number of functions: 22

## Creation

### Now

- **Signature:** `time_now(): Timestamp`
- **Output:** A timestamp instance with the current local date and time.
- **Purity:** Impure
- **Example:**

```
time_now() // returns the current timestamp
```

### From ISO

- **Signature:** `time_fromIso(a: String): Timestamp`
- **Input:** A string representation of a timestamp in ISO 8601 format.
- **Output:** A timestamp instance.
- **Constraints:** Throws an error if the string is not a valid ISO 8601 timestamp
- **Purity:** Pure
- **Example:**

```
time_fromIso("2024-01-15T10:30:00.000Z") // returns a timestamp
```

### From Epoch

- **Signature:** `time_fromEpoch(a: Number): Timestamp`
- **Input:** The number of milliseconds since the Unix epoch.
- **Output:** A timestamp instance.
- **Purity:** Pure
- **Example:**

```
time_fromEpoch(1704067200000) // returns a timestamp
```

## Conversion

### To ISO

- **Signature:** `time_toIso(a: Timestamp): String`
- **Input:** A timestamp instance.
- **Output:** A string representation of the timestamp in ISO 8601 format.
- **Purity:** Pure
- **Example:**

```
time_toIso(time_now()) // returns the ISO 8601 string
```

### To Epoch

- **Signature:** `time_toEpoch(a: Timestamp): Number`
- **Input:** A timestamp instance.
- **Output:** The number of milliseconds since the Unix epoch.
- **Purity:** Pure
- **Example:**

```
time_toEpoch(time_now()) // returns the epoch time in milliseconds
```

### Format

- **Signature:** `time_format(a: Timestamp, b: String): String`
- **Input:** A timestamp and a format pattern string.
- **Output:** A string representation of the timestamp in the specified format.
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
time_format(time_now(), "yyyy-MM-dd") // returns "2024-01-15"
```

## Components

### Year

- **Signature:** `time_year(a: Timestamp): Number`
- **Input:** A timestamp instance.
- **Output:** The year of the timestamp.
- **Purity:** Pure
- **Example:**

```
time_year(time_fromIso("2024-01-15T10:30:00.000Z")) // returns 2024
```

### Month

- **Signature:** `time_month(a: Timestamp): Number`
- **Input:** A timestamp instance.
- **Output:** The month of the timestamp (1-12).
- **Purity:** Pure
- **Example:**

```
time_month(time_fromIso("2024-01-15T10:30:00.000Z")) // returns 1
```

### Day

- **Signature:** `time_day(a: Timestamp): Number`
- **Input:** A timestamp instance.
- **Output:** The day of the timestamp (1-31).
- **Purity:** Pure
- **Example:**

```
time_day(time_fromIso("2024-01-15T10:30:00.000Z")) // returns 15
```

### Day of Week

- **Signature:** `time_dayOfWeek(a: Timestamp): Number`
- **Input:** A timestamp instance.
- **Output:** The day of the week (1-7, where 1 is Monday).
- **Purity:** Pure
- **Example:**

```
time_dayOfWeek(time_now()) // returns 1-7 (Monday=1)
```

### Day of Year

- **Signature:** `time_dayOfYear(a: Timestamp): Number`
- **Input:** A timestamp instance.
- **Output:** The day of the year (1-366).
- **Purity:** Pure
- **Example:**

```
time_dayOfYear(time_now()) // returns 1-366
```

### Hour

- **Signature:** `time_hour(a: Timestamp): Number`
- **Input:** A timestamp instance.
- **Output:** The hour of the timestamp (0-23).
- **Purity:** Pure
- **Example:**

```
time_hour(time_fromIso("2024-01-15T10:30:00.000Z")) // returns 10
```

### Minute

- **Signature:** `time_minute(a: Timestamp): Number`
- **Input:** A timestamp instance.
- **Output:** The minute of the timestamp (0-59).
- **Purity:** Pure
- **Example:**

```
time_minute(time_fromIso("2024-01-15T10:30:00.000Z")) // returns 30
```

### Second

- **Signature:** `time_second(a: Timestamp): Number`
- **Input:** A timestamp instance.
- **Output:** The second of the timestamp (0-59).
- **Purity:** Pure
- **Example:**

```
time_second(time_fromIso("2024-01-15T10:30:45.000Z")) // returns 45
```

### Millisecond

- **Signature:** `time_millisecond(a: Timestamp): Number`
- **Input:** A timestamp instance.
- **Output:** The millisecond of the timestamp (0-999).
- **Purity:** Pure
- **Example:**

```
time_millisecond(time_fromIso("2024-01-15T10:30:00.500Z")) // returns 500
```

## Comparison

### Compare

- **Signature:** `time_compare(a: Timestamp, b: Timestamp): Number`
- **Input:** Two timestamp instances.
- **Output:** 1 if the first timestamp is bigger than the second. -1 if it is the smaller. 0 if they are equal.
- **Purity:** Pure
- **Example:**

```
time_compare(time_fromIso("2024-02-01T00:00:00Z"), time_fromIso("2024-01-01T00:00:00Z")) // returns 1
```

### Is Before

- **Signature:** `time_isBefore(a: Timestamp, b: Timestamp): Boolean`
- **Input:** Two timestamps.
- **Output:** True if the first timestamp is before the second, false otherwise.
- **Purity:** Pure
- **Example:**

```
time_isBefore(yesterday, time_now()) // returns true
```

### Is After

- **Signature:** `time_isAfter(a: Timestamp, b: Timestamp): Boolean`
- **Input:** Two timestamps.
- **Output:** True if the first timestamp is after the second, false otherwise.
- **Purity:** Pure
- **Example:**

```
time_isAfter(time_now(), yesterday) // returns true
```

## Arithmetic

### Add

- **Signature:** `time_add(a: Timestamp, b: Duration): Timestamp`
- **Input:** A timestamp and a duration.
- **Output:** A new timestamp with the duration added.
- **Purity:** Pure
- **Example:**

```
time_add(time_now(), duration_fromHours(2)) // returns timestamp 2 hours from now
```

### Subtract

- **Signature:** `time_subtract(a: Timestamp, b: Duration): Timestamp`
- **Input:** A timestamp and a duration.
- **Output:** A new timestamp with the duration subtracted.
- **Purity:** Pure
- **Example:**

```
time_subtract(time_now(), duration_fromDays(1)) // returns timestamp 1 day ago
```

### Between

- **Signature:** `time_between(a: Timestamp, b: Timestamp): Duration`
- **Input:** Two timestamps.
- **Output:** The duration between the two timestamps.
- **Purity:** Pure
- **Example:**

```
time_between(t1, t2) // returns the duration between t1 and t2
```

## Utility

### Is Leap Year

- **Signature:** `time_isLeapYear(a: Number): Boolean`
- **Input:** A year as a number.
- **Output:** True if the year is a leap year, false otherwise.
- **Purity:** Pure
- **Example:**

```
time_isLeapYear(2024) // returns true
```
