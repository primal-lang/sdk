# Duration Type Implementation Plan

This plan implements the Duration type as specified in `duration-proposal.md`.

---

## Phase 1: Core Type Infrastructure

### 1.1 Add DurationType and DurationTerm

**File:** `lib/compiler/models/type.dart`

- [x] Add `DurationType` class after `TimestampType`:
  ```dart
  class DurationType extends Type {
    const DurationType();
    @override
    String toString() => 'Duration';
  }
  ```

**File:** `lib/compiler/runtime/term.dart`

- [x] Add `DurationTerm` class after `TimestampTerm`:
  ```dart
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
        identical(this, other) || other is DurationTerm && value == other.value;
    @override
    int get hashCode => value.hashCode;
  }
  ```

- [x] Update `ValueTerm.from()` factory to handle `Duration` (add after `DateTime` check, before `File` check):
  ```dart
  } else if (value is Duration) {
    return DurationTerm(value);
  ```

### 1.2 Add Parameter Constructor

**File:** `lib/compiler/models/parameter.dart`

- [x] Add `Parameter.duration` constructor after `Parameter.timestamp`:
  ```dart
  const Parameter.duration(String name)
    : this._(name: name, type: const DurationType());
  ```

### 1.3 Add NegativeDurationError

**File:** `lib/compiler/errors/runtime_error.dart`

- [x] Add `NegativeDurationError` class:
  ```dart
  class NegativeDurationError extends RuntimeError {
    NegativeDurationError({required String function, String? component, num? value})
      : super(component != null
          ? 'Duration cannot be negative in "$function" ($component: $value)'
          : 'Duration cannot be negative in "$function"');
  }
  ```

### 1.4 Update Runtime Format Function

**File:** `lib/compiler/runtime/runtime.dart`

- [x] Add Duration handling to `format()` function (after `DateTime` check, before `File` check):
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

---

## Phase 2: Type Class Integration

**File:** `lib/compiler/models/type.dart`

### 2.1 OrderedType

- [x] Add `DurationType()` to `OrderedType.memberTypes` (after `TimestampType()`)

### 2.2 EquatableType

- [x] Add `DurationType()` to `EquatableType.memberTypes` (after `TimestampType()`)

### 2.3 HashableType

- [x] Add `DurationType()` to `HashableType.memberTypes` (after `TimestampType()`)

### 2.4 AddableType

- [x] Add `DurationType()` to `AddableType.memberTypes` (after `SetType()`)

### 2.5 SubtractableType

- [x] Add `DurationType()` to `SubtractableType.memberTypes` (after `SetType()`)

---

## Phase 3: Operator Implementations

### 3.1 Addition Operator

**File:** `lib/compiler/runtime/operators/operator_add.dart`

- [x] Add `DurationTerm` handling in `reduce()` (after `SetTerm` handling, before final `else`):
  ```dart
  } else if ((a is DurationTerm) && (b is DurationTerm)) {
    return DurationTerm(a.value + b.value);
  ```

### 3.2 Subtraction Operator

**File:** `lib/compiler/runtime/operators/operator_sub.dart`

- [x] Add `DurationTerm` handling in `reduce()` (after `SetTerm` handling, before final `else`):
  ```dart
  } else if ((a is DurationTerm) && (b is DurationTerm)) {
    final Duration result = a.value - b.value;
    if (result.isNegative) {
      throw NegativeDurationError(function: name);
    }
    return DurationTerm(result);
  ```

### 3.3 Comparison Operators

**File:** `lib/compiler/runtime/comparisons/comp_lt.dart`

- [x] Add `DurationTerm` handling (after `TimestampTerm` handling):
  ```dart
  } else if ((a is DurationTerm) && (b is DurationTerm)) {
    return BooleanTerm(a.value.compareTo(b.value) < 0);
  ```

**File:** `lib/compiler/runtime/comparisons/comp_le.dart`

- [x] Add `DurationTerm` handling (after `TimestampTerm` handling):
  ```dart
  } else if ((a is DurationTerm) && (b is DurationTerm)) {
    return BooleanTerm(a.value.compareTo(b.value) <= 0);
  ```

**File:** `lib/compiler/runtime/comparisons/comp_gt.dart`

