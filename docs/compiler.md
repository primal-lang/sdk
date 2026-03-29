# Compiler Architecture

The Primal compiler is a four-stage pipeline that transforms source code into an executable intermediate representation. It is implemented in Dart and supports both CLI and web targets.

```
Source Code
    |
    v
 Scanner ............. Characters with locations
    |
    v
 Lexical Analyzer .... Tokens (keywords, literals, operators, delimiters)
    |
    v
 Syntactic Analyzer .. Function definitions with expression trees
    |
    v
 Semantic Analyzer ... Intermediate code (validated, scope-resolved functions)
    |
    v
 Runtime ............. Evaluation via node substitution and reduction
```

The entry point is `Compiler.compile(String input)` in `lib/compiler/compiler.dart`, which runs the first four stages in sequence. The resulting `IntermediateCode` is then handed to the `Runtime` for execution.

---

## 1. Scanner

**File**: `lib/compiler/scanner/scanner_analyzer.dart`

The scanner converts a raw input string into a flat list of `Character` objects, each annotated with its row and column position.

- Iterates over UTF-8 runes and wraps each in a `Character(value, row, column)`.
- Handles shebang lines (`#!` on the first line) by skipping them.
- Injects newline characters between rows so downstream stages can rely on consistent line boundaries.

The output preserves every character from the source (including whitespace), with location information used later for error reporting.

---

## 2. Lexical Analysis

**Files**: `lib/compiler/lexical/lexical_analyzer.dart`, `lib/compiler/lexical/token.dart`

The lexical analyzer consumes the character list and produces a list of typed tokens. It is implemented as a **state machine** with 20+ state classes, each responsible for recognizing a specific kind of lexeme.

### State Machine

The analyzer starts in `InitState` and transitions based on the current character:

| Character class                                   | Target state                              |
| ------------------------------------------------- | ----------------------------------------- |
| Letter                                            | `IdentifierState`                         |
| Digit                                             | `IntegerState`                            |
| `"`                                               | `StringDoubleQuoteState`                  |
| `'`                                               | `StringSingleQuoteState`                  |
| `+`                                               | `PlusState`                               |
| `-`                                               | `MinusState`                              |
| `=`                                               | `EqualsState`                             |
| `>`                                               | `GreaterState`                            |
| `<`                                               | `LessState`                               |
| `\|`                                              | `PipeState`                               |
| `&`                                               | `AmpersandState`                          |
| `!`                                               | `BangState`                               |
| `/`                                               | `ForwardSlashState` (division or comment) |
| Delimiters `(`, `)`, `[`, `]`, `{`, `}`, `,`, `:` | Corresponding delimiter states            |
| Whitespace / newline                              | Skipped, returns to `InitState`           |

Multi-character tokens are accumulated via a `Lexeme` object that tracks the starting location and collects characters with `.add(Character)`.

### Token Types

All tokens extend `Token<T>` and carry a typed value plus location:

- **Literals**: `StringToken`, `NumberToken`, `BooleanToken`
- **Identifiers**: `IdentifierToken` (variable and function names)
- **Keywords**: `IfToken`, `ElseToken`
- **Assignment**: `AssignToken` (`=`)
- **Binary operators**: `PlusToken`, `MinusToken`, `AsteriskToken`, `ForwardSlashToken`, `PercentToken`, `PipeToken`, `AmpersandToken`, `EqualToken`, `NotEqualToken`, `GreaterThanToken`, `GreaterEqualThanToken`, `LessThanToken`, `LessEqualThanToken`
- **Unary operators**: `BangToken`
- **Delimiters**: `OpenParenthesisToken`, `CloseParenthesisToken`, `OpenBracketToken`, `CloseBracketToken`, `OpenBracesToken`, `CloseBracesToken`, `CommaToken`, `ColonToken`

Comments (single-line `//` and multi-line `/* */`) are recognized and discarded.

---

## 3. Syntactic Analysis

