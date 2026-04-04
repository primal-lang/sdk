Available types:

- `Boolean`
- `Number`
- `Integer` -> `Number`
- `Decimal` -> `Number`
- `String`
- `List<T>`
- `Map<String, T>`
- `Function<Number, String, Boolean>`: (a: Number, b: String): Boolean

Missing types: Vector, Set, etc.

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
