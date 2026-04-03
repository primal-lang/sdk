# Compiler Architecture

The Primal compiler is a four-stage pipeline that transforms source code into an executable intermediate representation. It is implemented in Dart and supports both CLI and web targets.

```
Source Code
    |
    v
 Scanner ............. Characters with locations          → compiler/scanner.md
    |
    v
 Lexical Analyzer .... Tokens (keywords, literals, ...)   → compiler/lexical.md
    |
    v
 Syntactic Analyzer .. Function definitions with ASTs     → compiler/syntactic.md
    |
    v
 Semantic Analyzer ... Validated, scope-resolved functions → compiler/semantic.md
    |
    v
 Runtime ............. Evaluation via node substitution    → compiler/runtime.md
```

The entry point is `Compiler.compile(String input)` in `lib/compiler/compiler.dart`, which runs the first four stages in sequence. The resulting `IntermediateCode` is then handed to the `Runtime` for execution.

Each pipeline stage is documented in its own file under [`compiler/`](compiler/).

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

The standard library provides 230+ built-in functions, organized by namespace:

| Namespace    | Count | Examples                                                |
| ------------ | ----- | ------------------------------------------------------- |
| `num.*`      | 35    | `num.add`, `num.sqrt`, `num.sin`, `num.clamp`           |
| `str.*`      | 28    | `str.length`, `str.split`, `str.replace`, `str.reverse` |
| `list.*`     | 31    | `list.map`, `list.filter`, `list.reduce`, `list.sort`   |
| `bool.*`     | 4     | `bool.and`, `bool.or`, `bool.not`, `bool.xor`           |
| `comp.*`     | 6     | `comp.eq`, `comp.lt`, `comp.ge`                         |
| `map.*`      | 9     | `map.at`, `map.set`, `map.keys`, `map.values`           |
| `set.*`      | 8+    | `set.add`, `set.union`, `set.intersection`              |
| `stack.*`    | 8     | `stack.push`, `stack.pop`, `stack.peek`                 |
| `queue.*`    | 8     | `queue.enqueue`, `queue.dequeue`, `queue.peek`          |
| `vector.*`   | 6     | `vector.add`, `vector.magnitude`, `vector.normalize`    |
| `time.*`     | 12    | `time.now`, `time.from.iso`, `time.year`                |
| `file.*`     | 13    | `file.read`, `file.write`, `file.exists`                |
| `dir.*`      | 11    | `dir.create`, `dir.list`, `dir.exists`                  |
| `hash.*`     | 4     | `hash.md5`, `hash.sha256`                               |
| `json.*`     | 2     | `json.encode`, `json.decode`                            |
| `console.*`  | 3     | `console.write`, `console.read`                         |
| Casting      | 22    | `is.boolean`, `to.string`, `to.integer`                 |
| Operators    | 14    | `operator.add`, `operator.eq`, `operator.not`           |
| Control flow | 2     | `if`, `try`                                             |
| Other        | 3     | `@`, `env.get`, `throw`                                 |

### Implementation Pattern

Each native function follows a two-class pattern:

```dart
// 1. Definition class - declares name, parameters, and types
class FunctionName extends NativeFunctionNode {
  FunctionName() : super(
    name: 'namespace.function',
    parameters: [Parameter.type('arg1'), Parameter.any('arg2')],
  );

  @override
  Node node(List<Node> arguments) => _Node(
    name: name, parameters: parameters, arguments: arguments,
  );
}

// 2. Evaluation class - implements the actual logic
class _Node extends NativeFunctionNodeWithArguments {
  @override
  Node evaluate() {
    // Validate argument types, compute result, return a Node
  }
}
```

---

## 3. Error and Warning System

**Files**: `lib/compiler/errors/`, `lib/compiler/warnings/`

All diagnostics extend `GenericError(errorType, message)`.

### Compilation Errors

Raised during compilation and abort the pipeline:

| Stage     | Error                           | Cause                                  |
| --------- | ------------------------------- | -------------------------------------- |
| Lexical   | `InvalidCharacterError`         | Unrecognized character                 |
| Syntactic | `InvalidTokenError`             | Unexpected token in context            |
| Syntactic | `ExpectedTokenError`            | Missing required token                 |
| Syntactic | `UnexpectedEndOfFileError`      | Premature end of input                 |
| Semantic  | `DuplicatedFunctionError`       | Two functions with the same name       |
| Semantic  | `DuplicatedParameterError`      | Repeated parameter in a function       |
| Semantic  | `UndefinedIdentifierError`      | Reference to unknown variable/function |
| Semantic  | `UndefinedFunctionError`        | Call to unknown function               |
| Semantic  | `InvalidNumberOfArgumentsError` | Wrong argument count in a call         |
| Semantic  | `NotCallableError`              | Calling a non-callable literal         |
| Semantic  | `NotIndexableError`             | Indexing a non-indexable literal       |

### Runtime Errors

Raised during execution:

| Error                               | Cause                                       |
| ----------------------------------- | ------------------------------------------- |
| `InvalidArgumentTypesError`         | Wrong argument types for a native function  |
| `InvalidArgumentCountError`         | Wrong number of arguments at runtime        |
| `IterablesWithDifferentLengthError` | Mismatched collection lengths (e.g., `zip`) |
| `InvalidLiteralValueError`          | Invalid literal value                       |
| `InvalidValueError`                 | Invalid computed value                      |
| `InvalidMapIndexError`              | Key not found in map                        |
| `ElementNotFoundError`              | Element not in collection                   |
| `NotFoundInScopeError`              | Function not found in runtime scope         |
| `InvalidFunctionError`              | Callee is not a function                    |
| `UnimplementedFunctionWebError`     | I/O function called on web platform         |

### Warnings

Non-fatal diagnostics collected during semantic analysis:

- `UnusedParameterWarning` - a declared parameter is never used in the function body.

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

|                | CLI                       | Web                                                  |
| -------------- | ------------------------- | ---------------------------------------------------- |
| Console output | `stdout` / `stderr`       | `print()`                                            |
| Console input  | `stdin.readLineSync()`    | Unsupported                                          |
| File system    | `dart:io` synchronous API | Unsupported (throws `UnimplementedFunctionWebError`) |
| Environment    | `Platform.environment`    | Unsupported                                          |

The active platform is selected at startup based on the entry point (`main_cli.dart` or `main_web.dart`).

---

## 5. Entry Points

### CLI (`lib/main/main_cli.dart`)

1. Reads source code from a file path provided as the first command-line argument.
2. Compiles the source via `Compiler().compile()`.
3. Prints any warnings to the console.
4. If a `main` function is defined, executes it with the remaining CLI arguments.
5. Otherwise, enters a **REPL** loop where the user can type expressions and see their evaluated results.

### Web (`lib/main/main_web.dart`)

Exposes the compiler as a set of JavaScript-callable functions via Dart's JS interop:

- `compileInput(source)` - compiles source code to intermediate code.
- `compileExpression(expression)` - parses a single expression.
- `runtimeWarnings(code)` - extracts warnings from compiled code.
- `runtimeHasMain(code)` - checks if a main function exists.
- `runtimeExecuteMain(code)` - executes the main function.
- `runtimeReduce(code, expression)` - evaluates an expression.

Each call creates a fresh `Runtime` instance (stateless).

---

## 6. Utilities

**Files**: `lib/utils/`, `lib/extensions/`

Supporting infrastructure used across compiler stages:

- **`ListIterator`** - a cursor over a list with `next`, `peek`, `previous`, `advance()`, and `back()`. Used by the lexical and syntactic analyzers to traverse their input sequences.
- **`Stack`** - a generic LIFO data structure. Used internally during parsing.
- **`FileReader`** - reads source files from disk (CLI only).
- **`Console`** - wraps platform console with colored output helpers (`warning()`, `error()`).
- **`Mapper`** - converts a `List<FunctionNode>` into a `Map<String, FunctionNode>` keyed by function name.
- **String extensions** - character classification methods (`isDigit`, `isLetter`, `isWhitespace`, `isOperator`, `isDelimiter`, etc.) used extensively by the scanner and lexer.

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
