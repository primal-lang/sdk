# CHANGELOG

## 0.5.0 - Bronze Axe

### Language

#### Added

- Let expressions for local variable bindings
- Lambda expressions (anonymous functions)

#### Changed

- Nullary functions now require parentheses: `main()` instead of `main`

### Standard Library

#### Added

- **Duration type** - New primitive type for representing time intervals
  - `duration.from(days, hours, minutes, seconds, milliseconds)` - Create from components
  - `duration.fromDays`, `duration.fromHours`, `duration.fromMinutes`, `duration.fromSeconds`, `duration.fromMilliseconds` - Create from single unit
  - `duration.days`, `duration.hours`, `duration.minutes`, `duration.seconds`, `duration.milliseconds` - Extract components
  - `duration.toDays`, `duration.toHours`, `duration.toMinutes`, `duration.toSeconds`, `duration.toMilliseconds` - Convert to single unit
  - `duration.format` - Format as human-readable string
  - `duration.compare` - Compare two durations
  - Operator support: `+`, `-`, comparison operators
- **Base64 encoding/decoding**
  - `base64.encode` - Encode string to Base64
  - `base64.decode` - Decode Base64 to string
- **UUID generation**
  - `uuid.v4` - Generate random UUID v4
- **Debug function**
  - `debug` - Print value with type information for debugging
- **Path utilities**
  - `path.basename` - Extract filename from path
  - `path.dirname` - Extract directory from path
  - `path.extension` - Extract file extension
  - `path.isAbsolute` - Check if path is absolute
  - `path.join` - Join path segments
  - `path.normalize` - Normalize path separators
- **Timestamp functions**
  - `time.add` - Add duration to timestamp
  - `time.subtract` - Subtract duration from timestamp
  - `time.between` - Get duration between two timestamps
  - `time.format` - Format timestamp with pattern
  - `time.fromEpoch` - Create timestamp from Unix epoch
  - `time.toEpoch` (renamed from `time.epoch`)
  - `time.dayOfWeek` - Get day of week (1-7)
  - `time.dayOfYear` - Get day of year (1-366)
  - `time.isAfter` - Check if timestamp is after another
  - `time.isBefore` - Check if timestamp is before another
  - `time.isLeapYear` - Check if year is a leap year
- **String functions**
  - `str.capitalize` - Capitalize first character
  - `str.count` - Count occurrences of substring
  - `str.fromBytes` - Create string from byte list
  - `str.isAlpha` - Check if string contains only letters
  - `str.isAlphaNumeric` - Check if string contains only letters and digits
  - `str.isBlank` - Check if string is empty or whitespace
  - `str.isLowercase` - Check if string is all lowercase
  - `str.isNumeric` - Check if string contains only digits
  - `str.isUppercase` - Check if string is all uppercase
  - `str.lastIndexOf` - Find last occurrence of substring
  - `str.lines` - Split string into lines
  - `str.repeat` - Repeat string n times
  - `str.trimLeft` - Trim whitespace from left
  - `str.trimRight` - Trim whitespace from right
- **List functions**
  - `list.chunk` - Split list into chunks of size n
  - `list.count` - Count elements matching predicate
  - `list.distinct` - Remove duplicates (preserve order)
  - `list.flatten` - Flatten nested lists
- **Map functions**
  - `map.entries` - Get list of key-value pairs
  - `map.merge` - Merge two maps
- **Set functions**
  - `set.isDisjoint` - Check if sets have no common elements
  - `set.isSubset` - Check if set is subset of another
  - `set.isSuperset` - Check if set is superset of another
- **Vector functions**
  - `vector.distance` - Euclidean distance between vectors
  - `vector.dot` - Dot product of two vectors
  - `vector.scale` - Multiply vector by scalar
- **Arithmetic functions**
  - `num.logBase` - Logarithm with custom base
  - `num.roundTo` - Round to n decimal places
  - `num.truncate` - Truncate to integer
- **File functions**
  - `file.append` - Append content to file
  - `file.lastModified` - Get file modification timestamp
- **Environment functions**
  - `env.has` - Check if environment variable exists
- **Type checking**
  - `is.duration` - Check if value is a Duration

### Documentation

#### Added

- Developer knowledge base (`docs/dev/`)
- Language reference (`docs/lang/`)

## 0.4.3 - Copper Chisel

### CLI

#### Added

- Watch mode (`--watch`, `-w`) for automatic re-execution when source file changes
- REPL commands for session management:
  - `:help` - Show REPL help
  - `:version` - Show version info
  - `:clear` - Clear the screen
  - `:quit`, `:q`, `:exit` - Exit the REPL
  - `:debug on/off` - Toggle debug mode
  - `:list` - Show all user-defined functions
  - `:delete <name>` - Remove a user-defined function
  - `:rename <old> <new>` - Rename a user-defined function
  - `:load <file>` - Load definitions from a file
  - `:run <file>` - Load definitions and run main
  - `:reset` - Clear all user-defined functions
- Function definition support in REPL (define functions interactively)
- Line editor with command history navigation (up/down arrow keys) and cursor movement
- ASCII art welcome banner with version and directory info

