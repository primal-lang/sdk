# Shared Compiler Models

**Directory**: `lib/compiler/models/`

Models in this directory are shared across multiple compiler phases. They represent core concepts that are phase-agnostic and can be used by any stage of the pipeline.

## Location

**File**: `lib/compiler/models/location.dart`

Represents a position in source code:

| Field    | Type  | Description               |
| -------- | ----- | ------------------------- |
| `row`    | `int` | Line number (1-indexed)   |
| `column` | `int` | Column number (1-indexed) |

Used by all phases to track source positions for error reporting.

## Located

**File**: `lib/compiler/models/located.dart`

Base class for objects that have a source location:

```dart
class Located {
  final Location location;

  const Located({required this.location});
}
```

Equality is based on `location`.

Extended by `Character`, `Token<T>`, `Lexeme`, `Expression`, `MapEntryExpression`, and other AST types.

## Parameter

**File**: `lib/compiler/models/parameter.dart`

Represents a function parameter:

| Field  | Type     | Description                                     |
| ------ | -------- | ----------------------------------------------- |
| `name` | `String` | Parameter name                                  |
| `type` | `Type`   | Type constraint (e.g., `NumberType`, `AnyType`) |

Factory constructors provide convenient creation:

- `Parameter.boolean(name)` - boolean parameter
- `Parameter.number(name)` - numeric parameter
- `Parameter.string(name)` - string parameter
- `Parameter.file(name)` - file parameter
- `Parameter.directory(name)` - directory parameter
- `Parameter.timestamp(name)` - timestamp parameter
- `Parameter.list(name)` - list parameter
- `Parameter.vector(name)` - vector parameter
- `Parameter.set(name)` - set parameter
- `Parameter.stack(name)` - stack parameter
- `Parameter.queue(name)` - queue parameter
- `Parameter.map(name)` - map parameter
- `Parameter.function(name)` - function parameter
- `Parameter.any(name)` - accepts any type
- `Parameter.ordered(name)` - ordered parameter (Number, String, Timestamp)
- `Parameter.equatable(name)` - equatable parameter
- `Parameter.hashable(name)` - hashable parameter
- `Parameter.indexable(name)` - indexable parameter (String, List, Map)
- `Parameter.collection(name)` - collection parameter (List, Set, Stack, Queue, Map)
- `Parameter.iterable(name)` - iterable parameter (String, List, Set, Stack, Queue)
- `Parameter.addable(name)` - addable parameter (Number, String, Vector, List, Set)
- `Parameter.subtractable(name)` - subtractable parameter (Number, Vector, Set)

## FunctionSignature

**File**: `lib/compiler/models/function_signature.dart`

A phase-agnostic representation of a function's calling interface:

| Field        | Type              | Description                     |
| ------------ | ----------------- | ------------------------------- |
| `name`       | `String`          | Function name                   |
| `parameters` | `List<Parameter>` | Parameter definitions           |
| `arity`      | `int`             | Number of parameters (computed) |

Used during semantic analysis to validate function calls without depending on runtime types. This enables clean separation between the semantic and runtime phases.

### Relationship to FunctionTerm

| Aspect             | FunctionSignature | FunctionTerm |
| ------------------ | ----------------- | ------------ |
| Phase              | Semantic          | Runtime      |
| Purpose            | Call validation   | Execution    |
| Has `reduce()`     | No                | Yes          |
| Has `substitute()` | No                | Yes          |
| Location           | `models/`         | `runtime/`   |

`FunctionTerm.toSignature()` creates a `FunctionSignature` from a `FunctionTerm`.

## Type

**File**: `lib/compiler/models/type.dart`

Base class for type representations. See [compiler.md](../compiler.md#1-type-system) for the full type hierarchy.

## Analyzer

**File**: `lib/compiler/models/analyzer.dart`

Abstract base class for pipeline stages:

```dart
abstract class Analyzer<I, O> {
  final I input;

  const Analyzer(this.input);

  O analyze();
}
```

Implemented by `SourceReader`, `LexicalAnalyzer`, `SyntacticAnalyzer`, and `SemanticAnalyzer`.

## State

**File**: `lib/compiler/models/state.dart`

Pairs a `ListIterator` with an accumulated output value, used during parsing to thread iterator position through recursive descent:

```dart
class State<I, O> {
  final O output;
  final ListIterator<I> iterator;

  const State(this.iterator, this.output);

  State get next => process(iterator.next);

  State process(I input) => this;
}
```

| Field      | Type              | Description                          |
| ---------- | ----------------- | ------------------------------------ |
| `output`   | `O`               | Accumulated result of processing     |
| `iterator` | `ListIterator<I>` | Current position in the input stream |

- `next` - advances the iterator and processes the next element
- `process(input)` - base implementation returns `this` unchanged; subclasses override to define state transitions
