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
// Given a duration of 2 hours, 30 minutes, 45 seconds, 500 milliseconds
example() =
  let d = duration.from(0, 2, 30, 45, 500) in
  [
    // Total conversions (returns fractional values)
    duration.toMilliseconds(d),    // 9045500
    duration.toSeconds(d),         // 9045.5
    duration.toMinutes(d),         // 150.758...
    duration.toHours(d),           // 2.512...
    duration.toDays(d),            // 0.104...

    // Component extraction (returns integer remainder after extracting larger units)
    duration.milliseconds(d),      // 500 (0-999)
    duration.seconds(d),           // 45  (0-59)
    duration.minutes(d),           // 30  (0-59)
    duration.hours(d),             // 2   (unbounded, not 0-23)
    duration.days(d)               // 0   (unbounded)
  ]

// For a duration of 50 hours:
largeExample() =
  let d = duration.fromHours(50) in
  [duration.days(d), duration.hours(d)]  // [2, 2] (50 hours = 2 days + 2 hours)
```

### Arithmetic

```primal
arithmetic() =
  let a = duration.fromHours(2) in
  let b = duration.fromMinutes(30) in
  [a + b, a - b]                   // [2h30m, 1h30m]
```

### Comparison

```primal
comparison() =
  let a = duration.fromHours(1) in
  let b = duration.fromMinutes(90) in
  [
    duration.compare(a, b),        // -1 (a < b)
    a < b,                         // true (Duration joins OrderedType)
    a == b,                        // false
    duration.fromHours(1) == duration.fromMinutes(60)  // true
  ]
```

### Formatting

```primal
formatting() =
  let d = duration.from(2, 5, 30, 45, 500) in  // 2 days, 5 hours, 30 minutes, 45 seconds, 500 milliseconds
  [
    duration.format(d, "HH:mm:ss"),                // "05:30:45"
    duration.format(d, "HH:mm:ss.SSS"),            // "05:30:45.500"
  ]
```

**Supported Patterns:**

- `d` — days
- `H` / `HH` — hours component (0-23)
- `m` / `mm` — minutes component (0-59)
- `s` / `ss` — seconds component (0-59)
- `S` / `SSS` — milliseconds component (0-999)

### Integration with Timestamp

```primal
timestampIntegration() =
  let now = time.now() in
  let oneWeekLater = time.add(now, duration.fromDays(7)) in
  let threeHoursAgo = time.subtract(now, duration.fromHours(3)) in
  [oneWeekLater, threeHoursAgo]

durationBetween() =
  let start = time.fromIso("2025-01-01T00:00:00Z") in
  let end = time.fromIso("2025-01-08T00:00:00Z") in
  time.between(start, end)                // 7 days