- [x] Add `DurationTerm` handling (after `TimestampTerm` handling):
  ```dart
  } else if ((a is DurationTerm) && (b is DurationTerm)) {
    return BooleanTerm(a.value.compareTo(b.value) > 0);
  ```

**File:** `lib/compiler/runtime/comparisons/comp_ge.dart`

- [x] Add `DurationTerm` handling (after `TimestampTerm` handling):
  ```dart
  } else if ((a is DurationTerm) && (b is DurationTerm)) {
    return BooleanTerm(a.value.compareTo(b.value) >= 0);
  ```

### 3.4 Equality Operators

**File:** `lib/compiler/runtime/comparisons/comp_eq.dart`

- [x] Add `DurationTerm` handling:
  ```dart
  } else if ((a is DurationTerm) && (b is DurationTerm)) {
    return BooleanTerm(a.value == b.value);
  ```

**File:** `lib/compiler/runtime/comparisons/comp_neq.dart`

- [x] Add `DurationTerm` handling:
  ```dart
  } else if ((a is DurationTerm) && (b is DurationTerm)) {
    return BooleanTerm(a.value != b.value);
  ```

---

## Phase 4: Standard Library Functions - Duration Namespace

**File:** Create `lib/compiler/runtime/functions/duration/` directory

### 4.1 Single-Unit Constructors (5 functions)

**File:** `lib/compiler/runtime/functions/duration/from_milliseconds.dart`

- [x] Create `DurationFromMilliseconds` function:
  - Parameters: `Number`
  - Returns: `Duration`
  - Throws `NegativeDurationError` if input < 0
  - Converts fractional milliseconds to microseconds (multiply by 1000)

**File:** `lib/compiler/runtime/functions/duration/from_seconds.dart`

- [x] Create `DurationFromSeconds` function:
  - Parameters: `Number`
  - Returns: `Duration`
  - Throws `NegativeDurationError` if input < 0
  - Converts fractional seconds to microseconds (multiply by 1,000,000)

**File:** `lib/compiler/runtime/functions/duration/from_minutes.dart`

- [x] Create `DurationFromMinutes` function:
  - Parameters: `Number`
  - Returns: `Duration`
  - Throws `NegativeDurationError` if input < 0
  - Converts fractional minutes to microseconds

**File:** `lib/compiler/runtime/functions/duration/from_hours.dart`

- [x] Create `DurationFromHours` function:
  - Parameters: `Number`
  - Returns: `Duration`
  - Throws `NegativeDurationError` if input < 0
  - Converts fractional hours to microseconds

**File:** `lib/compiler/runtime/functions/duration/from_days.dart`

- [x] Create `DurationFromDays` function:
  - Parameters: `Number`
  - Returns: `Duration`
  - Throws `NegativeDurationError` if input < 0
  - Converts fractional days to microseconds

### 4.2 Combined Constructor

**File:** `lib/compiler/runtime/functions/duration/from.dart`

- [x] Create `DurationFrom` function:
  - Parameters: `Number x 5` (days, hours, minutes, seconds, milliseconds)
  - Returns: `Duration`
  - Validates left-to-right; throws `NegativeDurationError` at first negative component (includes component name and value in error)
  - Combines all components into total microseconds

### 4.3 Total Conversion Functions (5 functions)

**File:** `lib/compiler/runtime/functions/duration/to_milliseconds.dart`

- [x] Create `DurationToMilliseconds` function:
  - Parameters: `Duration`
  - Returns: `Number` (fractional)
  - Returns `value.inMicroseconds / 1000`

**File:** `lib/compiler/runtime/functions/duration/to_seconds.dart`

- [x] Create `DurationToSeconds` function:
  - Parameters: `Duration`
  - Returns: `Number` (fractional)
  - Returns `value.inMicroseconds / 1,000,000`

**File:** `lib/compiler/runtime/functions/duration/to_minutes.dart`

- [x] Create `DurationToMinutes` function:
  - Parameters: `Duration`
  - Returns: `Number` (fractional)
  - Returns `value.inMicroseconds / 60,000,000`

**File:** `lib/compiler/runtime/functions/duration/to_hours.dart`

- [x] Create `DurationToHours` function:
  - Parameters: `Duration`
  - Returns: `Number` (fractional)
  - Returns `value.inMicroseconds / 3,600,000,000`

