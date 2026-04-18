---
title: Term Hierarchy
tags:
  - architecture
  - runtime
sources:
  - lib/compiler/runtime/term.dart
  - lib/compiler/runtime/runtime.dart
---

# Term Hierarchy

**TLDR**: The runtime represents all values and computations as `Term` objects organized in a class hierarchy, where `reduce()` evaluates terms to values and `substitute()` replaces bound variables with their argument values.

## Overview

Primal's runtime uses a term-based evaluation model inspired by lambda calculus. Every runtime value and pending computation is represented as a `Term`. The evaluation process consists of substitution (binding arguments to parameters) followed by reduction (computing the final value).

## The Term Base Class

All runtime entities extend the abstract `Term` class:

```dart
// From lib/compiler/runtime/term.dart
abstract class Term {
  const Term();

  Type get type;                              // The term's type
  Term substitute(Bindings bindings) => this; // Replace bound variables
  Term reduce() => this;                      // Evaluate to a value
  dynamic native();                           // Convert to Dart value
}
```

### The `reduce()` Contract

The `reduce()` method implements the evaluation semantics:

- **Value terms**: Return `this`. They are already fully evaluated.
- **Reference terms**: Look up and return the referenced value.
- **Computation terms**: Perform the computation and return the result.

A term is considered a **value** if `reduce()` returns itself unchanged. A term is considered a **computation** if `reduce()` performs work and may return a different term.

### The `substitute()` Contract

The `substitute()` method replaces bound variable references with their values:

- **Value terms**: Return `this`. They contain no variable references.
- **Variable terms**: Return the bound value from bindings, or `this` if unbound.
- **Compound terms**: Recursively substitute into sub-terms.

## Term Categories

### Value Terms

`ValueTerm<T>` is the abstract base for all terms that hold a typed Dart value:

```dart
abstract class ValueTerm<T> implements Term {
  final T value;

  Term substitute(Bindings bindings) => this;  // Values are closed
  Term reduce() => this;                        // Values are fully evaluated
  dynamic native() => value;                    // Unwrap to Dart
}
```

**Literal Terms** (extend `ValueTerm`):

| Term Class      | Dart Type   | Primal Type |
| --------------- | ----------- | ----------- |
| `BooleanTerm`   | `bool`      | Boolean     |
| `NumberTerm`    | `num`       | Number      |
| `StringTerm`    | `String`    | String      |
| `FileTerm`      | `File`      | File        |
| `DirectoryTerm` | `Directory` | Directory   |
| `TimestampTerm` | `DateTime`  | Timestamp   |

**Collection Terms** (extend `ValueTerm`):

| Term Class   | Dart Type         | Primal Type |
| ------------ | ----------------- | ----------- |
| `ListTerm`   | `List<Term>`      | List        |
| `VectorTerm` | `List<Term>`      | Vector      |
| `SetTerm`    | `Set<Term>`       | Set         |
| `StackTerm`  | `List<Term>`      | Stack       |
| `QueueTerm`  | `List<Term>`      | Queue       |
| `MapTerm`    | `Map<Term, Term>` | Map         |

Collection terms override `substitute()` to recurse into their elements, and override `native()` to return unwrapped Dart collections.

### Reference Terms

Reference terms represent bindings that must be resolved:

**`FunctionReferenceTerm`** - Holds a function name and the functions map. Resolution happens at evaluation time:

```dart
class FunctionReferenceTerm extends Term {
  final String name;
  final Map<String, FunctionTerm> functions;

  @override
  FunctionTerm reduce() {
    final FunctionTerm? function = functions[name];
    if (function == null) {
      throw NotFoundInScopeError(name);
    }
    return function;
  }
}
```

**`BoundVariableTerm`** - Represents a function parameter reference. Must be substituted before evaluation:

```dart
class BoundVariableTerm extends Term {
  final String name;

  @override
  Term substitute(Bindings bindings) => bindings.get(name);
}
```

**`LetBoundVariableTerm`** - Represents a let binding reference. Uses partial substitution (returns `this` if name not in bindings):

```dart
class LetBoundVariableTerm extends Term {
  final String name;

  @override
  Term substitute(Bindings bindings) =>
      bindings.data.containsKey(name) ? bindings.data[name]! : this;
}
```

**`LambdaBoundVariableTerm`** - Represents a lambda parameter reference. Also uses partial substitution to support closures.

### Computation Terms

**`CallTerm`** - Represents a function application:

```dart
class CallTerm extends Term {
  final Term callee;
  final List<Term> arguments;

  @override
  Term reduce() {
    final FunctionTerm function = getFunctionTerm(callee);
    return function.apply(arguments);
  }

  @override
  Term substitute(Bindings bindings) => CallTerm(
    callee: callee.substitute(bindings),
    arguments: arguments.map((e) => e.substitute(bindings)).toList(),
  );
}
```

**`LetTerm`** - Represents a let expression with local bindings:

```dart
class LetTerm extends Term {
  final List<(String, Term)> bindings;
  final Term body;

  @override
  Term reduce() {
    final Map<String, Term> bindingMap = {};
    for (final (String name, Term term) in bindings) {
      final Term substituted = term.substitute(Bindings(Map.of(bindingMap)));
      final Term value = substituted.reduce();
      bindingMap[name] = value;
    }
    return body.substitute(Bindings(bindingMap)).reduce();
  }
}
```

### Function Terms

`FunctionTerm` is the abstract base for all callable terms:

```dart
abstract class FunctionTerm extends Term {
  final String name;
  final List<Parameter> parameters;

  Term apply(List<Term> arguments) {
    // Validate argument count
    // Create bindings from parameters and arguments
    // Substitute and reduce
  }
}
```

**`CustomFunctionTerm`** - User-defined functions with eager argument evaluation:

```dart
class CustomFunctionTerm extends FunctionTerm {
  final Term term;  // The function body

  @override
  Term apply(List<Term> arguments) {
    FunctionTerm.incrementDepth();  // Track recursion
    try {
      // Eagerly evaluate all arguments (call-by-value)
      final List<Term> evaluatedArguments = arguments
          .map((argument) => argument.reduce())
          .toList();

      final Bindings bindings = Bindings.from(
        parameters: parameters,
        arguments: evaluatedArguments,
      );

      return term.substitute(bindings).reduce();
    } finally {
      FunctionTerm.decrementDepth();
    }
  }

  @override
  Term substitute(Bindings bindings) => this;  // Closed over definition environment
}
```

**`LambdaTerm`** - Anonymous functions that support closures:

```dart
class LambdaTerm extends FunctionTerm {
  final Term body;

  @override
  Term substitute(Bindings bindings) {
    // Filter out this lambda's own parameters to prevent shadowing issues
    final Map<String, Term> filteredBindings = Map.of(bindings.data);
    for (final Parameter parameter in parameters) {
      filteredBindings.remove(parameter.name);
    }

    return LambdaTerm(
      name: name,
      parameters: parameters,
      body: body.substitute(Bindings(filteredBindings)),
    );
  }

  @override
  Term reduce() => this;  // Lambdas are values
}
```

**`NativeFunctionTerm`** - Built-in functions implemented in Dart:

```dart
abstract class NativeFunctionTerm extends FunctionTerm {
  @override
  Term substitute(Bindings bindings) {
    final List<Term> arguments = parameters
        .map((e) => bindings.get(e.name))
        .toList();

    return term(arguments);
  }

  Term term(List<Term> arguments);  // Returns the evaluation term
}
```

**`NativeFunctionTermWithArguments`** - Holds resolved arguments for deferred evaluation:

```dart
abstract class NativeFunctionTermWithArguments extends FunctionTerm {
  final List<Term> arguments;

  @override
  Term reduce();  // Subclasses implement the actual logic
}
```

## Evaluation Flow

1. **Substitution Phase**: `substitute(bindings)` replaces `BoundVariableTerm` references with their argument values throughout the term tree.

2. **Reduction Phase**: `reduce()` evaluates the substituted term:
   - Value terms return themselves
   - `CallTerm` reduces the callee, then applies it to arguments
   - `LetTerm` evaluates bindings sequentially, substitutes into body, reduces

3. **Native Extraction**: `native()` converts the final `Term` back to a Dart value for output.

## Recursion Tracking

`FunctionTerm` maintains a static recursion depth counter to prevent stack overflow:

```dart
abstract class FunctionTerm extends Term {
  static const int maxRecursionDepth = 1000;
  static int _currentDepth = 0;

  static void resetDepth() => _currentDepth = 0;
  static bool incrementDepth() {
    if (_currentDepth >= maxRecursionDepth) {
      throw RecursionLimitError(limit: maxRecursionDepth);
    }
    _currentDepth++;
    return true;
  }
  static void decrementDepth() => _currentDepth--;
}
```

Both `CustomFunctionTerm` and `LambdaTerm` increment/decrement this counter in their `apply()` methods.

## Type Hierarchy Diagram

```
Term (abstract)
├── ValueTerm<T> (abstract)
│   ├── BooleanTerm
│   ├── NumberTerm
│   ├── StringTerm
│   ├── FileTerm
│   ├── DirectoryTerm
│   ├── TimestampTerm
│   ├── ListTerm
│   ├── VectorTerm
│   ├── SetTerm
│   ├── StackTerm
│   ├── QueueTerm
│   └── MapTerm
├── FunctionReferenceTerm
├── BoundVariableTerm
├── LetBoundVariableTerm
├── LambdaBoundVariableTerm
├── CallTerm
├── LetTerm
└── FunctionTerm (abstract)
    ├── CustomFunctionTerm
    ├── LambdaTerm
    ├── NativeFunctionTerm (abstract)
    └── NativeFunctionTermWithArguments (abstract)
```
