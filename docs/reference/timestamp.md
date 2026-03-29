# Timestamp

## time.now

`time.now(): Timestamp`

Returns a timestamp representing the current date and time.

## time.toIso

`time.toIso(a: Timestamp): String`

Converts a timestamp to its ISO 8601 string representation.

## time.fromIso

`time.fromIso(a: String): Timestamp`

Parses an ISO 8601 string and returns a timestamp.

## time.year

`time.year(a: Timestamp): Number`

Returns the year component of a timestamp.

## time.month

`time.month(a: Timestamp): Number`

Returns the month component of a timestamp (1-12).

## time.day

`time.day(a: Timestamp): Number`

Returns the day component of a timestamp (1-31).

## time.hour

`time.hour(a: Timestamp): Number`

Returns the hour component of a timestamp (0-23).

## time.minute

`time.minute(a: Timestamp): Number`

Returns the minute component of a timestamp (0-59).

## time.second

`time.second(a: Timestamp): Number`

Returns the second component of a timestamp (0-59).

## time.millisecond

`time.millisecond(a: Timestamp): Number`

Returns the millisecond component of a timestamp (0-999).

## time.epoch

`time.epoch(a: Timestamp): Number`

Returns the number of milliseconds elapsed since the Unix epoch.

## time.compare

`time.compare(a: Timestamp, b: Timestamp): Number`

Returns 1 if the first timestamp is greater, -1 if smaller, 0 if equal.
