# CHANGELOG

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
