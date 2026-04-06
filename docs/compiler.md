# Compiler Architecture

The Primal compiler is a six-stage pipeline that transforms source code into an executable representation. It is implemented in Dart and supports both CLI and web targets.

```
Source Code
    |
    v
 SourceReader ........ Characters with locations          → compiler/reader.md
    |
    v
 Lexical Analyzer .... Tokens (keywords, literals, ...)   → compiler/lexical.md
    |
    v
 Syntactic Analyzer .. Function definitions with ASTs     → compiler/syntactic.md
    |
    v
 Semantic Analyzer ... Semantic IR with FunctionSignature → compiler/semantic.md
    |
    v
 Lowerer ............. Runtime terms for evaluation       → compiler/runtime.md
    |
    v
 Runtime ............. Evaluation via term substitution   → compiler/runtime.md
```

The entry point is `Compiler.compile(String input)` in `lib/compiler/compiler.dart`, which runs the first four stages in sequence. The resulting `IntermediateRepresentation` contains semantic IR (with source locations and resolved references). The `RuntimeFacade` then orchestrates lowering via the `Lowerer` and execution via the `Runtime`.

Each pipeline stage is documented in its own file under [`compiler/`](compiler/). Shared data types are documented in [`compiler/models.md`](compiler/models.md).

---

## 1. Type System

**File**: `lib/compiler/models/type.dart`

Types are represented as classes extending `Type`:

| Type class         | Represents                           |
| ------------------ | ------------------------------------ |
| `BooleanType`      | Boolean values                       |
| `NumberType`       | Numeric values (integer and decimal) |
| `StringType`       | String values                        |
| `ListType`         | Ordered collections                  |
| `MapType`          | Key-value associations               |
| `SetType`          | Unique element collections           |
| `StackType`        | LIFO collections                     |
| `QueueType`        | FIFO collections                     |
| `VectorType`       | Mathematical vectors                 |
| `FileType`         | File handles                         |
| `DirectoryType`    | Directory handles                    |
| `TimestampType`    | Date/time values                     |
| `FunctionType`     | Function values                      |
| `FunctionCallType` | Function call expressions            |
| `AnyType`          | Wildcard (accepts any type)          |

Type checking is **dynamic** - it happens at runtime when native functions validate their argument types, not during compilation.

---

## 2. Standard Library

**File**: `lib/compiler/library/standard_library.dart`

The standard library provides 232 built-in functions, organized by namespace:

| Namespace     | Count | Examples                                                 |
| ------------- | ----- | -------------------------------------------------------- |
| `num.*`       | 35    | `num.add`, `num.sqrt`, `num.sin`, `num.clamp`            |
| `str.*`       | 28    | `str.length`, `str.split`, `str.replace`, `str.reverse`  |
| `list.*`      | 31    | `list.map`, `list.filter`, `list.reduce`, `list.sort`    |
| `bool.*`      | 4     | `bool.and`, `bool.or`, `bool.not`, `bool.xor`            |
| `comp.*`      | 6     | `comp.eq`, `comp.lt`, `comp.ge`                          |
| `map.*`       | 9     | `map.at`, `map.set`, `map.keys`, `map.values`            |
| `set.*`       | 10    | `set.add`, `set.union`, `set.intersection`               |
| `stack.*`     | 8     | `stack.push`, `stack.pop`, `stack.peek`                  |
| `queue.*`     | 8     | `queue.enqueue`, `queue.dequeue`, `queue.peek`           |
| `vector.*`    | 6     | `vector.add`, `vector.magnitude`, `vector.normalize`     |
| `time.*`      | 12    | `time.now`, `time.from.iso`, `time.year`                 |
| `file.*`      | 14    | `file.read`, `file.write`, `file.exists`                 |
| `directory.*` | 11    | `directory.create`, `directory.list`, `directory.exists` |
| `hash.*`      | 4     | `hash.md5`, `hash.sha256`                                |
| `json.*`      | 2     | `json.encode`, `json.decode`                             |
| `console.*`   | 3     | `console.write`, `console.read`                          |
| Casting       | 22    | `is.boolean`, `to.string`, `to.integer`                  |
| Operators     | 14    | `operator.add`, `operator.eq`, `operator.not`            |
| Control flow  | 2     | `if`, `try`                                              |
| Other         | 3     | `@`, `env.get`, `error.throw`                            |

---

## 3. Error and Warning System

**Files**: `lib/compiler/errors/`, `lib/compiler/warnings/`

All diagnostics extend `GenericError(errorType, message)`.

### Compilation Errors

Raised during compilation and abort the pipeline:

| Stage     | Error                                | Cause                                   |
| --------- | ------------------------------------ | --------------------------------------- |
| Lexical   | `InvalidCharacterError`              | Unrecognized character                  |
| Lexical   | `UnterminatedStringError`            | String literal missing closing quote    |
| Lexical   | `UnterminatedCommentError`           | Multi-line comment missing closing `*/` |
| Lexical   | `InvalidEscapeSequenceError`         | Unrecognized escape sequence            |
| Lexical   | `InvalidHexEscapeError`              | Malformed hex escape sequence           |
| Lexical   | `InvalidBracedEscapeError`           | Malformed braced Unicode escape         |
| Lexical   | `InvalidCodePointError`              | Code point exceeds U+10FFFF             |
| Syntactic | `InvalidTokenError`                  | Unexpected token in context             |
| Syntactic | `ExpectedTokenError`                 | Missing required token                  |
| Syntactic | `UnexpectedEndOfFileError`           | Premature end of input                  |
| Semantic  | `DuplicatedFunctionError`            | Two functions with the same name        |
| Semantic  | `DuplicatedParameterError`           | Repeated parameter in a function        |
| Semantic  | `UndefinedIdentifierError`           | Reference to unknown variable/function  |
| Semantic  | `UndefinedFunctionError`             | Call to unknown function                |
| Semantic  | `InvalidNumberOfArgumentsError`      | Wrong argument count in a call          |
| Semantic  | `NotCallableError`                   | Calling a non-callable literal          |
| Semantic  | `NotIndexableError`                  | Indexing a non-indexable literal        |
| Semantic  | `CannotRedefineStandardLibraryError` | Redefining a standard library function  |