### Language

#### Added

- Short-circuit logical operators `&&` (and) and `||` (or) with lazy evaluation
- Keyword aliases `and`, `or`, `not` that map to `&&`, `||`, `!` respectively
- Strict (eager) evaluation variants `bool.andStrict` and `bool.orStrict`

#### Changed

- Single-character operators `&` and `|` now use strict (eager) evaluation
- Double-character operators `&&` and `||` use short-circuit (lazy) evaluation

### Standard Library

#### Added

- `bool.andStrict` - Strict AND that evaluates both operands unconditionally
- `bool.orStrict` - Strict OR that evaluates both operands unconditionally

#### Changed

- Comparison operators (`==`, `!=`, `>`, `<`, `>=`, `<=`) now use typed parameter constraints (`Equatable`, `Ordered`) instead of `Any`
- Arithmetic operators (`+`, `-`) now use typed parameter constraints (`Addable`, `Subtractable`)
- Index operator (`@`) now requires `Indexable` and `Hashable` parameters
- Collection operations now use appropriate type constraints:
  - `list.contains`, `list.indexOf`, `list.remove` require `Equatable` elements
  - `set.add`, `set.contains`, `set.remove` require `Hashable` elements
  - `map.at`, `map.containsKey`, `map.set` require `Hashable` keys

#### Fixed

- `queue.isEmpty`, `queue.isNotEmpty`, `queue.reverse` now correctly use `Queue` parameter type instead of `Stack`
- `num.ceil`, `num.floor`, `num.round` now handle infinity values correctly (return unchanged instead of throwing)
- `num.clamp` now validates that min bound is less than or equal to max bound
- Empty collection operations (`stack.peek`, `stack.pop`, `queue.peek`, `queue.dequeue`) now throw structured `EmptyCollectionError` instead of generic `RuntimeError`

### Type System

#### Added

- Type class system with semantic type constraints:
  - `Ordered` - Types supporting ordering comparisons (Number, String, Timestamp)
  - `Equatable` - Types supporting equality comparisons
  - `Hashable` - Types that can be used as map keys or set elements
  - `Indexable` - Types supporting index access (String, List, Map)
  - `Collection` - Collection types (List, Set, Stack, Queue, Map)
  - `Iterable` - Types that can be iterated
  - `Addable` - Types supporting addition
  - `Subtractable` - Types supporting subtraction
- Parameter constructors for new type classes (`Parameter.ordered()`, `Parameter.equatable()`, etc.)

## 0.4.2 - Copper Chisel

### Language

- Added `RecursionLimitError` for detecting excessive recursion depth
- Added specific runtime error types for better error messages

### Standard Library

- Added `set.difference` function
- Added `is.file` and `is.directory` type checking functions
- Added division by zero checking to `num.div` and `/` operator

## 0.4.1 - Copper Chisel

### Language

- Added string escape sequences:
  - Standard: `\n`, `\t`, `\\`, `\"`, `\'`
  - Unicode: `\xXX`, `\uXXXX`, `\u{X...}`
- Added scientific notation for numbers (e.g., `1e10`, `3.14e-5`)
- Added underscore separators in numbers (e.g., `1_000_000`)
- Added `@` operator for element access
- Added grapheme cluster support
- Improved error messages with detailed context

### Documentation

- Added comprehensive compiler architecture documentation
- Added complete standard library reference

## 0.4.0 - Copper Chisel

### Language

- Added support for:
  - Map
  - Timestamp
  - Set
  - Stack
  - Queue
  - Vector
  - File
  - Directory

### Standard library

- Added basic functions for:
  - Map
  - Timestamp
  - Set
  - Stack
  - Queue
  - Vector
  - File
  - Directory
  - JSON
  - Hash
  - Environment

### Runtime

- Added shebang support

## 0.3.0 - Clay Pot

### Language

- Added support for:
  - Higher order functions
- Added main function optional parameters

### Standard library

- Added basic functions for:
  - List processing functions

## 0.2.0 - Bone Hook

### Language

- Added support for:
  - List
- Added syntactic sugar for `if` conditions
- Added syntactic sugar to construct lists: `[1, 2, 3]`
- Added syntactic sugar to access list elements: `list[index]`
- Added syntactic sugar to access string characters: `string[index]`

### Standard library

- Added standard operators:
  - Arithmetic: `+`, `-`, `*`, `/`, `%`
  - Comparison: `==`, `!=`, `>`, `<`, `>=`, `<=`
  - Logical: `&`, `|`, `!`
- Added basic functions for:
  - List
  - Console (write)

### Runtime

- Added lazy evaluation

## 0.1.0 - Stone Arrowhead

### Language

- Added lexical analyzer
- Added syntactic analyzer
- Added semantic analyzer
- Added support for:
  - Booleans
  - Numbers
  - Strings
- Added main function as entry point

### Standard library

- Added basic functions for:
  - Control
  - Error
  - Comparison
  - Arithmetic
  - Logic
  - String
  - Casting

### Runtime

- Added runtime interpreter