**Files**: `lib/compiler/syntactic/syntactic_analyzer.dart`, `lib/compiler/syntactic/function_definition.dart`, `lib/compiler/syntactic/expression_parser.dart`, `lib/compiler/syntactic/expression.dart`

The syntactic analyzer (parser) converts the token list into a list of `FunctionDefinition` objects, each containing a name, parameter list, and an expression tree.

### Function Definition Parsing

A state machine parses top-level function definitions:

```
identifier = expression               -- nullary function
identifier(p1, p2, ...) = expression  -- parameterized function
```

States:

1. `InitState` - expects an identifier (the function name).
2. `FunctionNameState` - expects either `=` (nullary) or `(` (parameterized).
3. `FunctionWithParametersState` / `FunctionWithNewParametersState` / `FunctionWithNextParametersState` - parse the comma-separated parameter list.
4. `FunctionParametrizedState` - expects `=` after closing `)`.
5. `ResultState` - expression parsing is complete; one `FunctionDefinition` is emitted.

### Expression Parser

The expression parser is a **recursive descent parser** with the following precedence levels (lowest to highest):

| Precedence | Rule           | Operators / Forms                                  |
| ---------- | -------------- | -------------------------------------------------- |
| 1          | `ifExpression` | `if (cond) expr else expr`                         |
| 2          | `equality`     | `==`, `!=`                                         |
| 3          | `comparison`   | `>`, `>=`, `<`, `<=`                               |
| 4          | `logic`        | `\|` (or), `&` (and)                               |
| 5          | `term`         | `+`, `-`                                           |
| 6          | `factor`       | `*`, `/`, `%`                                      |
| 7          | `unary`        | `!`, `-` (negation)                                |
| 8          | `call`         | function application `f(args)`, indexing `a[i]`    |
| 9          | `primary`      | literals, identifiers, `(expr)`, `[list]`, `{map}` |

### Expression Tree

All expressions extend `Expression` (which has a `Location`):

- `LiteralExpression<T>` - base for all literal values
  - `BooleanExpression`, `NumberExpression`, `StringExpression`
  - `ListExpression` (contains `List<Expression>`)
  - `MapExpression` (contains `Map<Expression, Expression>`)
- `IdentifierExpression` - a named reference (variable or function)
- `CallExpression` - function application (callee expression + argument list)
  - Also used to represent binary and unary operators via factory constructors (`fromBinaryOperation`, `fromUnaryOperation`, `fromIf`)

Operators and `if` expressions are desugared into `CallExpression` nodes at parse time, unifying all computation as function application.

---

## 4. Semantic Analysis

**File**: `lib/compiler/semantic/semantic_analyzer.dart`

The semantic analyzer validates the parsed function definitions and produces `IntermediateCode`. It performs the following checks:

1. **Function extraction** - converts each `FunctionDefinition` into a `CustomFunctionNode` with typed parameters.
2. **Duplicate function detection** - reports an error if two functions share the same name.
3. **Duplicate parameter detection** - reports an error if a function has repeated parameter names.
4. **Identifier resolution** - for every `FreeVariableNode` in a function body:
   - If it matches a parameter name, it is converted to a `BoundedVariableNode`.
   - If it matches a known function name (custom or standard library), it remains a `FreeVariableNode` (resolved at runtime via scope).
   - Otherwise, an `UndefinedIdentifierError` is raised.
5. **Call validation** - for every `CallNode`, the argument count is checked against the callee's parameter count.
6. **Unused parameter warnings** - parameters that are never referenced in the function body produce a warning.

Nested structures (`CallNode`, `ListNode`, `MapNode`) are checked recursively.

### Intermediate Code

The output of semantic analysis is `IntermediateCode` (`lib/compiler/semantic/intermediate_code.dart`):

- `functions`: `Map<String, FunctionNode>` - all functions (user-defined + standard library), keyed by name.
- `warnings`: `List<GenericWarning>` - any warnings produced during analysis.

