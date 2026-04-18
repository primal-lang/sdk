---
title: Duration
tags: [reference, time]
sources: [lib/compiler/library/duration/]
---

# Duration

**TLDR**: Functions for creating, converting, formatting, and comparing durations (time spans) with support for arithmetic and timestamp integration.

Number of functions: 18

## Creation

### From Milliseconds

- **Signature:** `duration.fromMilliseconds(milliseconds: Number): Duration`
- **Input:** One number (supports fractional values)
- **Output:** A duration representing the given milliseconds
- **Constraints:** Throws `NegativeDurationError` if input is negative
- **Purity:** Pure
- **Example:**

```
duration.fromMilliseconds(500)   // 500 milliseconds
duration.fromMilliseconds(1.5)   // 1.5 milliseconds (preserved as 1500 microseconds)
```

### From Seconds

- **Signature:** `duration.fromSeconds(seconds: Number): Duration`
- **Input:** One number (supports fractional values)
- **Output:** A duration representing the given seconds
- **Constraints:** Throws `NegativeDurationError` if input is negative
- **Purity:** Pure
- **Example:**

```
duration.fromSeconds(30)   // 30 seconds
duration.fromSeconds(1.5)  // 1.5 seconds = 1500 milliseconds
```

### From Minutes

- **Signature:** `duration.fromMinutes(minutes: Number): Duration`
- **Input:** One number (supports fractional values)
- **Output:** A duration representing the given minutes
- **Constraints:** Throws `NegativeDurationError` if input is negative
- **Purity:** Pure
- **Example:**

```
duration.fromMinutes(5)    // 5 minutes
duration.fromMinutes(2.5)  // 2.5 minutes = 150 seconds
```

### From Hours

- **Signature:** `duration.fromHours(hours: Number): Duration`
- **Input:** One number (supports fractional values)
- **Output:** A duration representing the given hours
- **Constraints:** Throws `NegativeDurationError` if input is negative
- **Purity:** Pure
- **Example:**

```
duration.fromHours(2)    // 2 hours
duration.fromHours(2.5)  // 2.5 hours = 150 minutes
```

### From Days

- **Signature:** `duration.fromDays(days: Number): Duration`
- **Input:** One number (supports fractional values)
- **Output:** A duration representing the given days
- **Constraints:** Throws `NegativeDurationError` if input is negative
- **Purity:** Pure
- **Example:**

```
duration.fromDays(7)    // 7 days
duration.fromDays(0.5)  // 0.5 days = 12 hours
```

### From Components

- **Signature:** `duration.from(days: Number, hours: Number, minutes: Number, seconds: Number, milliseconds: Number): Duration`
- **Input:** Five numbers representing days, hours, minutes, seconds, and milliseconds
- **Output:** A duration combining all components
- **Constraints:** Validates left-to-right; throws `NegativeDurationError` at first negative component (includes component name and value in error message)
- **Purity:** Pure
- **Example:**

```
duration.from(0, 2, 30, 0, 0)      // 2 hours, 30 minutes
duration.from(1, 0, 0, 0, 0)      // 1 day
duration.from(0, 1, 30, 45, 500)  // 1 hour, 30 minutes, 45 seconds, 500 milliseconds
```

## Total Conversion

These functions return the total duration converted to the specified unit as a fractional number.

### To Milliseconds

- **Signature:** `duration.toMilliseconds(duration: Duration): Number`
- **Input:** One duration
- **Output:** The total duration in milliseconds (fractional)
- **Purity:** Pure
- **Example:**

```
duration.toMilliseconds(duration.fromSeconds(1.5))  // returns 1500
```

### To Seconds

- **Signature:** `duration.toSeconds(duration: Duration): Number`
- **Input:** One duration
- **Output:** The total duration in seconds (fractional)
- **Purity:** Pure
- **Example:**

```
duration.toSeconds(duration.fromMilliseconds(1500))  // returns 1.5
```

### To Minutes

- **Signature:** `duration.toMinutes(duration: Duration): Number`
- **Input:** One duration
- **Output:** The total duration in minutes (fractional)
- **Purity:** Pure
- **Example:**

```
duration.toMinutes(duration.fromSeconds(90))  // returns 1.5
```

### To Hours

