---
title: Duration
tags:
  - reference
  - time
sources:
  - lib/compiler/library/duration/
---

# Duration

**TLDR**: Functions for creating, converting, formatting, and comparing durations (time spans) with support for arithmetic and timestamp integration.

Number of functions: 18

## Creation

### From Milliseconds

- **Signature:** `duration.fromMilliseconds(a: Number): Duration`
- **Input:** A number representing the number of milliseconds.
- **Output:** A duration instance representing the specified number of milliseconds.
- **Constraints:** Throws `NegativeDurationError` if input is negative
- **Purity:** Pure
- **Example:**

```
duration.fromMilliseconds(5000) // returns a duration of 5000 milliseconds
```

### From Seconds

- **Signature:** `duration.fromSeconds(a: Number): Duration`
- **Input:** A number representing the number of seconds.
- **Output:** A duration instance representing the specified number of seconds.
- **Constraints:** Throws `NegativeDurationError` if input is negative
- **Purity:** Pure
- **Example:**

```
duration.fromSeconds(3600) // returns a duration of 3600 seconds
```

### From Minutes

- **Signature:** `duration.fromMinutes(a: Number): Duration`
- **Input:** A number representing the number of minutes.
- **Output:** A duration instance representing the specified number of minutes.
- **Constraints:** Throws `NegativeDurationError` if input is negative
- **Purity:** Pure
- **Example:**

```
duration.fromMinutes(90) // returns a duration of 90 minutes
```

### From Hours

- **Signature:** `duration.fromHours(a: Number): Duration`
- **Input:** A number representing the number of hours.
- **Output:** A duration instance representing the specified number of hours.
- **Constraints:** Throws `NegativeDurationError` if input is negative
- **Purity:** Pure
- **Example:**

```
duration.fromHours(24) // returns a duration of 24 hours
```

### From Days

- **Signature:** `duration.fromDays(a: Number): Duration`
- **Input:** A number representing the number of days.
- **Output:** A duration instance representing the specified number of days.
- **Constraints:** Throws `NegativeDurationError` if input is negative
- **Purity:** Pure
- **Example:**

```
duration.fromDays(7) // returns a duration of 7 days
```

### From

- **Signature:** `duration.from(a: Number, b: Number, c: Number, d: Number, e: Number): Duration`
- **Input:** Five numbers representing days (a), hours (b), minutes (c), seconds (d), and milliseconds (e).
- **Output:** A duration instance created from the specified components.
- **Constraints:** Validates left-to-right; throws `NegativeDurationError` at first negative component (includes component name and value in error message)
- **Purity:** Pure
- **Example:**

```
duration.from(1, 2, 30, 0, 0) // returns a duration of 1 day, 2 hours, 30 minutes
```

## Total Conversion

These functions return the total duration converted to the specified unit as a fractional number.

### To Milliseconds

- **Signature:** `duration.toMilliseconds(a: Duration): Number`
- **Input:** A duration instance.
- **Output:** The total duration converted to milliseconds.
- **Purity:** Pure
- **Example:**

```
duration.toMilliseconds(duration.fromSeconds(2)) // returns 2000
```

### To Seconds

- **Signature:** `duration.toSeconds(a: Duration): Number`
- **Input:** A duration instance.
- **Output:** The total duration converted to seconds.
- **Purity:** Pure
- **Example:**

```
duration.toSeconds(duration.fromMinutes(5)) // returns 300
```

### To Minutes

- **Signature:** `duration.toMinutes(a: Duration): Number`
- **Input:** A duration instance.
- **Output:** The total duration converted to minutes.
- **Purity:** Pure
- **Example:**

```
duration.toMinutes(duration.fromHours(2)) // returns 120
```

### To Hours

- **Signature:** `duration.toHours(a: Duration): Number`
- **Input:** A duration instance.
- **Output:** The total duration converted to hours.
- **Purity:** Pure
- **Example:**

```
duration.toHours(duration.fromDays(1)) // returns 24
```

### To Days

- **Signature:** `duration.toDays(a: Duration): Number`
- **Input:** A duration instance.
- **Output:** The total duration converted to days.
- **Purity:** Pure
- **Example:**

```
duration.toDays(duration.fromHours(48)) // returns 2
```

## Component Extraction

These functions extract a specific component of the duration as an integer remainder after extracting larger units.

### Milliseconds

- **Signature:** `duration.milliseconds(a: Duration): Number`
- **Input:** A duration instance.
- **Output:** The milliseconds component of the duration (0-999).
- **Purity:** Pure
- **Example:**

```
duration.milliseconds(duration.from(0, 0, 0, 1, 500)) // returns 500
```

### Seconds

- **Signature:** `duration.seconds(a: Duration): Number`
- **Input:** A duration instance.
- **Output:** The seconds component of the duration (0-59).
- **Purity:** Pure
- **Example:**

```
duration.seconds(duration.from(0, 0, 1, 30, 0)) // returns 30
```

### Minutes

- **Signature:** `duration.minutes(a: Duration): Number`
- **Input:** A duration instance.
- **Output:** The minutes component of the duration (0-59).
- **Purity:** Pure
- **Example:**

```
duration.minutes(duration.from(0, 1, 45, 0, 0)) // returns 45
```

### Hours

- **Signature:** `duration.hours(a: Duration): Number`
- **Input:** A duration instance.
- **Output:** The hours component of the duration (0-23).
- **Purity:** Pure
- **Example:**

```
duration.hours(duration.from(1, 12, 0, 0, 0)) // returns 12
```

### Days

- **Signature:** `duration.days(a: Duration): Number`
- **Input:** A duration instance.
- **Output:** The days component of the duration.
- **Purity:** Pure
- **Example:**

```
duration.days(duration.from(2, 5, 30, 0, 0)) // returns 2
```

## Comparison

### Compare

- **Signature:** `duration.compare(a: Duration, b: Duration): Number`
- **Input:** Two duration instances.
- **Output:** 1 if the first duration is longer, -1 if shorter, 0 if equal.
- **Purity:** Pure
- **Example:**

```
duration.compare(duration.fromHours(2), duration.fromHours(1)) // returns 1
```

## Formatting

### Format

- **Signature:** `duration.format(a: Duration, b: String): String`
- **Input:** A duration and a format pattern string.
- **Output:** The duration formatted according to the pattern.
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
duration.format(duration.from(1, 2, 30, 0, 0), "d:HH:mm:ss") // returns "1:02:30:00"
```