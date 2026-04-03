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

## 3. Where Clauses

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** High

Allow local definitions after the main expression:

```
circleArea(r) = pi * r * r where
  pi = 3.14159

quadratic(a, b, c) = [root1, root2] where
  discriminant = b * b - 4 * a * c
  root1 = (-b + num.sqrt(discriminant)) / (2 * a)
  root2 = (-b - num.sqrt(discriminant)) / (2 * a)
```

**Why it belongs:** Primal currently puts every helper in the global namespace. `where` gives structure without requiring a full module system or imperative block syntax.

**Design notes:**

- `where` should introduce a lexical scope visible only to the owning function body.
- It should support both local values and local helper functions.
- This is a strong fit for the current expression-oriented design.
- It is also a good foundation for later features like guards and local recursion.

---

## 4. Guards in Function Definitions

**Current Fit:** High | **Complexity:** Medium | **Impact:** High

Allow multiple conditional bodies for one function:

```
abs(n)
  | n >= 0 = n
  | else   = -n

grade(score)
  | score >= 90 = "A"
  | score >= 80 = "B"
  | score >= 70 = "C"
  | score >= 60 = "D"
  | else        = "F"
```

**Why it belongs:** This is a cleaner alternative to long nested `if` chains and matches the functional flavor Primal already aims for.

**Design notes:**

- Guards can compile down to nested `if` calls, so the runtime impact is small.
- `| else = ...` should be optional but strongly recommended for clarity.
- This feature pairs especially well with `where`, because guarded definitions often need local helper values.
- It is a good example of a high-value syntax feature that does not force a new runtime model.

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

## 7. Symbols / Atoms

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** Medium

Add lightweight identifier-like literals:

```
status = :pending
next = if (status == :pending) :running else :done

config = { :host: "localhost", :port: 8080 }
```

**Why it belongs:** Atoms are often clearer than free-form strings for status values, tags, and well-known keys.

**Design notes:**

- They should compare by identity/value without the cost or ambiguity of regular strings.
- They are especially useful as map keys and tagged union constructors.
- A simple implementation could intern atom values globally.
- This feature becomes more powerful if Primal later adds `Option`, `Result`, records, or pattern matching.

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

## 9. Binary, Hex, and Octal Number Literals

**Current Fit:** High | **Complexity:** Low | **Impact:** Medium

Add alternate numeric literal forms:

```
binary = 0b1010
hex = 0xFF
octal = 0o77
```

**Why it belongs:** These literals are standard in modern languages and are particularly useful for teaching number systems, bitwise operations, colors, and file permissions.

**Design notes:**

- This is mostly a lexer enhancement.
- It should preserve support for underscore separators, such as `0xFF_FF`.
- Runtime behavior remains unchanged because all of these still become `Number`.
- This is one of the lowest-risk additions in the whole document.

---

## 10. Default Parameter Values

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** High

Allow omitted arguments to fall back to defaults:

```
greet(name, greeting = "Hello") = greeting + ", " + name

main = greet("Alice")
alt = greet("Alice", "Hi")
```

**Why it belongs:** This makes APIs easier to use without needing multiple versions of the same function.

**Design notes:**

- Defaults should probably be evaluated at call time, not compile time.
- Evaluation should happen in parameter order, so later defaults can reference earlier parameters if allowed.
- This fits especially well if Primal later adds named arguments.
- It requires semantic validation around which parameters are optional and how many positional arguments are legal.

---

## 11. Named Arguments

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** Medium

Allow passing arguments by parameter name:

```
createUser(name, age, active) =
  { "name": name, "age": age, "active": active }

user = createUser(age: 30, name: "Bob", active: true)
```

**Why it belongs:** Named arguments improve readability at call sites and make it safer to extend APIs over time.

**Design notes:**

- Positional calls should remain valid for simple cases.
- Named arguments become much more useful when combined with default values.
- This requires semantic validation for unknown, duplicate, or missing names.
- Native library functions could expose their existing parameter names as part of this feature.

---

## 12. Memoization

**Current Fit:** Medium | **Complexity:** Medium-High | **Impact:** Medium

Allow explicit caching of pure function results:

```
memo fib(n) =
  if (n <= 1) n else fib(n - 1) + fib(n - 2)

main = fib(50)
```

**Why it belongs:** Primal encourages recursion and immutable data, which makes opt-in memoization unusually effective for educational examples and dynamic programming problems.

**Design notes:**

- Explicit opt-in is important because not every function is pure: `time.now`, file I/O, console I/O, and environment access must not be memoized accidentally.
- The cache key should be based on evaluated argument values.
- A size limit or eviction strategy may be worth supporting later, but not in a first version.
- This can be implemented either as syntax sugar or as a wrapper around existing function definitions.

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

## 14. Lazy Sequences / Generators

**Current Fit:** Medium-Low | **Complexity:** High | **Impact:** Medium

Add a first-class lazy sequence type:

```
naturals = seq.iterate(0, num.inc)
first10 = seq.take(naturals, 10)
main = seq.toList(first10)
```

**Why it belongs:** The language description already emphasizes lazy evaluation, but most user-visible collection behavior today is eager. A dedicated lazy sequence type would make that design goal concrete.

**Design notes:**

- A sequence should be distinct from a list.
- The standard library would likely need `seq.map`, `seq.filter`, `seq.take`, `seq.drop`, `seq.fold`, and `seq.toList`.
- This is especially attractive for infinite streams and large pipelines.
- It is a meaningful runtime addition, not just parser work.

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

## 16. Boolean Alias and Fallback Operators

**Current Fit:** High for aliases, Medium for fallback | **Complexity:** Low-Medium | **Impact:** Medium

Add more familiar boolean spellings and a dedicated fallback operator:

```
result = x != 0 && 10 / x > 2
name = userName ?? "anonymous"
```

**Why it belongs:** Primal already short-circuits boolean `&` and `|`, so the real value here is familiarity and the opportunity to introduce an explicit fallback operator.

**Design notes:**

- `&&` and `||` could simply be parser aliases for existing short-circuit boolean behavior.
- `??` needs a precise meaning: fallback on `none`, fallback on error, or fallback on explicit empty/missing values. It should not silently adopt JavaScript-style truthiness.
- If `Option` is added, `??` becomes much easier to define cleanly.
- The document should treat this as an ergonomics feature, not as a fix for current boolean short-circuit semantics.

---

## 17. Assert / Contract Expressions

**Current Fit:** Medium | **Complexity:** Medium | **Impact:** Medium

Add explicit assertions and preconditions:

```
safeSqrt(n) =
  assert(n >= 0, "sqrt requires non-negative input", num.sqrt(n))

divide(a, b)
  requires b != 0
  = a / b
```

**Why it belongs:** This would make invariants visible in the source instead of relying on comments or late runtime failures.

**Design notes:**

- Expression-form `assert` is easier to integrate with the current language than statement-based assertions.
- `requires` syntax is attractive, but it is a larger parser change than a plain function.
- Assertions could remain enabled in all builds, or optionally be removable in a future optimized mode.
- This pairs well with improved error reporting.

---

## 18. User-Defined Infix Operators

**Current Fit:** Low | **Complexity:** High | **Impact:** Low-Medium

Allow users to define custom infix operators:

```
(a <+> b) = list.concat(a, b)
combined = [1, 2] <+> [3, 4]
```

**Why it belongs:** It opens the door to domain-specific syntax, especially for pipelines, parsing, math, and collection composition.

**Design notes:**

- Precedence and associativity rules are the hard part.
- A constrained version could require operators to come from a small allowed symbol set.
- This is powerful, but it is one of the easiest proposals to overdo in a minimalist language.
- If adopted, it should probably come late.

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

## 20. Doc Comments

**Current Fit:** High | **Complexity:** Low-Medium | **Impact:** Medium

Attach structured comments to function definitions:

```primal
/// Calculates factorial of n.
/// @param n A non-negative integer
/// @returns n!
/// @example factorial(5) // returns 120
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)
```

**Why it belongs:** Primal already has strong documentation in `docs/`. Doc comments would let source files carry that same clarity and enable REPL help, documentation generation, and editor support.

**Design notes:**

- Triple-slash comments should attach to the next function definition.
- This has no runtime cost if treated as metadata.
- A first version only needs to preserve the raw text.
- Later tooling can parse tags like `@param`, `@returns`, and `@example`.

---

## 21. Tail Call Optimization

**Current Fit:** Medium-Low | **Complexity:** High | **Impact:** High

Optimize tail-recursive functions to avoid stack overflow:

```
factorial(n) = factorialHelper(n, 1) where
  factorialHelper(n, acc) =
    if (n <= 1) acc else factorialHelper(n - 1, n * acc)
```

**Why it belongs:** Primal explicitly relies on recursion instead of loops. Without tail-call optimization, a large class of idiomatic programs remains fragile.

**Design notes:**

- Self-tail recursion is the best first target.
- Mutual tail recursion could come later if needed.
- This likely requires runtime changes, such as a trampoline or loop-based evaluation path.
- This is one of the highest-impact runtime improvements available.

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

## 23. Bitwise Operators

**Current Fit:** High as library, Medium as syntax | **Complexity:** Low-Medium | **Impact:** Medium

Add bitwise operations and shifts:

```
a = bit.and(5, 3)
b = bit.or(5, 3)
c = bit.xor(5, 3)
d = bit.not(5)
e = bit.shiftLeft(5, 2)
f = bit.shiftRight(20, 2)
```

**Why it belongs:** Bitwise operations are standard tools for flags, masks, low-level data handling, and teaching numeric representations.

**Design notes:**

- A library-first design is safer than adding syntax immediately.
- Functions are probably enough for a first version.
- If syntax is later added, it should reuse the same semantics.
- This is a good example of a feature that can start in the standard library before it needs parser support.

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
