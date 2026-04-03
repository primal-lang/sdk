## 1. Function Composition Operator

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** Medium

Compose functions with `>>` (left-to-right) or `<<` (right-to-left):

```
double(x) = x * 2
square(x) = x * x

doubleSquare = double >> square
main = doubleSquare(3)   // returns 36
```

**Why it belongs:** Primal already treats functions as first-class values. Composition makes function pipelines concise without adding mutable intermediate names.

**Design notes:**

- `f >> g` should mean `x => g(f(x))`.
- A minimal first version can restrict composition to unary functions.
- A later version could allow composing partially applied functions as well.
- Parser work is moderate; runtime work is mostly about constructing a new callable value.

---

## 2. Partial Application

**Current Fit:** Medium-Low | **Complexity:** High | **Impact:** High

Apply some arguments now, get a function that expects the rest:

```
add(a, b) = a + b

addFive = add(5, _)
main = addFive(3)   // returns 8
```

**Why it belongs:** The standard library already has higher-order functions such as `list.map`, `list.filter`, and `list.reduce`. Partial application would make them much easier to use with existing multi-argument functions.

**Design notes:**

- Placeholder-based partial application is probably the best fit for Primal's existing syntax.
- It should work for both user-defined and native functions.
- This is one of the first proposals that truly needs closure-like behavior or an equivalent runtime representation.
- If closures are considered too large a step, this can be deferred until local scopes/functions exist.

---

## 5. List Comprehensions

**Current Fit:** Medium-Low | **Complexity:** High | **Impact:** High

Declarative list construction:

```
squares = [x * x | x <- [1, 2, 3, 4, 5]]
evens = [x | x <- [1, 2, 3, 4, 5, 6], num.isEven(x)]
pairs = [[x, y] | x <- [1, 2], y <- ["a", "b"]]
```

**Why it belongs:** Comprehensions make mapping, filtering, and nested iteration much easier to read than explicit combinations of library calls.

**Design notes:**

- A single-generator comprehension is straightforward.
- Multiple generators imply cartesian-product semantics.
- Filters after generators are more readable than nesting `if`.
- This would likely lower to combinations of `list.map`, `list.filter`, concatenation, and helper lambdas/locals, which means it becomes much easier once local bindings or anonymous functions exist.

---

## 6. Tuples

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** Medium

Add fixed-size heterogeneous collections:

```
point = (3, 4)
person = ("Alice", 30, true)

x = tuple.first(point)
name = tuple.at(person, 0)
```

**Why it belongs:** Lists are currently used for many things, but they do not communicate "fixed-size structured value". Tuples would be a lightweight way to return multiple values and model small product data.

**Design notes:**

- Tuples should be distinct from lists in printing, equality, and type checks.
- They should support indexing and equality out of the box.
- If records are added later, tuples remain useful for positional data.
- This is a runtime/data-model addition, not just syntax sugar.

---

## 8. Regular Expression Literals

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** Medium

Add first-class regex syntax:

```
pattern = /[a-z]+[0-9]+/
matched = regex.match("hello123", pattern)
groups = regex.findAll("abc123def456", /\d+/)
replaced = regex.replace("hello123", /\d+/, "XXX")
```

**Why it belongs:** Primal already exposes `str.match`, but string-based regex patterns are harder to read and easier to mistype.

**Design notes:**

- Literal regexes should be validated during lexing/parsing, not only at runtime.
- A dedicated regex runtime value would be cleaner than treating regexes as plain strings.
- This proposal implies a new `regex.*` namespace in the standard library.
- Raw strings and regex literals complement each other well.

---

## 13. Sequence / Do Expressions

**Current Fit:** Medium-Low | **Complexity:** High | **Impact:** High

Allow evaluating expressions in order and returning the last one:

```
main = do
  console.writeLn("Enter name:")
  name = console.read()
  console.writeLn("Hello, " + name)
  name
end
```

**Why it belongs:** Primal is expression-oriented, but practical scripting still needs a readable way to sequence I/O and local bindings.