```

## Standard Library Functions Summary

### Duration Functions

| Function                    | Parameters         | Return   | Description                       |
| --------------------------- | ------------------ | -------- | --------------------------------- |
| `duration.fromMilliseconds` | Number             | Duration | Create from milliseconds          |
| `duration.fromSeconds`      | Number             | Duration | Create from seconds               |
| `duration.fromMinutes`      | Number             | Duration | Create from minutes               |
| `duration.fromHours`        | Number             | Duration | Create from hours                 |
| `duration.fromDays`         | Number             | Duration | Create from days                  |
| `duration.from`             | Number x 5         | Duration | Create from d, h, m, s, ms        |
| `duration.toMilliseconds`   | Duration           | Number   | Total milliseconds (fractional)   |
| `duration.toSeconds`        | Duration           | Number   | Total seconds (fractional)        |
| `duration.toMinutes`        | Duration           | Number   | Total minutes (fractional)        |
| `duration.toHours`          | Duration           | Number   | Total hours (fractional)          |
| `duration.toDays`           | Duration           | Number   | Total days (fractional)           |
| `duration.milliseconds`     | Duration           | Number   | Milliseconds component (0-999)    |
| `duration.seconds`          | Duration           | Number   | Seconds component (0-59)          |
| `duration.minutes`          | Duration           | Number   | Minutes component (0-59)          |
| `duration.hours`            | Duration           | Number   | Hours component (0-23, unbounded) |
| `duration.days`             | Duration           | Number   | Days component (unbounded)        |
| `duration.compare`          | Duration, Duration | Number   | Compare (-1, 0, 1)                |
| `duration.format`           | Duration, String   | String   | Format with pattern string        |

### Timestamp Integration Functions

| Function        | Parameters           | Return    | Description                      |
| --------------- | -------------------- | --------- | -------------------------------- |
| `time.add`      | Timestamp, Duration  | Timestamp | Add duration to timestamp        |
| `time.subtract` | Timestamp, Duration  | Timestamp | Subtract duration from timestamp |
| `time.between`  | Timestamp, Timestamp | Duration  | Duration between two instants    |

### Type Checking Function

| Function      | Parameters | Return  | Description                    |
| ------------- | ---------- | ------- | ------------------------------ |
| `is.duration` | Any        | Boolean | True if argument is a Duration |

## Type System Integration

Duration joins the following type classes:

- **OrderedType** — enables comparison operators (`<`, `>`, `<=`, `>=`)
- **EquatableType** — enables equality operators (`==`, `!=`)
- **HashableType** — enables use as map keys and set elements
- **AddableType** — enables `+` operator
- **SubtractableType** — enables `-` operator

Note: Subtraction resulting in a negative duration throws `InvalidValueError`. This differs from Number subtraction, which allows negative results. The rationale is that Duration represents a non-negative span of time; use `time.subtract` to move timestamps backward.

## Implementation Notes

### Internal Representation

Store duration as a single integer representing **microseconds**. This provides:

- Sufficient precision for most use cases (microsecond granularity)
- Simple arithmetic operations
- No floating-point precision issues
- Direct mapping to Dart's `Duration` class (which uses microseconds internally)

Note: The API uses milliseconds as the smallest unit for simplicity, but internal storage uses microseconds for Dart compatibility. Fractional inputs are truncated to microseconds (e.g., `duration.fromMilliseconds(1.5)` stores 1500 microseconds).

### String Representation

When a Duration is converted to a string (via `to.string` or printed), it uses the format:

- `"0d 2h 30m 45s 500ms"` for 2 hours, 30 minutes, 45 seconds, 500 milliseconds
- `"0d 0h 0m 0s 0ms"` for zero duration
- `"2d 2h 0m 0s 0ms"` for 50 hours (2 days + 2 hours)
- `"100d 0h 0m 0s 0ms"` for 100 days

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
    final int days = value.inDays;
    final int hours = value.inHours.remainder(24);
    final int minutes = value.inMinutes.remainder(60);
    final int seconds = value.inSeconds.remainder(60);
    final int milliseconds = value.inMilliseconds.remainder(1000);
    return '${days}d ${hours}h ${minutes}m ${seconds}s ${milliseconds}ms';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DurationTerm && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
```

### Parameter Type

The parameter class requires a new constructor:

```dart
const Parameter.duration(String name)
  : this._(name: name, type: const DurationType());
```

### Runtime Updates Required

The following runtime files must be updated:

1. **`lib/compiler/runtime/term.dart`** — Add Duration handling to `ValueTerm.from()`:

   ```dart
   } else if (value is Duration) {
     return DurationTerm(value);
   }
   ```

2. **`lib/compiler/runtime/runtime.dart`** — Add Duration handling to `format()`:

   ```dart
   } else if (value is Duration) {
     final int days = value.inDays;
     final int hours = value.inHours.remainder(24);
     final int minutes = value.inMinutes.remainder(60);
     final int seconds = value.inSeconds.remainder(60);
     final int milliseconds = value.inMilliseconds.remainder(1000);
     return '"${days}d ${hours}h ${minutes}m ${seconds}s ${milliseconds}ms"';
   }
   ```

3. **`lib/compiler/models/type.dart`** — Add `DurationType()` to:
   - `OrderedType.memberTypes`
   - `EquatableType.memberTypes`
   - `HashableType.memberTypes`
   - `AddableType.memberTypes`
   - `SubtractableType.memberTypes`

4. **Operator implementations** — Add explicit `DurationTerm` handling to:
   - `lib/compiler/library/operators/operator_add.dart`
   - `lib/compiler/library/operators/operator_sub.dart`
   - `lib/compiler/library/comparison/comp_lt.dart`
   - `lib/compiler/library/comparison/comp_le.dart`
   - `lib/compiler/library/comparison/comp_gt.dart`
   - `lib/compiler/library/comparison/comp_ge.dart`
   - `lib/compiler/library/comparison/comp_eq.dart`
   - `lib/compiler/library/comparison/comp_neq.dart`

   Note: Type classes are used for parameter validation only. Runtime dispatch uses explicit type checks (e.g., `if (a is DurationTerm && b is DurationTerm)`).

### Error Handling