- **Signature:** `duration.toHours(duration: Duration): Number`
- **Input:** One duration
- **Output:** The total duration in hours (fractional)
- **Purity:** Pure
- **Example:**

```
duration.toHours(duration.fromMinutes(90))  // returns 1.5
```

### To Days

- **Signature:** `duration.toDays(duration: Duration): Number`
- **Input:** One duration
- **Output:** The total duration in days (fractional)
- **Purity:** Pure
- **Example:**

```
duration.toDays(duration.fromHours(36))  // returns 1.5
```

## Component Extraction

These functions extract a specific component of the duration as an integer remainder after extracting larger units.

### Milliseconds

- **Signature:** `duration.milliseconds(duration: Duration): Number`
- **Input:** One duration
- **Output:** The milliseconds component (0-999)
- **Purity:** Pure
- **Example:**

```
duration.milliseconds(duration.from(0, 2, 30, 45, 500))  // returns 500
```

### Seconds

- **Signature:** `duration.seconds(duration: Duration): Number`
- **Input:** One duration
- **Output:** The seconds component (0-59)
- **Purity:** Pure
- **Example:**

```
duration.seconds(duration.from(0, 2, 30, 45, 500))  // returns 45
```

### Minutes

- **Signature:** `duration.minutes(duration: Duration): Number`
- **Input:** One duration
- **Output:** The minutes component (0-59)
- **Purity:** Pure
- **Example:**

```
duration.minutes(duration.from(0, 2, 30, 45, 500))  // returns 30
```

### Hours

- **Signature:** `duration.hours(duration: Duration): Number`
- **Input:** One duration
- **Output:** The hours component after extracting days (0-23)
- **Purity:** Pure
- **Example:**

```
duration.hours(duration.from(0, 2, 30, 45, 500))  // returns 2
duration.hours(duration.fromHours(50))            // returns 2 (50 hours = 2 days + 2 hours)
```

### Days

- **Signature:** `duration.days(duration: Duration): Number`
- **Input:** One duration
- **Output:** The days component (unbounded integer)
- **Purity:** Pure
- **Example:**

```
duration.days(duration.fromHours(50))    // returns 2
duration.days(duration.fromDays(100))    // returns 100
```

## Comparison

### Compare

- **Signature:** `duration.compare(a: Duration, b: Duration): Number`
- **Input:** Two durations
- **Output:** -1 if a < b, 0 if a == b, 1 if a > b
- **Purity:** Pure
- **Example:**

```
duration.compare(duration.fromHours(1), duration.fromHours(2))     // returns -1
duration.compare(duration.fromHours(1), duration.fromMinutes(60))  // returns 0
duration.compare(duration.fromHours(2), duration.fromHours(1))     // returns 1
```

## Formatting

### Format

- **Signature:** `duration.format(duration: Duration, pattern: String): String`
- **Input:** One duration and one format pattern string
- **Output:** The formatted duration string
- **Purity:** Pure
- **Supported Patterns:**
  - `d` - days component (unbounded)
  - `dd` - days component, zero-padded to 2 digits
  - `H` - hours component (0-23)
  - `HH` - hours component, zero-padded to 2 digits
  - `m` - minutes component (0-59)
  - `mm` - minutes component, zero-padded to 2 digits
  - `s` - seconds component (0-59)
  - `ss` - seconds component, zero-padded to 2 digits
  - `S` - milliseconds component (0-999)
  - `SSS` - milliseconds component, zero-padded to 3 digits
- **Note:** Format patterns use component values (remainders), not totals. A duration of 50 hours formatted with "HH:mm" produces "02:00" (2 hours after extracting 2 days), not "50:00".
- **Example:**

```
duration.format(duration.from(2, 5, 30, 45, 500), "HH:mm:ss")       // "05:30:45"
duration.format(duration.from(2, 5, 30, 45, 500), "HH:mm:ss.SSS")   // "05:30:45.500"
duration.format(duration.fromHours(50), "d days HH hours")          // "2 days 02 hours"
```

## Timestamp Integration

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

## Type Checking

### Is Duration

- **Signature:** `is.duration(a: Any): Boolean`
- **Input:** Any value
- **Output:** True if the value is a Duration, false otherwise
- **Purity:** Pure
- **Example:**

```
is.duration(duration.fromHours(2))  // true
is.duration(time.now())             // false
is.duration(3600)                   // false
```