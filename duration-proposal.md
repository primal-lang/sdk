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

// Total conversions (returns fractional values)
duration.toMilliseconds(d)         // 9045500
duration.toSeconds(d)              // 9045.5
duration.toMinutes(d)              // 150.758...
duration.toHours(d)                // 2.512...
duration.toDays(d)                 // 0.104...

// Component extraction (returns integer values, like time.second for Timestamp)
duration.milliseconds(d)           // 500
duration.seconds(d)                // 45
duration.minutes(d)                // 30
duration.hours(d)                  // 2
duration.days(d)                   // 0
```

### Arithmetic

```primal
a = duration.fromHours(2)
b = duration.fromMinutes(30)

a + b                              // 2 hours 30 minutes
a - b                              // 1 hour 30 minutes
a * 3                              // 6 hours
a / 2                              // 1 hour
```

### Comparison

```primal
a = duration.fromHours(1)
b = duration.fromMinutes(90)

duration.compare(a, b)             // -1 (a < b)

// Duration supports comparison operators (joins OrderedType)
a < b                              // true
a == b                             // false
duration.fromHours(1) == duration.fromMinutes(60)  // true
```

### Formatting

```primal
d = duration.from(0, 2, 30, 45, 500)

duration.format(d)                 // "2:30:45.500"
duration.formatHuman(d)            // "2 hours, 30 minutes, 45 seconds"
```

### Parsing

```primal
duration.parse("2:30:45")          // 2 hours, 30 minutes, 45 seconds
duration.parse("PT2H30M")          // ISO 8601 duration format
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

### Duration Functions

| Function                    | Parameters           | Return   | Description                          |
| --------------------------- | -------------------- | -------- | ------------------------------------ |
| `duration.fromMilliseconds` | Number               | Duration | Create from milliseconds             |
| `duration.fromSeconds`      | Number               | Duration | Create from seconds                  |
| `duration.fromMinutes`      | Number               | Duration | Create from minutes                  |
| `duration.fromHours`        | Number               | Duration | Create from hours                    |
| `duration.fromDays`         | Number               | Duration | Create from days                     |
| `duration.from`             | Number x 5           | Duration | Create from d, h, m, s, ms           |
| `duration.toMilliseconds`   | Duration             | Number   | Total milliseconds (fractional)      |
| `duration.toSeconds`        | Duration             | Number   | Total seconds (fractional)           |
| `duration.toMinutes`        | Duration             | Number   | Total minutes (fractional)           |
| `duration.toHours`          | Duration             | Number   | Total hours (fractional)             |
| `duration.toDays`           | Duration             | Number   | Total days (fractional)              |
| `duration.milliseconds`     | Duration             | Number   | Milliseconds component (0-999)       |
| `duration.seconds`          | Duration             | Number   | Seconds component (0-59)             |
| `duration.minutes`          | Duration             | Number   | Minutes component (0-59)             |
| `duration.hours`            | Duration             | Number   | Hours component (0-23)               |
| `duration.days`             | Duration             | Number   | Days component (integer)             |
| `duration.compare`          | Duration, Duration   | Number   | Compare (-1, 0, 1)                   |
| `duration.format`           | Duration             | String   | Format as "H:MM:SS.mmm"              |
| `duration.formatHuman`      | Duration             | String   | Format as human-readable string      |
| `duration.parse`            | String               | Duration | Parse duration from string           |

### Timestamp Integration Functions

| Function        | Parameters           | Return    | Description                      |
| --------------- | -------------------- | --------- | -------------------------------- |
| `time.add`      | Timestamp, Duration  | Timestamp | Add duration to timestamp        |
| `time.subtract` | Timestamp, Duration  | Timestamp | Subtract duration from timestamp |
| `time.between`  | Timestamp, Timestamp | Duration  | Duration between two instants    |

### Type Checking Function

| Function      | Parameters | Return  | Description                              |
| ------------- | ---------- | ------- | ---------------------------------------- |
| `is.duration` | Any        | Boolean | True if argument is a Duration           |

**Total: 23 functions**

## Type System Integration

Duration joins the following type classes:

- **OrderedType** — enables comparison operators (`<`, `>`, `<=`, `>=`)
- **EquatableType** — enables equality operators (`==`, `!=`)
- **HashableType** — enables use as map keys and set elements
- **ArithmeticType** — enables arithmetic operators (`+`, `-`, `*`, `/`)

Note: For `*` and `/`, the right operand must be a Number (scalar). Division by zero throws `DivisionByZeroError`. Subtraction resulting in a negative duration throws `InvalidValueError`.

## Implementation Notes

### Internal Representation

Store duration as a single integer representing **microseconds**. This provides:

