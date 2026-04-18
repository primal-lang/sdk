---
title: Typing
tags: [roadmap, types]
sources: []
---

# Typing

**TLDR**: A static type system with type aliases (`type NumberList = List<Number>`), generic types, type classes inspired by Haskell (`Eq`, `Ord`, `Show`), data declarations for structured records, and optional type inference with explicit annotations for functions.

Available types:

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

- `Function<Number, String, Boolean>`: (a: Number, b: String): Boolean
- `Integer` -> `Number`?
- `Decimal` -> `Number`?

Haskell uses Type Classes

| Type Class    | Purpose                                   | Key Methods                     |
| :------------ | :---------------------------------------- | :------------------------------ |
| **`Eq`**      | Equality testing                          | `(==)`, `(/=)`                  |
| **`Ord`**     | Total ordering (comparison)               | `compare`, `(<)`, `(<=)`, `max` |
| **`Show`**    | String conversion (for debugging)         | `show`                          |
| **`Read`**    | String parsing                            | `read`, `readMaybe`             |
| **`Enum`**    | Sequential types (things you can "count") | `succ`, `pred`, `[1..10]`       |
| **`Bounded`** | Types with a min and max limit            | `minBound`, `maxBound`          |

---

```primal
type NumberList = List<Number>
type Stack<T> = List<T>
```

```primal
enum Weekday = (Monday, Tuesday, Wednesday, Thrusday, Friday, Saturday, Sunday)
enum.values(e: Enum): List
```

```primal
data Person = (name: String, age: Integer, married: Boolean)

// new
Person("John Smith", 42, true)

// get
data.get(person, "name"): T

// set
data.set(person, "age", 50): Person

// keys
data.keys(a: Data): List

// values
data.values(a: Data): List
```

```primal
func foo(a: Number, b: String, c: Boolean): NumberList
func sumList<T>(list: List<T>): Number
```

# Type inference

To make the inference easier, split the overloaded operators such as `+`, into specifics:

- `++`: to concatenate strings
- `::`: to concatenate lists

```primal
foo(n) /* : Number */ = mul(n, 2) // n : Number
```