**File:** `lib/compiler/runtime/functions/duration/to_days.dart`

- [x] Create `DurationToDays` function:
  - Parameters: `Duration`
  - Returns: `Number` (fractional)
  - Returns `value.inMicroseconds / 86,400,000,000`

### 4.4 Component Extraction Functions (5 functions)

**File:** `lib/compiler/runtime/functions/duration/milliseconds.dart`

- [x] Create `DurationMilliseconds` function:
  - Parameters: `Duration`
  - Returns: `Number` (integer 0-999)
  - Returns `value.inMilliseconds.remainder(1000)`

**File:** `lib/compiler/runtime/functions/duration/seconds.dart`

- [x] Create `DurationSeconds` function:
  - Parameters: `Duration`
  - Returns: `Number` (integer 0-59)
  - Returns `value.inSeconds.remainder(60)`

**File:** `lib/compiler/runtime/functions/duration/minutes.dart`

- [x] Create `DurationMinutes` function:
  - Parameters: `Duration`
  - Returns: `Number` (integer 0-59)
  - Returns `value.inMinutes.remainder(60)`

**File:** `lib/compiler/runtime/functions/duration/hours.dart`

- [x] Create `DurationHours` function:
  - Parameters: `Duration`
  - Returns: `Number` (integer 0-23)
  - Returns `value.inHours.remainder(24)`

**File:** `lib/compiler/runtime/functions/duration/days.dart`

- [x] Create `DurationDays` function:
  - Parameters: `Duration`
  - Returns: `Number` (integer, unbounded)
  - Returns `value.inDays`

### 4.5 Comparison Function

**File:** `lib/compiler/runtime/functions/duration/compare.dart`

- [x] Create `DurationCompare` function:
  - Parameters: `Duration, Duration`
  - Returns: `Number` (-1, 0, or 1)
  - Returns `a.value.compareTo(b.value).sign` or equivalent

### 4.6 Format Function

**File:** `lib/compiler/runtime/functions/duration/format.dart`

- [x] Create `DurationFormat` function:
  - Parameters: `Duration, String`
  - Returns: `String`
  - Supported patterns:
    - `d` / `dd` - days (unbounded; `dd` zero-pads to 2 digits)
    - `H` / `HH` - hours component (0-23; `HH` zero-pads)
    - `m` / `mm` - minutes component (0-59; `mm` zero-pads)
    - `s` / `ss` - seconds component (0-59; `ss` zero-pads)
    - `S` / `SSS` - milliseconds (0-999; `SSS` zero-pads to 3 digits)
  - Uses component values (remainders), not totals

---

## Phase 5: Standard Library Functions - Time Namespace Integration

### 5.1 time.add

**File:** `lib/compiler/runtime/functions/time/add.dart`

- [x] Create `TimeAdd` function:
  - Parameters: `Timestamp, Duration`
  - Returns: `Timestamp`
  - Implementation: `timestamp.add(duration)`

### 5.2 time.subtract

**File:** `lib/compiler/runtime/functions/time/subtract.dart`

- [x] Create `TimeSubtract` function:
  - Parameters: `Timestamp, Duration`
  - Returns: `Timestamp`
  - Implementation: `timestamp.subtract(duration)`

### 5.3 time.between

**File:** `lib/compiler/runtime/functions/time/between.dart`

- [x] Create `TimeBetween` function:
  - Parameters: `Timestamp, Timestamp`
  - Returns: `Duration`
  - Returns absolute difference: `(a.difference(b)).abs()`

---

## Phase 6: Type Checking Function

**File:** `lib/compiler/runtime/functions/is/duration.dart`

- [x] Create `IsDuration` function:
  - Parameters: `Any`
  - Returns: `Boolean`
  - Returns `true` if argument is `DurationTerm`

---

## Phase 7: Register All Functions

**File:** `lib/compiler/runtime/standard_library.dart`

