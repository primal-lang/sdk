---
title: Type Representations
tags:
  - architecture
  - types
sources:
  - lib/compiler/models/type.dart
  - lib/compiler/models/parameter.dart
---

# Type Representations

**TLDR**: Types in Primal are represented as immutable Dart objects extending the `Type` base class. The type system includes primitive types, collection types, a wildcard `AnyType`, `FunctionType` for callable values, and type classes that group types by shared behavior.

## Type Base Class

All types extend the `Type` base class defined in `lib/compiler/models/type.dart`:

```dart
class Type {
  const Type();

  bool accepts(Type actualType) => this == actualType;

  @override
  bool operator ==(Object other) => runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
```

Key characteristics:

- **Immutable**: All type instances are `const` constructors.
- **Singleton pattern**: Type equality is based on `runtimeType`, so `const NumberType() == const NumberType()` is always `true`.
- **accepts()**: Determines if a type specification accepts a given actual type. By default, requires exact type equality.

## Primitive Types

Primitive types represent atomic values:

| Type            | Dart Backing Type | Description             |
| --------------- | ----------------- | ----------------------- |
| `BooleanType`   | `bool`            | Boolean true/false      |
| `NumberType`    | `num`             | Integers and decimals   |
| `StringType`    | `String`          | Text values             |
| `FileType`      | `File`            | File system files       |
| `DirectoryType` | `Directory`       | File system directories |
| `TimestampType` | `DateTime`        | Date and time values    |
| `DurationType`  | `Duration`        | Time span values        |

Each primitive type class is a simple extension with a `toString()` override:

```dart
class NumberType extends Type {
  const NumberType();

  @override
  String toString() => 'Number';
}
```

## Collection Types

Collection types represent compound data structures:

| Type         | Dart Backing Type | Description                         |
| ------------ | ----------------- | ----------------------------------- |
| `ListType`   | `List<Term>`      | Ordered, indexable sequences        |
| `VectorType` | `List<Term>`      | Fixed-size numeric vectors          |
| `SetType`    | `Set<Term>`       | Unordered unique element sets       |
| `StackType`  | `List<Term>`      | LIFO (last-in-first-out) structure  |
| `QueueType`  | `List<Term>`      | FIFO (first-in-first-out) structure |
| `MapType`    | `Map<Term, Term>` | Key-value associations              |

Note: Collection types are not parameterized. A `ListType` does not carry element type information at the type level. Element types are checked at runtime during operations.

## Function Types

Two function-related types exist:

```dart
class FunctionType extends Type {
  const FunctionType();

  @override
  String toString() => 'Function';
}

class FunctionCallType extends Type {
  const FunctionCallType();

  @override
  String toString() => 'FunctionCall';
}
```

- **FunctionType**: Represents callable values (user-defined functions, native functions, lambdas).
- **FunctionCallType**: Represents a function call expression (a `CallTerm` in the runtime).

`FunctionType` is a simple marker type. It does not encode parameter types or return types. Type checking for function arguments happens at runtime during function application.

## AnyType (Wildcard)

`AnyType` is a wildcard type that accepts any actual type:

```dart
class AnyType extends Type {
  const AnyType();

  @override
  bool accepts(Type actualType) => true;

  @override
  String toString() => 'Any';
}
```

Use cases:

- **Higher-order function parameters**: Functions like `if` accept values of any type for their branches.
- **Polymorphic operations**: Operations that work uniformly across all types.
- **Untyped contexts**: Lambda parameters and let bindings use `AnyType` since their types are not declared.

## Type Classes

Type classes group multiple types that share a common behavior. They extend `TypeClass`:

```dart
abstract class TypeClass extends Type {
  const TypeClass();

  List<Type> get memberTypes;

  @override
  bool accepts(Type actualType) =>
      memberTypes.any((Type type) => type == actualType);
}
```

The `accepts()` method returns `true` if the actual type equals any member type.

### Available Type Classes

