---
title: Native Functions
tags:
  - architecture
  - stdlib
sources:
  - lib/compiler/runtime/term.dart
  - lib/compiler/library/standard_library.dart
  - lib/compiler/library/arithmetic/num_add.dart
  - lib/compiler/library/control/if.dart
  - lib/compiler/library/list/list_map.dart
---

# Native Functions

**TLDR**: Native functions are built-in standard library functions implemented in Dart using a two-class pattern: a definition class declaring the function signature, and an evaluation class implementing the computation logic.

## Overview

Primal's standard library consists of native functions implemented directly in Dart. These functions extend `NativeFunctionTerm` and follow a consistent two-class pattern that separates declaration from evaluation. This design enables lazy evaluation by deferring argument reduction to the evaluation phase.

## The Two-Class Pattern

Every native function consists of:

1. **Definition class** (`NativeFunctionTerm` subclass): Declares the function name, parameters, and types.
2. **Evaluation class** (`NativeFunctionTermWithArguments` subclass): Implements the actual computation logic.

### Example: `num.add`

```dart
// From lib/compiler/library/arithmetic/num_add.dart

// 1. Definition class - declares signature
class NumAdd extends NativeFunctionTerm {
  const NumAdd()
    : super(
        name: 'num.add',
        parameters: const [
          Parameter.number('a'),
          Parameter.number('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

// 2. Evaluation class - implements logic
class TermWithArguments extends NativeFunctionTermWithArguments {
  const TermWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();
    final Term b = arguments[1].reduce();

    if ((a is NumberTerm) && (b is NumberTerm)) {
      return NumberTerm(a.value + b.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
```

## How Native Functions Work

### Substitution Phase

When a native function is applied, `NativeFunctionTerm.substitute()` resolves arguments from bindings without reducing them:

```dart
// From lib/compiler/runtime/term.dart
abstract class NativeFunctionTerm extends FunctionTerm {
  @override
  Term substitute(Bindings bindings) {
    final List<Term> arguments = parameters
        .map((e) => bindings.get(e.name))
        .toList();

    return term(arguments);  // Arguments NOT reduced
  }

  Term term(List<Term> arguments);
}
```

The `term()` method creates an instance of the evaluation class holding the unreduced arguments.

### Evaluation Phase

The evaluation class's `reduce()` method receives the arguments and decides when to evaluate each one:

```dart
abstract class NativeFunctionTermWithArguments extends FunctionTerm {
  final List<Term> arguments;

  @override
  Term reduce();  // Subclasses implement actual logic
}
```

This separation enables lazy evaluation for functions like `if` that should not evaluate all arguments.

## Type Checking in Native Functions

Type checking happens at runtime in the `reduce()` method:

1. **Reduce the argument**: Call `arguments[i].reduce()` to get the value.
2. **Check the type**: Use `is` checks against expected term types.
3. **Handle type errors**: Throw `InvalidArgumentTypesError` if types do not match.

```dart
@override
Term reduce() {
  final Term a = arguments[0].reduce();
  final Term b = arguments[1].reduce();

  if ((a is ListTerm) && (b is FunctionTerm)) {
    // Type-safe logic here
  } else {
    throw InvalidArgumentTypesError(
      function: name,
      expected: parameterTypes,
      actual: [a.type, b.type],
    );
  }
}
```

The `Parameter` declarations in the definition class provide expected types for error messages via `parameterTypes`.

## Common Patterns

### Eager Evaluation (Most Functions)

Most functions reduce all arguments immediately:

```dart
@override
Term reduce() {
  final Term a = arguments[0].reduce();
  final Term b = arguments[1].reduce();
  // Use a and b
}
```

### Lazy Evaluation (Control Flow)

Control flow functions selectively reduce arguments:

```dart
// From lib/compiler/library/control/if.dart
@override
Term reduce() {
  final Term a = arguments[0].reduce();  // Always evaluate condition
  final Term b = arguments[1];            // Leave unreduced
  final Term c = arguments[2];            // Leave unreduced

  if (a is BooleanTerm) {
    if (a.value) {
      return b.reduce();  // Evaluate only if needed
    } else {
      return c.reduce();  // Evaluate only if needed
    }
  } else {
    throw InvalidArgumentTypesError(...);
  }
}
```

### Higher-Order Functions

Functions that accept function arguments apply them using `FunctionTerm.apply()`:

```dart
// From lib/compiler/library/list/list_map.dart
@override
Term reduce() {
  final Term a = arguments[0].reduce();
  final Term b = arguments[1].reduce();

  if ((a is ListTerm) && (b is FunctionTerm)) {
    final List<Term> result = [];

    for (final Term element in a.value) {
      final Term value = b.apply([element]);
      result.add(value);
    }

    return ListTerm(result);
  } else {
    throw InvalidArgumentTypesError(...);
  }
}
```

### Returning Collections

Functions that return collections wrap results in the appropriate term type:

```dart
return ListTerm(result);
return MapTerm(Map.fromEntries(entries));
return SetTerm(values.toSet());
```