- [x] Import all new duration function files
- [x] Register functions in the appropriate namespace maps:
  - `duration.fromMilliseconds` -> `DurationFromMilliseconds`
  - `duration.fromSeconds` -> `DurationFromSeconds`
  - `duration.fromMinutes` -> `DurationFromMinutes`
  - `duration.fromHours` -> `DurationFromHours`
  - `duration.fromDays` -> `DurationFromDays`
  - `duration.from` -> `DurationFrom`
  - `duration.toMilliseconds` -> `DurationToMilliseconds`
  - `duration.toSeconds` -> `DurationToSeconds`
  - `duration.toMinutes` -> `DurationToMinutes`
  - `duration.toHours` -> `DurationToHours`
  - `duration.toDays` -> `DurationToDays`
  - `duration.milliseconds` -> `DurationMilliseconds`
  - `duration.seconds` -> `DurationSeconds`
  - `duration.minutes` -> `DurationMinutes`
  - `duration.hours` -> `DurationHours`
  - `duration.days` -> `DurationDays`
  - `duration.compare` -> `DurationCompare`
  - `duration.format` -> `DurationFormat`
  - `time.add` -> `TimeAdd`
  - `time.subtract` -> `TimeSubtract`
  - `time.between` -> `TimeBetween`
  - `is.duration` -> `IsDuration`

---

## Phase 8: Tests

**Directory:** `test/functions/duration/`

### 8.1 Constructor Tests

- [x] `test/functions/duration/from_milliseconds_test.dart`
  - Valid inputs (integer and fractional)
  - Zero input
  - Negative input throws `NegativeDurationError`
  - Type mismatch throws `InvalidArgumentTypesError`
  - Wrong argument count throws `InvalidArgumentCountError`

- [x] `test/functions/duration/from_seconds_test.dart`
  - Same test patterns as above

- [x] `test/functions/duration/from_minutes_test.dart`
  - Same test patterns as above

- [x] `test/functions/duration/from_hours_test.dart`
  - Same test patterns as above

- [x] `test/functions/duration/from_days_test.dart`
  - Same test patterns as above
  - Fractional days: `duration.fromDays(0.5)` equals 12 hours

- [x] `test/functions/duration/from_test.dart`
  - Valid combined construction
  - Zero duration
  - Each component negative individually (5 tests)
  - Left-to-right validation (first negative stops)
  - Type mismatch on each parameter
  - Wrong argument count

### 8.2 Total Conversion Tests

- [x] `test/functions/duration/to_milliseconds_test.dart`
  - Valid conversion with fractional result
  - Zero duration returns 0
  - Roundtrip with `fromMilliseconds` (including fractional)
  - Type mismatch throws error

- [x] `test/functions/duration/to_seconds_test.dart`
  - Same patterns

- [x] `test/functions/duration/to_minutes_test.dart`
  - Same patterns

- [x] `test/functions/duration/to_hours_test.dart`
  - Same patterns

- [x] `test/functions/duration/to_days_test.dart`
  - Same patterns

### 8.3 Component Extraction Tests

- [x] `test/functions/duration/milliseconds_test.dart`
  - Returns 0-999 range
  - Various durations
  - Type mismatch

- [x] `test/functions/duration/seconds_test.dart`
  - Returns 0-59 range
  - Various durations
  - Type mismatch

- [x] `test/functions/duration/minutes_test.dart`
  - Returns 0-59 range
  - Various durations
  - Type mismatch

- [x] `test/functions/duration/hours_test.dart`
  - Returns 0-23 range
  - 50 hours returns 2 (after extracting 2 days)
  - Type mismatch

- [x] `test/functions/duration/days_test.dart`
  - Unbounded
  - 50 hours returns 2 days
  - Type mismatch

### 8.4 Compare and Format Tests

- [x] `test/functions/duration/compare_test.dart`
  - Less than returns -1
  - Equal returns 0
  - Greater than returns 1
  - Same duration via different constructors compares equal
  - Type mismatch

- [x] `test/functions/duration/format_test.dart`
  - Each pattern letter individually
  - Combined patterns
  - Zero-padding variants (`dd`, `HH`, `mm`, `ss`, `SSS`)
  - Non-padded variants (`d`, `H`, `m`, `s`, `S`)
  - Large day values (>99)
  - Type mismatch

### 8.5 Timestamp Integration Tests

- [x] `test/functions/time/add_test.dart`
  - Add duration to timestamp
  - Add zero duration
  - Type mismatch

- [x] `test/functions/time/subtract_test.dart`
  - Subtract duration from timestamp
  - Subtract zero duration
  - Type mismatch

