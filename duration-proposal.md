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
// All components must be non-negative; throws NegativeDurationError otherwise
duration.from(0, 2, 30, 0, 0)        // 2 hours, 30 minutes
duration.from(1, 0, 0, 0, 0)         // 1 day
duration.from(0, 1, 30, 45, 500)     // 1 hour, 30 minutes, 45 seconds, 500 milliseconds
```

### Extraction

```primal
// Given a duration of 2 hours, 30 minutes, 45 seconds, 500 milliseconds
extractionExample() =
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
    duration.hours(d),             // 2   (0-23, remainder after extracting days)
    duration.days(d)               // 0   (unbounded)
  ]

// For a duration of 50 hours:
fiftyHoursExample() =
  let d = duration.fromHours(50) in
  [duration.days(d), duration.hours(d)]  // [2, 2] (50 hours = 2 days + 2 hours)
```

### Arithmetic

```primal
durationArithmetic() =
  let a = duration.fromHours(2) in
  let b = duration.fromMinutes(30) in
  [a + b, a - b]                   // Duration values; to.string yields ["0d 2h 30m 00s 000ms", "0d 1h 30m 00s 000ms"]
```

### Comparison

```primal
durationComparison() =
  let a = duration.fromHours(1) in
  let b = duration.fromMinutes(90) in
  [
    duration.compare(a, b),        // -1 (a < b)
    a < b,                         // true (Duration joins OrderedType)
    a == b,                        // false (Duration joins EquatableType)
    a != b,                        // true
    duration.fromHours(1) == duration.fromMinutes(60)  // true
  ]
```

### Formatting

```primal
durationFormatting() =
  let d = duration.from(2, 5, 30, 45, 500) in  // 2 days, 5 hours, 30 minutes, 45 seconds, 500 milliseconds
  [
    duration.format(d, "HH:mm:ss"),             // "05:30:45"
    duration.format(d, "HH:mm:ss.SSS"),         // "05:30:45.500"
  ]
```

**Supported Patterns:**

- `d` / `dd` — days component (unbounded; `dd` zero-pads to 2 digits)
- `H` / `HH` — hours component after extracting days (0-23; `HH` zero-pads)
- `m` / `mm` — minutes component (0-59; `mm` zero-pads)
- `s` / `ss` — seconds component (0-59; `ss` zero-pads)
- `S` / `SSS` — milliseconds component (0-999; `SSS` zero-pads to 3 digits)

Note: Format patterns use **component** values (remainders after extracting larger units), not totals. For example, a duration of 50 hours formatted with `"HH:mm"` produces `"02:00"` (2 hours after extracting 2 days), not `"50:00"`. Use `duration.toHours(d)` for total hours.

### Integration with Timestamp

```primal
timestampIntegration() =
  let now = time.now() in
  let oneWeekLater = time.add(now, duration.fromDays(7)) in
  let threeHoursAgo = time.subtract(now, duration.fromHours(3)) in
  [oneWeekLater, threeHoursAgo]

durationBetweenTimestamps() =
  let start = time.fromIso("2025-01-01T00:00:00Z") in
  let end = time.fromIso("2025-01-08T00:00:00Z") in
  time.between(start, end)                // 7 days (argument order doesn't matter; returns absolute duration)