- `duration.fromHours(-1)` — throws `InvalidValueError` with message "Duration cannot be negative"
- `a - b` where `b > a` — throws `InvalidValueError` with message "Duration cannot be negative"
- Type mismatches — throws `InvalidArgumentTypesError`
- Overflow (duration exceeding ~292,000 years) — throws `InvalidValueError`

## Examples

### Timing Operations

```primal
// Measure elapsed time
measureElapsed() =
  let start = time.now() in
  let end = time.now() in
  let elapsed = time.between(start, end) in
  console.write("Took: " + to.string(elapsed))
```

### Scheduling

```primal
// Calculate next run time
calculateNextRun() =
  let interval = duration.fromHours(6) in
  let lastRun = time.fromIso("2025-01-15T10:00:00Z") in
  time.add(lastRun, interval)
```

### Time Remaining

```primal
// Countdown timer
showTimeRemaining() =
  let deadline = time.fromIso("2025-12-31T23:59:59Z") in
  let remaining = time.between(time.now(), deadline) in
  console.write("Time remaining: " + to.string(remaining))
```

### Working Hours Calculation

```primal
// Calculate total work time
totalWorkHours() =
  let shifts = [
    duration.from(0, 8, 30, 0, 0),   // 8h 30m
    duration.from(0, 7, 45, 0, 0),   // 7h 45m
    duration.from(0, 9, 0, 0, 0)     // 9h
  ] in
  let total = list.reduce(shifts, duration.fromMilliseconds(0), (a, b) => a + b) in
  console.write("Total hours: " + to.string(duration.toHours(total)))
```

### Type Checking

```primal
typeChecks() =
  let d = duration.fromHours(2) in
  [
    is.duration(d),             // true
    is.duration(time.now()),    // false
    is.duration(3600)           // false
  ]
```

## Compatibility

- **Backward compatible** — new type, no changes to existing functionality
- **Timestamp integration** — extends `time.*` namespace with duration support
- **Platform support** — works on both CLI and web (Duration uses no I/O; verified that Dart's `Duration` class works in dart2js)
- **BREAKING CHANGE** — users who defined custom `time.add`, `time.subtract`, or `time.between` functions will receive `CannotRedefineStandardLibraryError` at compile time. This must be clearly documented in release notes.

## Documentation Requirements

This feature requires the following documentation updates:

1. Create `docs/reference/duration.md` with full function documentation
2. Add Duration link to `docs/reference.md`
3. Add Duration to the types list in `docs/primal.md` under "System" types
4. Update `docs/reference/casting.md` to include `is.duration`
5. Update `docs/reference/operators.md` to list Duration under additive (`+`, `-`) and comparison operators

## Decisions (Resolved)

1. **Months/years support:** No. Months and years have variable lengths (28-31 days, 365-366 days). Duration represents fixed time spans only.

2. **Negative durations:** No. Durations represent non-negative time spans. Construction functions throw `InvalidValueError` for negative inputs. Use `time.subtract` to move timestamps backward.

3. **Fractional input:** Yes. Construction functions accept fractional numbers: `duration.fromHours(2.5)` creates a duration of 2 hours and 30 minutes. The value is converted to microseconds internally.

4. **Component vs total extraction:** Component functions (`duration.seconds`, etc.) return integer parts as with `time.second` for Timestamp. Total functions (`duration.toSeconds`, etc.) return fractional totals.

## Test Requirements

The implementation must include tests for:

### Happy Path

- All 21 functions with valid inputs
- `to.string(duration)` produces expected format
- Roundtrip: `time.between(a, b)` then `time.add(a, duration)` returns `b`
- Arithmetic operators: `+`, `-`
- Comparison operators: `<`, `>`, `<=`, `>=`, `==`, `!=`
- Use as map key and set element (HashableType)

### Edge Cases

- Zero duration: `duration.fromMilliseconds(0)` behavior in all operations
- Maximum precision: microsecond-level accuracy
- Large durations: near overflow limits (~292,000 years)
- Fractional inputs: `duration.fromSeconds(1.5)`

### Error Cases

- Negative input (e.g., `duration.fromHours(-1)`) throws `InvalidValueError`
- Subtraction resulting in negative (e.g., `a - b` where `b > a`) throws `InvalidValueError`
- Type mismatches for all functions throw `InvalidArgumentTypesError`
- Wrong argument count throws `InvalidArgumentCountError`

### Integration

- `list.reduce` with `+` operator
- `list.map` with duration functions
- Composition with Timestamp functions