- [x] `test/functions/time/between_test.dart`
  - Difference between timestamps
  - Reversed arguments (absolute value)
  - Same timestamp returns zero duration
  - Type mismatch

### 8.6 Type Check Tests

- [x] `test/functions/is/duration_test.dart`
  - `is.duration(duration)` returns true
  - `is.duration(timestamp)` returns false
  - `is.duration(number)` returns false
  - `is.duration(string)` returns false

### 8.7 Operator Tests

- [x] `test/operators/duration_add_test.dart`
  - Duration + Duration
  - Identity with zero duration
  - Type mismatch

- [x] `test/operators/duration_sub_test.dart`
  - Duration - Duration
  - Subtraction resulting in zero
  - Subtraction resulting in negative throws `NegativeDurationError`
  - Type mismatch

- [x] `test/operators/duration_comparison_test.dart`
  - `<`, `>`, `<=`, `>=` operators
  - Equal durations via different constructors

- [x] `test/operators/duration_equality_test.dart`
  - `==`, `!=` operators
  - Equal durations via different constructors

### 8.8 Hashable Tests

- [x] `test/types/duration_hashable_test.dart`
  - Duration as map key
  - Duration in set
  - Equal durations hash to same value
  - Zero duration as map key

### 8.9 Integration Tests

- [x] `test/integration/duration_integration_test.dart`
  - `list.reduce` with `+` operator
  - `list.map` with duration functions
  - `list.filter` with duration comparison
  - Composition with timestamp functions
  - Duration in conditional expressions
  - Roundtrip: `time.between(a, b)` then `time.add(a, duration)` returns `b`

### 8.10 Edge Case Tests

- [x] `test/edge_cases/duration_edge_cases_test.dart`
  - Maximum precision (microsecond-level)
  - Large durations near overflow limit
  - Fractional milliseconds roundtrip: `toMilliseconds(fromMilliseconds(1.5))` returns 1.5
  - `to.string(duration)` produces expected format

---

## Phase 9: Documentation

### 9.1 Create Duration Reference

**File:** `docs/reference/duration.md`

- [x] Create comprehensive documentation including:
  - All 18 duration functions with signatures, descriptions, examples
  - Purity annotations (all Pure)
  - Error conditions
  - Internal representation notes

### 9.2 Update Reference Index

**File:** `docs/reference.md`

- [x] Add Duration link after Timestamp entry

### 9.3 Update README

**File:** `README.md`

- [x] Add Duration to the types list under "System" types

### 9.4 Update Casting Reference

**File:** `docs/reference/casting.md`

- [x] Add `is.duration` to the type checking functions list

### 9.5 Update Operators Reference

**File:** `docs/reference/operators.md`

- [x] Add `Duration == Duration` under Equality
- [x] Add `Duration != Duration` under Inequality
- [x] Add `Duration < Duration`, `Duration > Duration`, `Duration <= Duration`, `Duration >= Duration` under comparison operators
- [x] Add `Duration + Duration` under Addition
- [x] Add `Duration - Duration` under Subtraction

---

## Phase 10: Final Verification

- [x] Run full test suite: `dart test`
- [x] Run `/delta-review` on all changes
- [x] Verify web platform compatibility (if applicable)
- [x] Manual testing of REPL output format

---

## Implementation Order Summary

1. **Phase 1** - Core type infrastructure (DurationType, DurationTerm, Parameter, Error, Runtime format)
2. **Phase 2** - Type class integration (Ordered, Equatable, Hashable, Addable, Subtractable)
3. **Phase 3** - Operator implementations (add, sub, comparisons, equality)
4. **Phase 4** - Duration namespace functions (18 functions)
5. **Phase 5** - Time namespace integration (3 functions)
6. **Phase 6** - Type checking function (1 function)
7. **Phase 7** - Register all functions in standard library
8. **Phase 8** - Tests (comprehensive coverage)
9. **Phase 9** - Documentation updates
10. **Phase 10** - Final verification

---

## Notes

- All functions are **Pure** (no side effects)
- Internal storage uses **microseconds** (Dart's `Duration` representation)
- API exposes **milliseconds** as smallest user-facing unit
- Fractional inputs are supported and converted to microseconds
- Negative durations throw `NegativeDurationError` (not allowed)
- Overflow checking required for very large durations (throws `InvalidValueError`)