```

## Standard Library Functions Summary

### Duration Functions

| Function                    | Parameters         | Return   | Purity | Description                       |
| --------------------------- | ------------------ | -------- | ------ | --------------------------------- |
| `duration.fromMilliseconds` | Number             | Duration | Pure   | Create from milliseconds          |
| `duration.fromSeconds`      | Number             | Duration | Pure   | Create from seconds               |
| `duration.fromMinutes`      | Number             | Duration | Pure   | Create from minutes               |
| `duration.fromHours`        | Number             | Duration | Pure   | Create from hours                 |
| `duration.fromDays`         | Number             | Duration | Pure   | Create from days                  |
| `duration.from`             | Number x 5         | Duration | Pure   | Create from d, h, m, s, ms        |
| `duration.toMilliseconds`   | Duration           | Number   | Pure   | Total milliseconds (fractional)   |
| `duration.toSeconds`        | Duration           | Number   | Pure   | Total seconds (fractional)        |
| `duration.toMinutes`        | Duration           | Number   | Pure   | Total minutes (fractional)        |
| `duration.toHours`          | Duration           | Number   | Pure   | Total hours (fractional)          |
| `duration.toDays`           | Duration           | Number   | Pure   | Total days (fractional)           |
| `duration.milliseconds`     | Duration           | Number   | Pure   | Milliseconds component (0-999)    |
| `duration.seconds`          | Duration           | Number   | Pure   | Seconds component (0-59)          |
| `duration.minutes`          | Duration           | Number   | Pure   | Minutes component (0-59)          |
| `duration.hours`            | Duration           | Number   | Pure   | Hours component after days (0-23) |
| `duration.days`             | Duration           | Number   | Pure   | Days component (unbounded)        |
| `duration.compare`          | Duration, Duration | Number   | Pure   | Compare (-1, 0, 1)                |
| `duration.format`           | Duration, String   | String   | Pure   | Format with pattern string        |

### Timestamp Integration Functions

| Function        | Parameters           | Return    | Purity | Description                                                  |
| --------------- | -------------------- | --------- | ------ | ------------------------------------------------------------ |
| `time.add`      | Timestamp, Duration  | Timestamp | Pure   | Add duration to timestamp                                    |
| `time.subtract` | Timestamp, Duration  | Timestamp | Pure   | Subtract duration from timestamp                             |
| `time.between`  | Timestamp, Timestamp | Duration  | Pure   | Absolute duration between two instants (always non-negative) |

### Type Checking Function

| Function      | Parameters | Return  | Purity | Description                    |
| ------------- | ---------- | ------- | ------ | ------------------------------ |
| `is.duration` | Any        | Boolean | Pure   | True if argument is a Duration |

## Type System Integration

Duration joins the following type classes:

- **OrderedType** — enables comparison operators (`<`, `>`, `<=`, `>=`)
- **EquatableType** — enables equality operators (`==`, `!=`)
- **HashableType** — enables use as map keys and set elements
- **AddableType** — enables `+` operator (Duration + Duration)
- **SubtractableType** — enables `-` operator (Duration - Duration)

Note: Subtraction resulting in a negative duration throws `NegativeDurationError`. This differs from Number subtraction, which allows negative results. The rationale is that Duration represents a non-negative span of time; use `time.subtract` to move timestamps backward.

## Implementation Notes

### Internal Representation

Store duration as a single integer representing **microseconds**. This provides:

- Sufficient precision for most use cases (microsecond granularity)
- Simple arithmetic operations
- No floating-point precision issues
- Direct mapping to Dart's `Duration` class (which uses microseconds internally)

Note: The API uses milliseconds as the smallest unit for simplicity, but internal storage uses microseconds for Dart compatibility. Fractional inputs are converted to microseconds (e.g., `duration.fromMilliseconds(1.5)` stores 1500 microseconds). Sub-microsecond precision is truncated.

### String Representation

When a Duration is converted to a string (via `to.string` or printed), it uses the format:

- `"0d 2h 30m 45s 500ms"` for 2 hours, 30 minutes, 45 seconds, 500 milliseconds
- `"0d 0h 00m 00s 000ms"` for zero duration
- `"2d 2h 00m 00s 000ms"` for 50 hours (2 days + 2 hours)
- `"100d 0h 00m 00s 000ms"` for 100 days

Note: Days and hours are not zero-padded. Minutes and seconds are padded to 2 digits. Milliseconds are padded to 3 digits.

### New Error Type

Add a new semantic error type for negative duration attempts:

```dart
class NegativeDurationError extends RuntimeError {
  const NegativeDurationError({required String function})
    : super('Duration cannot be negative in "$function"');
}
```

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
    final String minutesString = minutes.toString().padLeft(2, '0');
    final String secondsString = seconds.toString().padLeft(2, '0');
    final String millisecondsString = milliseconds.toString().padLeft(3, '0');
    return '${days}d ${hours}h ${minutesString}m ${secondsString}s ${millisecondsString}ms';
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

Add a new constructor to `lib/compiler/models/parameter.dart`, placed after `Parameter.timestamp`:

```dart
const Parameter.duration(String name)
  : this._(name: name, type: const DurationType());