- Sufficient precision for most use cases (microsecond granularity)
- Simple arithmetic operations
- No floating-point precision issues
- Direct mapping to Dart's `Duration` class (which uses microseconds internally)

Note: The API uses milliseconds as the smallest unit for simplicity, but internal storage uses microseconds for Dart compatibility.

### String Representation

When a Duration is converted to a string (via `to.string` or printed), it uses the format:

- `"Duration(2:30:45.500)"` for 2 hours, 30 minutes, 45 seconds, 500 milliseconds
- `"Duration(0:00:00.000)"` for zero duration

### Dart Mapping

```dart
class DurationType extends Type {
  const DurationType();

  @override
  String toString() => 'Duration';
}

class DurationTerm extends ValueTerm<Duration> {
  const DurationTerm(super.value);

  @override
  Type get type => const DurationType();

  @override
  String toString() {
    final int hours = value.inHours;
    final int minutes = value.inMinutes.remainder(60);
    final int seconds = value.inSeconds.remainder(60);
    final int milliseconds = value.inMilliseconds.remainder(1000);
    return 'Duration($hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')})';
  }
}
```

### Parameter Type

The parameter class requires a new constructor:

```dart
const Parameter.duration(String name)
  : this._(name: name, type: const DurationType());
```

### Error Handling

- `d / 0` — throws `DivisionByZeroError`
- `duration.parse("invalid")` — throws `ParseError` with message "Invalid duration format: 'invalid'"
- `duration.fromHours(-1)` — throws `InvalidValueError` with message "Duration cannot be negative"
- `a - b` where `b > a` — throws `InvalidValueError` with message "Duration cannot be negative"
- Type mismatches — throws `InvalidArgumentTypesError`
- Overflow (duration exceeding ~292,000 years) — throws `InvalidValueError`

## Examples

### Timing Operations

```primal
// Measure elapsed time
start = time.now()
result = list.reduce([1, 2, 3, 4, 5], 0, num.add)
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
total = list.reduce(shifts, duration.fromMilliseconds(0), (a, b) => a + b)
console.write("Total hours: " + to.string(duration.toHours(total)))
```

### Type Checking

```primal
d = duration.fromHours(2)
is.duration(d)              // true
is.duration(time.now())     // false
is.duration(3600)           // false
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
- **Platform support** — works on both CLI and web (Duration uses no I/O; verified that Dart's `Duration` class works in dart2js)
- **Breaking change risk** — minimal; users who defined custom `time.add` or `time.subtract` functions will see `CannotRedefineStandardLibraryError`

## Documentation Requirements

This feature requires the following documentation updates:

1. Create `docs/reference/duration.md` with full function documentation
2. Add Duration link to `docs/reference.md`
3. Add Duration to the types list in `docs/primal.md` under "System" types
4. Update `docs/reference/casting.md` to include `is.duration`
5. Update `docs/reference/operators.md` to list Duration under arithmetic and comparison operators

## Decisions (Resolved)

1. **Months/years support:** No. Months and years have variable lengths (28-31 days, 365-366 days). Duration represents fixed time spans only.

2. **Negative durations:** No. Durations represent non-negative time spans. Construction functions throw `InvalidValueError` for negative inputs. Use `time.subtract` to move timestamps backward.

3. **Fractional input:** Yes. Construction functions accept fractional numbers: `duration.fromHours(2.5)` creates a duration of 2 hours and 30 minutes. The value is converted to microseconds internally.

4. **Component vs total extraction:** Component functions (`duration.seconds`, etc.) return integer parts as with `time.second` for Timestamp. Total functions (`duration.toSeconds`, etc.) return fractional totals.

## Test Requirements

The implementation must include tests for:

### Happy Path
- All 23 functions with valid inputs
- Roundtrip: `time.between(a, b)` then `time.add(a, duration)` returns `b`
- Arithmetic operators: `+`, `-`, `*`, `/`
- Comparison operators: `<`, `>`, `<=`, `>=`, `==`, `!=`
- Use as map key and set element (HashableType)

### Edge Cases
- Zero duration: `duration.fromMilliseconds(0)` behavior in all operations
- Maximum precision: microsecond-level accuracy
- Large durations: near overflow limits (~292,000 years)
- Fractional inputs: `duration.fromSeconds(1.5)`

### Error Cases
- `d / 0` throws `DivisionByZeroError`
- `duration.parse("invalid")` throws `ParseError`
- Negative input (e.g., `duration.fromHours(-1)`) throws `InvalidValueError`
- Subtraction resulting in negative (e.g., `a - b` where `b > a`) throws `InvalidValueError`
- Type mismatches for all functions throw `InvalidArgumentTypesError`
- Wrong argument count throws `InvalidArgumentCountError`

### Integration
- `list.reduce` with `+` operator
- `list.map` with duration functions
- Composition with Timestamp functions
