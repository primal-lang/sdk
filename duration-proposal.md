# Duration Type Proposal

## Overview

A **Duration** type represents a span of time, independent of any specific point in time. Unlike `Timestamp` which represents an instant (e.g., "January 15, 2025 at 10:30 AM"), a `Duration` represents a length of time (e.g., "2 hours and 30 minutes").

## Motivation

Currently, Primal has `Timestamp` for working with dates and times, but lacks a dedicated type for representing time spans. This leads to:

1. **Awkward arithmetic** — subtracting two timestamps yields a number (milliseconds), losing semantic meaning
2. **Manual conversions** — users must manually convert between units (seconds, minutes, hours, days)
3. **No type safety** — a number representing "5 hours" is indistinguishable from "5 apples"

## Syntax

### Construction

```primal
// Named constructors for each unit
duration.fromMilliseconds(500)     // 500 milliseconds
duration.fromSeconds(30)           // 30 seconds
duration.fromMinutes(5)            // 5 minutes
duration.fromHours(2)              // 2 hours
duration.fromDays(7)               // 7 days

// Combined construction (days, hours, minutes, seconds, milliseconds)
duration.from(0, 2, 30, 0, 0)        // 2 hours, 30 minutes
duration.from(1, 0, 0, 0, 0)         // 1 day
duration.from(0, 1, 30, 45, 500)     // 1 hour, 30 minutes, 45 seconds, 500 milliseconds
```

### Extraction

```primal
d = duration.from(0, 2, 30, 45, 500)    // 2 hours, 30 minutes, 45 seconds, 500 milliseconds

duration.toMilliseconds(d)         // 9045500
duration.toSeconds(d)              // 9045.5
duration.toMinutes(d)              // 150.758...
duration.toHours(d)                // 2.512...
duration.toDays(d)                 // 0.104...

// Component extraction
duration.milliseconds(d)       // 500
duration.seconds(d)            // 45.5
duration.minutes(d)            // 30
duration.hours(d)              // 2
duration.days(d)               // 0
```

### Comparison

```primal
a = duration.fromHours(1)
b = duration.fromMinutes(90)

duration.compare(a, b)             // -1 (a < b)
```

### Integration with Timestamp

```primal
now = time.now()

// Add/subtract duration from timestamp
time.add(now, duration.fromDays(7))       // one week from now
time.subtract(now, duration.fromHours(3)) // 3 hours ago

// Get duration between timestamps
start = time.fromIso("2025-01-01T00:00:00Z")
end = time.fromIso("2025-01-08T00:00:00Z")
time.between(start, end)                  // 7 days
```

## Standard Library Functions Summary

| Function                    | Parameters           | Return   | Description                    |
| --------------------------- | -------------------- | -------- | ------------------------------ |
| `duration.fromMilliseconds` | Integer              | Duration | Create from milliseconds       |
| `duration.fromSeconds`      | Integer              | Duration | Create from seconds            |
| `duration.fromMinutes`      | Integer              | Duration | Create from minutes            |
| `duration.fromHours`        | Integer              | Duration | Create from hours              |
| `duration.fromDays`         | Integer              | Duration | Create from days               |
| `duration.from`             | Integer x 5          | Duration | Create from d, h, m, s, ms     |
| `time.between`              | Timestamp, Timestamp | Duration | Duration between two instants  |
| `duration.toMilliseconds`   | Duration             | Number   | Total milliseconds             |
| `duration.toSeconds`        | Duration             | Number   | Total seconds                  |
| `duration.toMinutes`        | Duration             | Number   | Total minutes                  |
| `duration.toHours`          | Duration             | Number   | Total hours                    |
| `duration.toDays`           | Duration             | Number   | Total days                     |
| `duration.milliseconds`     | Duration             | Number   | Milliseconds component         |
| `duration.seconds`          | Duration             | Number   | Seconds component              |
| `duration.minutes`          | Duration             | Number   | Minutes component              |
| `duration.hours`            | Duration             | Number   | Hours component                |
| `duration.days`             | Duration             | Number   | Days component                 |
| `duration.compare`          | Duration, Duration   | Number   | Compare (-1, 0, 1)             |
| `duration.isNegative`       | Duration             | Boolean  | Check if negative              |
| `duration.isZero`           | Duration             | Boolean  | Check if zero                  |
| `duration.isPositive`       | Duration             | Boolean  | Check if positive              |

**Total: 20 functions**

## Implementation Notes

### Internal Representation

Store duration as a single integer representing **microseconds** (or milliseconds for simplicity). This provides:

- Sufficient precision for most use cases
- Simple arithmetic operations
- No floating-point precision issues
- Direct mapping to Dart's `Duration` class

### Dart Mapping

```dart
class DurationType extends Type {
  const DurationType();

  @override
  String get name => 'Duration';
}

class DurationTerm extends Term {
  final Duration value; // Dart's built-in Duration

  const DurationTerm(this.value);

  @override
  Term reduce() => this;

  @override
  String toString() => formatDuration(value);
}
```

### Error Handling

- `duration.divide(d, 0)` — throws `DivisionByZeroError`
- `duration.parse("invalid")` — throws `ParseError`
- Type mismatches — throws `InvalidArgumentTypesError`

## Examples

### Timing Operations

```primal
// Measure elapsed time
start = time.now()
result = someExpensiveComputation()
end = time.now()
elapsed = time.between(start, end)
console.write("Took: " + duration.format(elapsed))
```

### Scheduling

```primal
// Calculate next run time
interval = duration.fromHours(6)
lastRun = time.fromIso("2025-01-15T10:00:00Z")
nextRun = time.add(lastRun, interval)
```

### Time Remaining

```primal
// Countdown timer
deadline = time.fromIso("2025-12-31T23:59:59Z")
remaining = time.between(time.now(), deadline)
console.write("Time remaining: " + duration.formatHuman(remaining))
```

### Working Hours Calculation

```primal
// Calculate total work time
shifts = [
  duration.from(0, 8, 30, 0, 0),   // 8h 30m
  duration.from(0, 7, 45, 0, 0),   // 7h 45m
  duration.from(0, 9, 0, 0, 0),    // 9h
]
total = list.reduce(shifts, duration.zero, duration.add)
console.write("Total hours: " + to.string(duration.toHours(total)))
```

## Alternatives Considered

### 1. Use Numbers Directly

**Rejected** — loses type safety and semantic meaning. A number `3600` could mean 3600 seconds, milliseconds, or anything else.

### 2. Extend Timestamp

**Rejected** — conceptually different. A timestamp is a point in time; a duration is a span. Mixing them leads to confusion.

### 3. Use Maps/Records

**Rejected** — verbose and error-prone:

```primal
// Awkward without Duration type
d = { hours: 2, minutes: 30, seconds: 0 }
```

## Compatibility

- **Backward compatible** — new type, no changes to existing functionality
- **Timestamp integration** — extends `time.*` namespace with duration support
- **Platform support** — works on both CLI and web (no I/O required)

## Open Questions

1. Should we support months/years? (Suggested: no, as they have variable lengths)
2. Should negative durations be allowed? (Suggested: yes, for representing "time ago")