---

## 5. Runtime

**Files**: `lib/compiler/runtime/runtime.dart`, `lib/compiler/runtime/node.dart`, `lib/compiler/runtime/bindings.dart`, `lib/compiler/runtime/scope.dart`

The runtime evaluates intermediate code through **node substitution and reduction**.

### Node Hierarchy

All runtime values are nodes. The base `Node` class defines:

- `type` - returns the node's `Type`.
- `substitute(Bindings)` - replaces bound variables with their argument values.
- `evaluate()` - reduces the node to a value.
- `native()` - converts to a native Dart value.

**Literal nodes** (self-evaluating):
`BooleanNode`, `NumberNode`, `StringNode`, `FileNode`, `DirectoryNode`, `TimestampNode`

**Collection nodes** (substitute recursively; self-evaluating):
`ListNode`, `MapNode`, `SetNode`, `VectorNode`, `StackNode`, `QueueNode`

**Variable nodes**:

- `FreeVariableNode(name)` - resolved at runtime by looking up `name` in the global scope.
- `BoundedVariableNode(name)` - replaced during substitution via bindings.

**Call node**:
`CallNode(callee, arguments)` - on evaluation, evaluates the callee to a `FunctionNode`, then calls `apply()` with the arguments.

**Function nodes**:

- `FunctionNode` - base, with name and parameters.
- `CustomFunctionNode` - user-defined; `apply()` substitutes arguments into the body, then evaluates.
- `NativeFunctionNode` - built-in; delegates to a Dart implementation.

### Evaluation Model

Function application follows these steps:

1. Evaluate the callee expression to get a `FunctionNode`.
2. Create `Bindings` from the function's parameters and the provided arguments.
3. Substitute all `BoundedVariableNode`s in the function body with their bound values.
4. Evaluate the resulting node.

This is a substitution-based evaluation model consistent with lambda calculus reduction.

### Scope

`Scope` (`lib/compiler/runtime/scope.dart`) is a global map from function names to `FunctionNode` definitions, stored as `Runtime.SCOPE`. Free variables in function bodies are resolved against this scope at evaluation time.

---

## 6. Type System

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

## 7. Standard Library

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
| Other        | 3     | `element.at`, `env.get`, `throw`                        |

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

## 8. Error and Warning System

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

## 9. Platform Abstraction

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

## 10. Entry Points

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

## 11. Utilities

**Files**: `lib/utils/`, `lib/extensions/`

Supporting infrastructure used across compiler stages:

- **`ListIterator`** - a cursor over a list with `next`, `peek`, `previous`, `advance()`, and `back()`. Used by the lexical and syntactic analyzers to traverse their input sequences.
- **`Stack`** - a generic LIFO data structure. Used internally during parsing.
- **`FileReader`** - reads source files from disk (CLI only).
- **`Console`** - wraps platform console with colored output helpers (`warning()`, `error()`).
- **`Mapper`** - converts a `List<FunctionNode>` into a `Map<String, FunctionNode>` keyed by function name.
- **String extensions** - character classification methods (`isDigit`, `isLetter`, `isWhitespace`, `isOperator`, `isDelimiter`, etc.) used extensively by the scanner and lexer.

---

## 12. Design Patterns

| Pattern             | Where                                | Purpose                                                     |
| ------------------- | ------------------------------------ | ----------------------------------------------------------- |
| State machine       | Lexical analyzer, syntactic analyzer | Tokenization and function definition parsing                |
| Recursive descent   | Expression parser                    | Precedence-aware expression parsing                         |
| Substitution model  | Runtime evaluation                   | Function application via variable substitution              |
| Strategy            | Platform abstraction                 | CLI vs. web I/O implementations                             |
| Two-class native    | Standard library                     | Separate declaration from evaluation for built-in functions |
| Analyzer base class | All pipeline stages                  | Uniform `Analyzer<Input, Output>` interface                 |