**Design notes:**

- `do ... end` is most useful if it also supports local bindings.
- The block should evaluate top-to-bottom and yield the last expression.
- This overlaps with `where` and any future `let`-like feature; those designs should be coordinated rather than implemented independently.
- This is a larger change than it looks because it introduces nested scope and ordered evaluation as explicit syntax.

---

## 15. Record Types

**Current Fit:** Medium-Low | **Complexity:** High | **Impact:** High

Add named-field structures:

```
record Person(name, age)

alice = Person("Alice", 30)
name = alice.name
older = alice with { age: 31 }
```

**Why it belongs:** Maps are flexible but weakly communicative. Records would give Primal a lightweight way to model structured data with named fields.

**Design notes:**

- A dynamic first version does not need field type annotations.
- Field access and functional update are the key capabilities.
- A simple implementation could lower records to tagged maps at first.
- This interacts with the lexer/parser because dot access is not currently a general expression form.

---

## 19. Multiline / Raw Strings

**Current Fit:** High | **Complexity:** Low | **Impact:** High

Add triple-quoted multiline strings and raw strings:

```
query = """
  SELECT * FROM users
  WHERE age > 18
"""

path = r"C:\Users\name"
pattern = r"\d+\.\d+"
```

**Why it belongs:** Primal already has solid string escape handling. Extending the lexer to support raw and multiline forms would provide immediate value for scripts, regexes, JSON snippets, and embedded text.

**Design notes:**

- Indentation trimming rules should be explicit.
- Raw strings should disable escape processing entirely.
- Triple-quoted strings should preserve line breaks naturally.
- This is a very good near-term feature because the value is high and the scope is contained.

---

## 22. Maybe / Option Type

**Current Fit:** Medium | **Complexity:** Medium-High | **Impact:** High

Add explicit values for present or absent results:

```
safeHead(xs) =
  if (list.isEmpty(xs)) none else some(list.first(xs))

value = maybe.unwrapOr(safeHead([]), 0)
```

**Why it belongs:** The language currently uses exceptions for many missing-value cases, such as indexing failures. `Option` would provide a safer, more explicit path for ordinary absence.

**Design notes:**

- A minimal representation could be atoms/tags plus payload, but a dedicated runtime type is cleaner.
- The standard library would need helpers such as `maybe.map`, `maybe.flatMap`, `maybe.unwrapOr`, and `maybe.isSome`.
- This becomes especially valuable if safe indexing/lookups are added.
- It also reduces overuse of `try(a, b)` for non-exceptional control flow.

---

## 24. Type Aliases

**Current Fit:** Low in current dynamic model | **Complexity:** Medium | **Impact:** Low-Medium

Add named aliases for documentation and tooling:

```
type Point = Tuple
type UserId = Number
type Person = Record
```

**Why it belongs:** Even in a dynamic language, names for common shapes and conventions can improve documentation and REPL output.

**Design notes:**

- In Primal's current dynamic model, aliases would initially be descriptive rather than enforced.
- This proposal becomes much stronger if static types or type inference are ever added.
- Because of that, this is better treated as a long-term language/tooling feature than a near-term parser priority.
- If adopted early, it should be framed honestly as documentation metadata.

---

## 25. Module-Level Constants

**Current Fit:** High | **Complexity:** Low-Medium | **Impact:** Medium

Add explicit constant declarations:

```
const PI = 3.14159265359
const APP_NAME = "Primal"
```

**Why it belongs:** Nullary functions already act like constants in practice, but explicit constant syntax communicates intent and could enable eager validation or precomputation.

**Design notes:**

- This should not duplicate existing nullary function semantics without adding value.
- The main benefit is intent, discoverability, and tooling.
- A conservative implementation could lower `const` to the existing zero-argument function model.
- A more ambitious version could evaluate compile-time-safe constants eagerly.

---

## 26. Unicode Identifiers

**Current Fit:** High | **Complexity:** Low-Medium | **Impact:** Medium

