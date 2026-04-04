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

**File**: `lib/compiler/models/location.dart`

Mixin/base class for objects that have a source location:

```dart
mixin class Located {
  final Location location;
}
```

Extended by `Character`, `Token`, `Expression`, `SemanticNode`, and other AST types.

## Parameter

**File**: `lib/compiler/models/parameter.dart`

Represents a function parameter:

| Field  | Type     | Description                                     |
| ------ | -------- | ----------------------------------------------- |
| `name` | `String` | Parameter name                                  |
| `type` | `Type`   | Type constraint (e.g., `NumberType`, `AnyType`) |

Factory constructors provide convenient creation:

- `Parameter.number(name)` - numeric parameter
- `Parameter.string(name)` - string parameter
- `Parameter.boolean(name)` - boolean parameter
- `Parameter.list(name)` - list parameter
- `Parameter.any(name)` - accepts any type

## FunctionSignature

**File**: `lib/compiler/models/function_signature.dart`

A phase-agnostic representation of a function's calling interface:

| Field        | Type              | Description                     |
| ------------ | ----------------- | ------------------------------- |
| `name`       | `String`          | Function name                   |
| `parameters` | `List<Parameter>` | Parameter definitions           |
| `arity`      | `int`             | Number of parameters (computed) |

Used during semantic analysis to validate function calls without depending on runtime types. This enables clean separation between the semantic and runtime phases.

### Relationship to FunctionNode

| Aspect             | FunctionSignature | FunctionNode |
| ------------------ | ----------------- | ------------ |
| Phase              | Semantic          | Runtime      |
| Purpose            | Call validation   | Execution    |
| Has `evaluate()`   | No                | Yes          |
| Has `substitute()` | No                | Yes          |
| Location           | `models/`         | `runtime/`   |

`FunctionNode.toSignature()` creates a `FunctionSignature` from a `FunctionNode`.

## Type

**File**: `lib/compiler/models/type.dart`

Base class for type representations. See [compiler.md](../compiler.md#1-type-system) for the full type hierarchy.

## Analyzer

**File**: `lib/compiler/models/analyzer.dart`

Abstract base class for pipeline stages:

```dart
abstract class Analyzer<Input, Output> {
  const Analyzer();
  Output analyze();
}
```

Implemented by `LexicalAnalyzer`, `SyntacticAnalyzer`, and `SemanticAnalyzer`.