```

### Runtime Updates Required

The following runtime files must be updated:

1. **`lib/compiler/runtime/term.dart`** — Add Duration handling to `ValueTerm.from()`, placed after the `DateTime` check (line ~44) and before the `File` check:

   ```dart
   } else if (value is Duration) {
     return DurationTerm(value);
   ```

2. **`lib/compiler/runtime/runtime.dart`** — Add Duration handling to `format()`, placed after the `DateTime` check (line ~22) and before the `File` check:

   ```dart
   } else if (value is Duration) {
     final int days = value.inDays;
     final int hours = value.inHours.remainder(24);
     final int minutes = value.inMinutes.remainder(60);
     final int seconds = value.inSeconds.remainder(60);
     final int milliseconds = value.inMilliseconds.remainder(1000);
     final String minutesString = minutes.toString().padLeft(2, '0');
     final String secondsString = seconds.toString().padLeft(2, '0');
     final String millisecondsString = milliseconds.toString().padLeft(3, '0');
     return '"${days}d ${hours}h ${minutesString}m ${secondsString}s ${millisecondsString}ms"';
   }
   ```

3. **`lib/compiler/models/type.dart`** — Add `DurationType()` to:
   - `OrderedType.memberTypes` (after `TimestampType()`)
   - `EquatableType.memberTypes` (after `TimestampType()`)
   - `HashableType.memberTypes` (after `TimestampType()`)
   - `AddableType.memberTypes` (after `SetType()`)
   - `SubtractableType.memberTypes` (after `SetType()`)

4. **`lib/compiler/errors/runtime_error.dart`** — Add the new error class:

   ```dart
   class NegativeDurationError extends RuntimeError {
     NegativeDurationError({required String function})
       : super('Duration cannot be negative in "$function"');
   }
   ```

5. **Operator implementations** — Add explicit `DurationTerm` handling to:
   - `lib/compiler/library/operators/operator_add.dart`
   - `lib/compiler/library/operators/operator_sub.dart`
   - `lib/compiler/library/operators/operator_lt.dart`
   - `lib/compiler/library/operators/operator_le.dart`
   - `lib/compiler/library/operators/operator_gt.dart`
   - `lib/compiler/library/operators/operator_ge.dart`
   - `lib/compiler/library/operators/operator_eq.dart`
   - `lib/compiler/library/operators/operator_neq.dart`
   - `lib/compiler/library/comparison/comp_lt.dart`
   - `lib/compiler/library/comparison/comp_le.dart`
   - `lib/compiler/library/comparison/comp_gt.dart`
   - `lib/compiler/library/comparison/comp_ge.dart`
   - `lib/compiler/library/comparison/comp_eq.dart`
   - `lib/compiler/library/comparison/comp_neq.dart`

   Note: Type classes are used for parameter validation only. Runtime dispatch uses explicit type checks (e.g., `if (a is DurationTerm && b is DurationTerm)`).

### Error Handling

- `duration.fromHours(-1)` — throws `NegativeDurationError` with message `Duration cannot be negative in "duration.fromHours"`
- `duration.from(0, -1, 0, 0, 0)` — throws `NegativeDurationError` (each component validated individually)
- `duration.from(-1, 0, 0, 0, 0)` — throws `NegativeDurationError` (negative days)
- `a - b` where `b > a` — throws `NegativeDurationError` with function name "-"
- Type mismatches — throws `InvalidArgumentTypesError`
- Wrong argument count — throws `InvalidArgumentCountError`
- Overflow (duration exceeding ~292,471 years / 2^63-1 microseconds on 64-bit platforms) — throws `InvalidValueError`

**Platform Note:** On the web platform (JavaScript), number precision is limited to 53 bits (IEEE 754 double). This limits maximum duration to approximately 104 million days (~285,000 years) without precision loss. The CLI platform supports the full 64-bit range.

## Examples

### Timing Operations

```primal
// Measure elapsed time
measureElapsedTime() =
  let start = time.now() in
  let end = time.now() in
  let elapsed = time.between(start, end) in
  console.write("Took: " + to.string(elapsed))