### Runtime Errors

Raised during execution:

| Error                               | Cause                                              |
| ----------------------------------- | -------------------------------------------------- |
| `InvalidArgumentTypesError`         | Wrong argument types for a native function         |
| `InvalidArgumentCountError`         | Wrong number of arguments at runtime               |
| `IterablesWithDifferentLengthError` | Mismatched collection lengths (e.g., `vector.add`) |
| `InvalidLiteralValueError`          | Invalid literal value                              |
| `InvalidValueError`                 | Invalid computed value                             |
| `InvalidMapIndexError`              | Key not found in map                               |
| `ElementNotFoundError`              | Element not in collection                          |
| `NotFoundInScopeError`              | Function not found in runtime scope                |
| `InvalidFunctionError`              | Callee is not a function                           |
| `UnimplementedFunctionWebError`     | I/O function called on web platform                |
| `EmptyCollectionError`              | Attempting to access an empty collection           |
| `IndexOutOfBoundsError`             | Index outside collection range                     |
| `NegativeIndexError`                | Negative index provided where disallowed           |
| `DivisionByZeroError`               | Division by zero                                   |
| `InvalidNumericOperationError`      | Domain error (e.g., `log(-1)`, `sqrt(-1)`)         |
| `ParseError`                        | Failed string conversion                           |
| `JsonParseError`                    | Invalid JSON string                                |
| `RecursionLimitError`               | Maximum recursion depth exceeded                   |
| `CustomError`                       | Explicitly raised via `error.throw`                |

---

## 4. Platform Abstraction

**Files**: `lib/compiler/platform/`

The compiler uses a **strategy pattern** to abstract platform-specific operations behind a common interface.

### Interface

`PlatformBase` defines four subsystems:

- `PlatformConsoleBase` - standard output, error output, and input.
- `PlatformEnvironmentBase` - environment variable lookup.
- `PlatformFileBase` - file creation, reading, writing, deletion, and metadata.
- `PlatformDirectoryBase` - directory creation, listing, deletion, and navigation.

### Implementations

|                | CLI                       | Web         |
| -------------- | ------------------------- | ----------- |
| Console output | `stdout` / `stderr`       | `print()`   |
| Console input  | `stdin.readLineSync()`    | Unsupported |
| File system    | `dart:io` synchronous API | Unsupported |
| Environment    | `Platform.environment`    | Unsupported |

The active platform is selected at startup based on the entry point (`main_cli.dart` or `main_web.dart`).

---

## 5. Entry Points

### CLI (`lib/main/main_cli.dart`)

1. Reads source code from a file path provided as the first command-line argument.
2. Compiles the source via `Compiler().compile()`.
3. Prints any warnings to the console.
4. If a `main` function is defined, executes it with the remaining CLI arguments.
5. Otherwise, enters a **REPL** loop where the user can type expressions and see their reduced results.

### Web (`lib/main/main_web.dart`)

Exposes the compiler as a set of JavaScript-callable functions via Dart's JS interop:

- `compileInput(source)` - compiles source code to intermediate code.
- `compileExpression(expression)` - parses a single expression.
- `runtimeWarnings(code)` - extracts warnings from compiled code.
- `runtimeHasMain(code)` - checks if a main function exists.
- `runtimeExecuteMain(code)` - executes the main function.
- `runtimeReduce(code, expression)` - reduces an expression.
- `intermediateRepresentationEmpty()` - returns an empty intermediate representation handle.
- `disposeCode(code)` - frees a compiled code handle.
- `disposeExpression(expression)` - frees a parsed expression handle.

Each call creates a fresh `Runtime` instance (stateless).

---

## 6. Utilities

**Files**: `lib/utils/`, `lib/extensions/`

Supporting infrastructure used across compiler stages:

- **`ListIterator`** - a cursor over a list with `next`, `peek`, `previous`, `advance()`, and `back()`. Used by the lexical and syntactic analyzers to traverse their input sequences.
- **`Stack`** - a generic LIFO data structure.
- **`FileReader`** - reads source files from disk (CLI only).
- **`Console`** - wraps platform console with colored output helpers (`warning()`, `error()`).
- **`LineEditor`** - a terminal line editor with command history navigation (up/down arrow keys, cursor movement). Used by the REPL.
- **`Mapper`** - converts a `List<FunctionTerm>` into a `Map<String, FunctionTerm>` keyed by function name.
- **String extensions** - character classification methods (`isDigit`, `isLetter`, `isWhitespace`, `isOperator`, `isDelimiter`, etc.) used extensively by the reader and lexer.

---

## 7. Design Patterns

| Pattern             | Where                                | Purpose                                                     |
| ------------------- | ------------------------------------ | ----------------------------------------------------------- |
| State machine       | Lexical analyzer, syntactic analyzer | Tokenization and function definition parsing                |
| Recursive descent   | Expression parser                    | Precedence-aware expression parsing                         |
| Substitution model  | Runtime evaluation                   | Function application via variable substitution              |
| Strategy            | Platform abstraction                 | CLI vs. web I/O implementations                             |
| Two-class native    | Standard library                     | Separate declaration from evaluation for built-in functions |
| Analyzer base class | All pipeline stages                  | Uniform `Analyzer<Input, Output>` interface                 |