Allow identifiers beyond ASCII:

```
cafe = "ASCII"
café = "Unicode"
Δx(x1, x2) = x2 - x1
```

**Why it belongs:** The source reader already tracks grapheme clusters correctly, but identifier recognition is still ASCII-only. Supporting Unicode names would make the language more internationally friendly and better aligned with the existing reader design.

**Design notes:**

- Identifier rules must be explicit about what counts as a valid start and continuation character.
- Normalization should be considered so visually similar names behave predictably.
- It may be wise to warn about confusable identifiers even if they are legal.
- This is a relatively contained lexer enhancement with meaningful ergonomic upside.

---

## 27. Result Type

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** High

Add explicit success/error values:

```
safePort(text) =
  if (str.match(text, "^[0-9]+$"))
    ok(to.integer(text))
  else
    err("invalid port")

port = result.unwrapOr(safePort("abc"), 8080)
```

**Why it belongs:** `try(a, b)` is useful, but it catches failures by evaluating one branch and falling back to another. `Result` would let code represent success and failure as ordinary values.

**Design notes:**

- This is different from `Option`: it preserves error information.
- It is especially useful for safe versions of parsing, JSON decoding, file reads, and directory operations.
- The standard library would likely expose `result.map`, `result.mapError`, `result.unwrapOr`, and `result.isOk`.
- This feature would make error handling more explicit without requiring exceptions everywhere.

---

## 28. Variadic Parameters

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** Medium

Allow functions to accept a variable number of arguments:

```
join(sep, parts...) = list.join(parts, sep)
sum(nums...) = list.reduce(nums, 0, num.add)
```

**Why it belongs:** Variadics are a natural fit for formatting helpers, list builders, and aggregation utilities.

**Design notes:**

- The trailing variadic parameter should become a list at runtime.
- Only the final parameter should be variadic.
- This is easier to add than full spread syntax because it only changes declarations and call validation.
- It also works well with arity-based overloading and default parameters.

---

## 29. Overloading by Arity

**Current Fit:** High | **Complexity:** Medium | **Impact:** High

Allow multiple functions with the same name when parameter counts differ:

```
range(end) = range(0, end)
range(start, end) = ...
range(start, end, step) = ...
```

**Why it belongs:** The current semantic analyzer rejects duplicate names entirely. Overloading by arity only would keep dispatch simple while making APIs more expressive.

**Design notes:**

- This should be limited to argument count, not types.
- The compiler can resolve most calls statically.
- This is safer and simpler than full type-based overloading.
- It combines well with optional defaults, but the two features should be designed together to avoid ambiguous calls.

---

## 30. Safe Indexing and Lookup

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** High

Allow collection access that does not throw on missing elements:

```
first = xs?[0]
port = config?["port"]
letter = name?[2]
```

**Why it belongs:** Today, indexing and lookup errors are handled through exceptions. A safe form would make ordinary missing-value handling cleaner and more explicit.

**Design notes:**

- The cleanest return type is `Option`.
- If `Option` is not added, the language would need some other explicit "missing" value, which is riskier.
- This should apply consistently to lists, strings, and maps.
- Safe access is one of the most practical follow-ups to `Option`.

---

## 31. Compile-Time Constant Evaluation

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** Medium-High

Precompute obviously pure constant expressions:

```
const SECONDS_PER_DAY = 24 * 60 * 60
const UNIT_X = vector.normalize(vector.new([1, 0, 0]))
```

**Why it belongs:** Primal already treats many top-level expressions as immutable values. Constant evaluation would reduce repeated work and strengthen the value of explicit constants.

**Design notes:**

- It must be conservative: `time.now`, `console.read`, file I/O, environment access, random functions, and similar operations are not safe to fold.
- A whitelist of pure built-ins is safer than trying to infer purity from all functions immediately.
- This could be implemented in semantic analysis or as a later optimization pass.
- Even a small first version would be useful for numeric, string, list, and vector literals built from pure operations.