```

### Scheduling

```primal
// Calculate next run time
calculateNextRunTime() =
  let interval = duration.fromHours(6) in
  let lastRun = time.fromIso("2025-01-15T10:00:00Z") in
  time.add(lastRun, interval)
```

### Time Remaining

```primal
// Countdown timer
displayTimeRemaining() =
  let deadline = time.fromIso("2025-12-31T23:59:59Z") in
  let remaining = time.between(time.now(), deadline) in
  console.write("Time remaining: " + to.string(remaining))
```

### Working Hours Calculation

```primal
// Calculate total work time
calculateTotalWorkHours() =
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
durationTypeChecks() =
  let d = duration.fromHours(2) in
  [
    is.duration(d),             // true
    is.duration(time.now()),    // false
    is.duration(3600)           // false
  ]
```

## Compatibility

- **Mostly backward compatible** — new type with no changes to existing standard library behavior
- **Timestamp integration** — extends `time.*` namespace with duration support
- **Platform support** — works on both CLI and web (Duration uses no I/O; verified that Dart's `Duration` class works in dart2js)
- **BREAKING CHANGE** — users who defined custom `time.add`, `time.subtract`, or `time.between` functions will receive `CannotRedefineStandardLibraryError` at compile time

### Migration Guide for Breaking Change

If you have user-defined functions named `time.add`, `time.subtract`, or `time.between`:

1. **Rename your functions** to avoid the `time.*` namespace:
   - `time.add` → `myTime.add` or `addToTimestamp`
   - `time.subtract` → `myTime.subtract` or `subtractFromTimestamp`
   - `time.between` → `myTime.between` or `timeDifference`

2. **Update all call sites** to use the new function names

3. **Consider using the new standard library functions** if your custom implementations were workarounds for missing duration support

### Known Namespace Inconsistency

The existing `timestamp.toEpoch` function uses the `timestamp.*` namespace while all other timestamp functions use `time.*`. This proposal maintains consistency with the majority by using `time.*` for the new functions. A future release may deprecate `timestamp.toEpoch` in favor of `time.toEpoch`.

## Documentation Requirements

This feature requires the following documentation updates:

1. Create `docs/reference/duration.md` with full function documentation (including purity annotations)
2. Add Duration link to `docs/reference.md` (after Timestamp)
3. Add Duration to the types list in `README.md` under "System" types
4. Update `docs/reference/casting.md` to include `is.duration`
5. Update `docs/reference/operators.md`:
   - Add `Duration == Duration` and `Duration != Duration` under Equality/Inequality
   - Add `Duration < Duration`, `Duration > Duration`, `Duration <= Duration`, `Duration >= Duration` under comparison operators
   - Add `Duration + Duration` under Addition
   - Add `Duration - Duration` under Subtraction

## Decisions (Resolved)

1. **Months/years support:** No. Months and years have variable lengths (28-31 days, 365-366 days). Duration represents fixed time spans only.

2. **Negative durations:** No. Durations represent non-negative time spans. Construction functions throw `NegativeDurationError` for negative inputs. Each component in `duration.from` is validated individually. Use `time.subtract` to move timestamps backward.

3. **Fractional input:** Yes. Construction functions accept fractional numbers: `duration.fromHours(2.5)` creates a duration of 2 hours and 30 minutes. The value is converted to microseconds internally.

4. **Component vs total extraction:** Component functions (`duration.seconds`, etc.) return integer parts. Total functions (`duration.toSeconds`, etc.) return fractional totals.

5. **Plural naming convention:** Duration component functions use plural names (`duration.seconds`, `duration.milliseconds`) to distinguish them from Timestamp property functions which use singular names (`time.second`, `time.millisecond`). This reflects the semantic difference: Timestamp properties extract a single calendar value, while Duration components extract a count of units.

6. **Format pattern letters:** Duration uses `D`/`DD` for days (uppercase) to avoid conflict with Timestamp's `d`/`dd` (day-of-month). Single `S` for milliseconds is not supported; only `SSS` (zero-padded to 3 digits) is available to match Timestamp's behavior.

7. **Error type for negative durations:** A dedicated `NegativeDurationError` provides clear, specific error messages that include the function name, rather than using the generic `InvalidValueError`.

## Test Requirements

The implementation must include tests for:

### Happy Path

- All 22 functions with valid inputs (18 duration + 3 timestamp integration + 1 type check)
- `to.string(duration)` produces expected format
- Roundtrip: `time.between(a, b)` then `time.add(a, duration)` returns `b`
- Arithmetic operators: `+`, `-`
- Comparison operators: `<`, `>`, `<=`, `>=`
- Equality operators: `==`, `!=`
- Use as map key and set element (HashableType)

### Edge Cases

- **Zero duration operations:**
  - `duration.fromMilliseconds(0)` construction
  - `zeroDuration + anyDuration` equals `anyDuration`
  - `anyDuration - anyDuration` equals zero duration (same duration)
  - `duration.compare(zero, zero)` returns 0
  - Zero duration as map key (should work, hashable)
  - Zero duration formatted with all patterns
  - `duration.toHours(zeroDuration)` returns 0
- Maximum precision: microsecond-level accuracy (sub-microsecond truncation)
- Large durations: near overflow limit (2^63-1 microseconds ≈ 292,471 years)
- Large durations on web: verify behavior near 2^53 limit
- Fractional inputs: `duration.fromSeconds(1.5)` stores 1,500,000 microseconds
- Fractional days: `duration.fromDays(0.5)` equals 12 hours
- `time.between` with reversed arguments: `time.between(later, earlier)` returns same as `time.between(earlier, later)`
- Duration equality across construction methods: `duration.fromHours(1) == duration.fromMinutes(60)`

### Error Cases

- Negative input to single-value constructors:
  - `duration.fromMilliseconds(-1)` throws `NegativeDurationError`
  - `duration.fromSeconds(-1)` throws `NegativeDurationError`
  - `duration.fromMinutes(-1)` throws `NegativeDurationError`
  - `duration.fromHours(-1)` throws `NegativeDurationError`
  - `duration.fromDays(-1)` throws `NegativeDurationError`
- Negative components in `duration.from`:
  - `duration.from(-1, 0, 0, 0, 0)` throws `NegativeDurationError`
  - `duration.from(0, -1, 0, 0, 0)` throws `NegativeDurationError`
  - `duration.from(0, 0, -1, 0, 0)` throws `NegativeDurationError`
  - `duration.from(0, 0, 0, -1, 0)` throws `NegativeDurationError`
  - `duration.from(0, 0, 0, 0, -1)` throws `NegativeDurationError`
- Subtraction resulting in negative (e.g., `a - b` where `b > a`) throws `NegativeDurationError`
- Type mismatches for all functions throw `InvalidArgumentTypesError`
- Wrong argument count throws `InvalidArgumentCountError`
- Duration passed to Timestamp function (e.g., `time.year(duration.fromHours(1))`) throws `InvalidArgumentTypesError`
- Timestamp passed to Duration function (e.g., `duration.toHours(time.now())`) throws `InvalidArgumentTypesError`
- `time.between(end, start)` where `end < start` returns absolute difference (no error)
- Overflow throws `InvalidValueError`

### Integration

- `list.reduce` with `+` operator
- `list.map` with duration functions
- `list.filter` with duration comparison
- Composition with Timestamp functions
- Duration in conditional expressions: `if (elapsed > duration.fromHours(1)) ... else ...`