### Using ValueTerm.from()

For dynamic value wrapping, use the `ValueTerm.from()` factory:

```dart
return ValueTerm.from(computedDartValue);
```

This factory handles: `bool`, `num`, `String`, `DateTime`, `File`, `Directory`, `Set<Term>`, `List<Term>`, `Map<Term, Term>`.

## Adding a New Native Function

### Step 1: Create the File

Create a new Dart file in the appropriate subdirectory of `lib/compiler/library/`:

```
lib/compiler/library/
├── arithmetic/     # Numeric operations
├── casting/        # Type checking and conversion
├── comparison/     # Comparison operators
├── console/        # Console I/O
├── control/        # Control flow (if, try)
├── directory/      # Directory operations
├── file/           # File operations
├── list/           # List operations
├── logic/          # Boolean operations
├── map/            # Map operations
├── operators/      # Infix operators
├── set/            # Set operations
├── string/         # String operations
└── ...
```

### Step 2: Define the Function Class

```dart
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class MyFunction extends NativeFunctionTerm {
  const MyFunction()
    : super(
        name: 'namespace.function',  // e.g., 'list.reverse', 'str.length'
        parameters: const [
          Parameter.list('items'),    // Use appropriate Parameter factory
          Parameter.number('count'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}
```

### Step 3: Define the Evaluation Class

```dart
class TermWithArguments extends NativeFunctionTermWithArguments {
  const TermWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    // 1. Reduce arguments as needed
    final Term items = arguments[0].reduce();
    final Term count = arguments[1].reduce();

    // 2. Type check
    if ((items is ListTerm) && (count is NumberTerm)) {
      // 3. Perform computation
      final List<Term> result = /* computation */;

      // 4. Return appropriate term type
      return ListTerm(result);
    } else {
      // 5. Handle type errors
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [items.type, count.type],
      );
    }
  }
}
```

### Step 4: Register in StandardLibrary

Add the function to `lib/compiler/library/standard_library.dart`:

```dart
import 'package:primal/compiler/library/namespace/my_function.dart';

class StandardLibrary {
  static List<FunctionTerm> get() => [
    // ... existing functions ...

    // Namespace
    const MyFunction(),
  ];
}
```

### Step 5: Export from Library

Add the export to the library barrel file if one exists for the namespace.

## Parameter Factories

The `Parameter` class provides typed factories for common parameter types:

| Factory                       | Type      |
| ----------------------------- | --------- |
| `Parameter.any('name')`       | Any       |
| `Parameter.boolean('name')`   | Boolean   |
| `Parameter.number('name')`    | Number    |
| `Parameter.string('name')`    | String    |
| `Parameter.list('name')`      | List      |
| `Parameter.map('name')`       | Map       |
| `Parameter.set('name')`       | Set       |
| `Parameter.function('name')`  | Function  |
| `Parameter.file('name')`      | File      |
| `Parameter.directory('name')` | Directory |
| `Parameter.timestamp('name')` | Timestamp |

## Error Types

Native functions typically throw these runtime errors:

| Error Type                  | When                                              |
| --------------------------- | ------------------------------------------------- |
| `InvalidArgumentTypesError` | Arguments have wrong types                        |
| `InvalidArgumentCountError` | Wrong number of arguments (handled by base class) |
| `IndexOutOfBoundsError`     | List/string index invalid                         |
| `KeyNotFoundError`          | Map key does not exist                            |
| `DivisionByZeroError`       | Division or modulo by zero                        |
| `InvalidValueError`         | Value cannot be processed                         |

## Standard Library Organization

Functions are organized by namespace prefix:

| Prefix   | Domain          | Example Functions                        |
| -------- | --------------- | ---------------------------------------- |
| `num.*`  | Arithmetic      | `num.add`, `num.sqrt`, `num.max`         |
| `bool.*` | Logic           | `bool.and`, `bool.or`, `bool.not`        |
| `str.*`  | Strings         | `str.length`, `str.concat`, `str.split`  |
| `list.*` | Lists           | `list.map`, `list.filter`, `list.reduce` |
| `map.*`  | Maps            | `map.at`, `map.keys`, `map.set`          |
| `set.*`  | Sets            | `set.add`, `set.union`, `set.contains`   |
| `file.*` | File I/O        | `file.read`, `file.write`, `file.exists` |
| `dir.*`  | Directory I/O   | `dir.list`, `dir.create`, `dir.delete`   |
| `time.*` | Timestamps      | `time.now`, `time.format`, `time.year`   |
| `json.*` | JSON            | `json.encode`, `json.decode`             |
| `comp.*` | Comparison      | `comp.eq`, `comp.lt`, `comp.gt`          |
| `is.*`   | Type checking   | `is.number`, `is.string`, `is.list`      |
| `to.*`   | Type conversion | `to.integer`, `to.string`, `to.list`     |

Control flow functions (`if`, `try`) and infix operators (`+`, `-`, `&&`, etc.) use simple names without namespace prefixes.
