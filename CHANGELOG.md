# CHANGELOG

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