| Type Class         | Member Types                                            | Purpose                                  |
| ------------------ | ------------------------------------------------------- | ---------------------------------------- |
| `OrderedType`      | `Number`, `String`, `Timestamp`, `Duration`             | Types supporting comparison              |
| `EquatableType`    | All primitives and collections except `Function`        | Types supporting equality                |
| `HashableType`     | `Number`, `String`, `Boolean`, `Timestamp`, `Duration`  | Types usable as map keys or set elements |
| `IndexableType`    | `String`, `List`, `Map`                                 | Types supporting index access            |
| `CollectionType`   | `List`, `Set`, `Stack`, `Queue`, `Map`                  | Container types                          |
| `IterableType`     | `String`, `List`, `Set`, `Stack`, `Queue`               | Types supporting iteration               |
| `AddableType`      | `Number`, `String`, `Vector`, `List`, `Set`, `Duration` | Types supporting `+` operator            |
| `SubtractableType` | `Number`, `Vector`, `Set`, `Duration`                   | Types supporting `-` operator            |

Example definition:

```dart
class OrderedType extends TypeClass {
  const OrderedType();

  @override
  List<Type> get memberTypes => const [
    NumberType(),
    StringType(),
    TimestampType(),
    DurationType(),
  ];

  @override
  String toString() => 'Ordered';
}
```

## Type Equality and Matching

Type comparison follows these rules:

1. **Exact equality**: Two types are equal if they have the same `runtimeType`.
2. **accepts() for specifications**: When checking if an argument matches a parameter type, use `parameterType.accepts(argumentType)`.
3. **Type class membership**: `TypeClass.accepts()` checks if the argument type is in `memberTypes`.
4. **AnyType wildcard**: `AnyType().accepts(anyType)` always returns `true`.

Example type matching:

```dart
const NumberType().accepts(const NumberType());     // true
const NumberType().accepts(const StringType());     // false
const AnyType().accepts(const NumberType());        // true
const OrderedType().accepts(const NumberType());    // true
const OrderedType().accepts(const BooleanType());   // false
```

## Parameter Type Declarations

The `Parameter` class in `lib/compiler/models/parameter.dart` provides factory constructors for declaring typed parameters:

```dart
const Parameter.number('value')    // NumberType
const Parameter.string('text')     // StringType
const Parameter.list('items')      // ListType
const Parameter.function('mapper') // FunctionType
const Parameter.any('value')       // AnyType
const Parameter.ordered('a')       // OrderedType (type class)
const Parameter.hashable('key')    // HashableType (type class)
```

These constructors are used in native function definitions to declare expected argument types.

## Relationship to Runtime Terms

Each `Type` has a corresponding `Term` subclass in `lib/compiler/runtime/term.dart`:

| Type               | Term                                   |
| ------------------ | -------------------------------------- |
| `BooleanType`      | `BooleanTerm`                          |
| `NumberType`       | `NumberTerm`                           |
| `StringType`       | `StringTerm`                           |
| `FileType`         | `FileTerm`                             |
| `DirectoryType`    | `DirectoryTerm`                        |
| `TimestampType`    | `TimestampTerm`                        |
| `DurationType`     | `DurationTerm`                         |
| `ListType`         | `ListTerm`                             |
| `VectorType`       | `VectorTerm`                           |
| `SetType`          | `SetTerm`                              |
| `StackType`        | `StackTerm`                            |
| `QueueType`        | `QueueTerm`                            |
| `MapType`          | `MapTerm`                              |
| `FunctionType`     | `FunctionTerm` (and subclasses)        |
| `FunctionCallType` | `CallTerm`                             |
| `AnyType`          | Any term (used for untyped references) |

Each term class implements `Type get type` returning its corresponding type instance:

```dart
class NumberTerm extends ValueTerm<num> {
  const NumberTerm(super.value);

  @override
  Type get type => const NumberType();
}
```

This enables runtime type checking by inspecting `term.type` during evaluation.
