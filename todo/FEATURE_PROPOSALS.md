## Table of Contents

5. [Language Primitives](#language-primitives)
   - [Symbols / Atoms](#31-symbols--atoms)
   - [Quotation / Quasi-quotation](#32-quotation--quasi-quotation)
   - [Multi-methods](#33-multi-methods)
   - [Debug / Trace Expressions](#34-debug--trace-expressions)
   - [First-Class Environments](#35-first-class-environments)
   - [Keyword Arguments as Values](#36-keyword-arguments-as-values)
   - [Namespace Blocks](#46-namespace-blocks)
   - [Function Introspection](#47-function-introspection)

6. [Testing & Verification](#testing--verification)
   - [Property-Based Testing](#37-property-based-testing)
   - [Soft Invariants / Contracts](#38-soft-invariants--contracts)
   - [Snapshot Testing](#39-snapshot-testing)
   - [Doctests / Executable Examples](#48-doctests--executable-examples)

7. [Syntax Sugar & Ergonomics](#syntax-sugar--ergonomics)
   - [Case Expressions](#40-case-expressions)
   - [When Expressions](#41-when-expressions)
   - [With Expressions](#42-with-expressions)
   - [Placeholder Arguments](#43-placeholder-arguments)
   - [Method Chaining Syntax](#44-method-chaining-syntax)
   - [From-End Indexing](#49-from-end-indexing)
   - [Native Set / Vector Literal Syntax](#50-native-set--vector-literal-syntax)

---

### 31. Symbols / Atoms

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
Interned symbolic values used for tags, map keys, and lightweight enum-like constants. They are cheaper and clearer than raw strings for identifiers that are meant to be stable program values rather than user-facing text.

Because `:` already separates key/value pairs in Primal map literals, the most implementation-friendly literal form is a dedicated sigil such as `#ok` rather than `:ok`.

**Proposed Syntax:**

```primal
// Symbol literals
status = #ok
error = #error
direction = #north

// Equality
#ok == #ok                                // true
#ok == #error                             // false

// As map keys
response = {
  #status: 200,
  #body: "Hello",
  #headers: {#contentType: "text/plain"}
}
response[#status]                         // 200

// As tags in tagged data
result1 = [#ok, 42]
result2 = [#error, "not found"]

describe(result) = case result of
  | [#ok, value] -> "Success: " + to.string(value)
  | [#error, msg] -> "Error: " + msg
  | _ -> "unknown"

// Symbol functions
symbol.name(#hello)                       // "hello"
symbol.fromString("hello")                // #hello
is.symbol(#ok)                            // true
is.symbol("ok")                           // false
```

**Use Cases:**

- Tagged union payloads
- Stable map keys
- Lightweight protocol messages
- Enum-like state values
- Interop with future keyword-argument or pattern-matching features

**Implementation Notes:**

- Add `SymbolNode` and `SymbolType`, or a dedicated interned representation distinct from `StringNode`.
- The lexer only needs a small extension for `#identifier`.
- Symbols should print without quotes so they remain visually distinct from strings in the REPL.
- Interning makes equality cheap and deterministic, but Primal should still define symbol equality as value equality, not exposed pointer identity.
- This proposal composes especially well with `case` expressions and future `Result`/`Option`-style tagged values.

---

### 32. Quotation / Quasi-quotation

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **High**   |
| Impact     | **Medium** |

**Description:**
Code as data - the ability to quote expressions and splice values into quoted code. Foundation for metaprogramming.

**Proposed Syntax:**

```primal
// Quote: treat code as data (unevaluated AST)
expr1 = '(1 + 2)                          // quoted expression
expr2 = '(x * x)                          // quoted with free variable

// Quote returns AST node
// '(1 + 2) = Call('+', [Lit(1), Lit(2)])

// Eval: evaluate quoted expression
eval('(1 + 2))                            // 3

// Quasi-quote: quote with holes for splicing
x = 5
expr3 = `(1 + ~x)                         // splice x into quote
// Result: '(1 + 5)

y = '(a + b)
expr4 = `(~y * 2)                         // splice quoted expression
// Result: '((a + b) * 2)

// Splice list of expressions
args = ['(1), '(2), '(3)]
expr5 = `(f(~@args))                      // splice list
// Result: '(f(1, 2, 3))

// AST manipulation
quote.isCall(expr1)                       // true
quote.isLiteral('(42))                    // true
quote.callee('(f(x)))                     // '(f)
quote.args('(f(x, y)))                    // ['(x), '(y)]

// Build AST programmatically
quote.call('+', [quote.lit(1), quote.lit(2)])
// Same as '(1 + 2)

// Pattern matching on AST
transform(expr) = match expr with
  | '(~a + 0) -> a                        // x + 0 = x
  | '(0 + ~a) -> a                        // 0 + x = x
  | '(~a * 1) -> a                        // x * 1 = x
  | '(1 * ~a) -> a                        // 1 * x = x
  | other -> other

// Hygienic macros (if supported)
@macro unless(cond, body) = `(if (~cond) () else ~body)

unless(isEmpty(list), process(list))
// Expands to: if (isEmpty(list)) () else process(list)
```

**Use Cases:**

- Code generation
- DSL implementation
- Optimization passes
- Symbolic computation
- Compile-time metaprogramming

**Implementation Notes:**

- Quote returns AST representation
- Hygiene for macro system
- Clear evaluation semantics

---

### 33. Multi-methods

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **Medium** |
| Impact     | **Medium** |

**Description:**
Functions that dispatch based on the runtime types of multiple arguments, not just one (like traditional OOP).

**Proposed Syntax:**

```primal
// Declare multi-method
multimethod collide(a, b)

// Define implementations for specific type combinations
method collide(a: Asteroid, b: Asteroid) =
  "asteroids bounce"

method collide(a: Asteroid, b: Spaceship) =
  "spaceship destroyed"

method collide(a: Spaceship, b: Asteroid) =
  collide(b, a)                           // delegate to above

method collide(a: Spaceship, b: Spaceship) =
  "both ships damaged"

// Dispatch is symmetric - order doesn't matter for lookup
collide(asteroid1, ship1)                 // "spaceship destroyed"
collide(ship1, asteroid1)                 // "spaceship destroyed"

// Default method
method collide(a, b) =
  "default collision behavior"

// Multi-method on more than 2 args
multimethod render(shape, material, light)

method render(s: Circle, m: Matte, l: PointLight) = ...
method render(s: Circle, m: Glossy, l: PointLight) = ...
method render(s: Square, m: Matte, l: Ambient) = ...

// Hierarchical dispatch (if type hierarchy exists)
type Shape
type Circle extends Shape
type Square extends Shape

method area(s: Shape) = "unknown"         // default
method area(s: Circle) = num.pi * s.radius * s.radius
method area(s: Square) = s.side * s.side

// Custom dispatch function
multimethod jsonEncode(value) using typeof

method jsonEncode(value: Number) = to.string(value)
method jsonEncode(value: String) = "\"" + escape(value) + "\""
method jsonEncode(value: Boolean) = if (value) "true" else "false"
method jsonEncode(value: List) = "[" + str.join(list.map(value, jsonEncode), ",") + "]"
method jsonEncode(value: Map) = "{" + ... + "}"
```

**Use Cases:**

- Game collision systems
- Serialization
- Visitor pattern replacement
- Graphics rendering
- Binary operations on mixed types

**Implementation Notes:**

- Dispatch table indexed by type tuple
- Caching for performance
- Clear precedence rules

---

### 34. Debug / Trace Expressions

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
Expression-returning debug helpers that print or validate values without changing program behavior. This is a particularly good fit for Primal because everything is an expression and the CLI already has a `--debug` mode.

**Proposed Syntax:**

```primal
x = debug.trace(expensiveComputation())
y = debug.trace("after filter", list.filter(data, isValid))

safeHead(xs) =
  debug.assert(
    list.isNotEmpty(xs),
    list.first(xs),
    "expected a non-empty list"
  )

measured = debug.timed("loadUsers", loadUsers())
debug.type(measured)                      // "List", "Number", "Function", ...

traceStep(x) = debug.trace("step", x)
result = list.map([1, 2, 3], traceStep)

debug.traceWhen(isVerbose, "payload", payload)
```

**Use Cases:**

- Debugging during development
- Performance profiling
- Understanding recursion
- Validating assumptions

**Implementation Notes:**

- The MVP should be library functions rather than decorators, breakpoints, or statement-like forms.
- `debug.trace` must evaluate its value exactly once and return it unchanged.
- `debug.assert` should throw a regular runtime error so it composes naturally with `try`.
- `debug.timed` can piggyback on the existing CLI debug mode but should also work as a normal runtime function.
- Rich call-stack tracing can come later once the runtime carries more source-location metadata through evaluation.

---

### 35. First-Class Environments

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **Medium** |
| Impact     | **Low**    |

**Description:**
Ability to capture, manipulate, and evaluate code within explicit environments/scopes.

**Proposed Syntax:**

```primal
// Capture current environment
env1 = environment.current()

// Create empty environment
env2 = environment.empty()

// Create environment with bindings
env3 = environment.fromMap({
  "x": 10,
  "y": 20,
  "add": (a, b) -> a + b
})

// Extend environment
env4 = environment.extend(env3, "z", 30)

// Look up in environment
environment.lookup(env3, "x")             // some(10)
environment.lookup(env3, "w")             // nothing

// Evaluate expression in environment
environment.eval(env3, '(x + y))          // 30
environment.eval(env4, '(add(x, z)))      // 40

// Get all bindings
environment.bindings(env3)                // {"x": 10, "y": 20, "add": <fn>}
environment.names(env3)                   // ["x", "y", "add"]

// Check if binding exists
environment.has(env3, "x")                // true

// Create closure explicitly
makeAdder(env, n) =
  environment.closure(
    environment.extend(env, "n", n),
    '(x) -> x + n)
  )

addFive = makeAdder(environment.empty(), 5)
addFive(10)                               // 15

// Sandbox evaluation
safEval(code) =
  environment.eval(
    environment.sandbox(),                // restricted environment
    code
  )
```

**Use Cases:**

- Implementing REPLs
- Sandboxed evaluation
- Dynamic scoping
- Testing with mock environments

**Implementation Notes:**

- Environment = map from names to values
- Closure = (environment, expression)
- Security considerations for eval

---

### 36. Keyword Arguments as Values

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
First-class keyword arguments that can be passed around, merged, and applied to functions.

**Proposed Syntax:**

```primal
// Keyword argument syntax
result = createUser(name: "Alice", age: 30, active: true)

// Keywords as a map-like value
kwargs = {name: "Alice", age: 30}
result = createUser(**kwargs)             // spread keywords

// Merge keywords
defaults = {active: true, role: "user"}
overrides = {name: "Bob", role: "admin"}
merged = kwargs.merge(defaults, overrides)
// {active: true, role: "admin", name: "Bob"}

// Function capturing keywords
configure(**opts) = do {
  name <- opts.name ?? "default"
  port <- opts.port ?? 8080
  {name: name, port: port}
}

// Partial application with keywords
boundFn = createUser.bind(active: true)
boundFn(name: "Alice", age: 30)

// Extract keywords
takeKeywords(required, **rest) = do {
  // required is positional
  // rest contains all keyword args
  ...
}

// Required vs optional keywords
createUser(name:, age:, active: true) = ...  // name, age required; active optional

// Keyword-only (no positional)
configure(*, host:, port:) = ...          // must use keywords
configure(host: "localhost", port: 8080)

// Destructuring keywords
{name:, age:, ...rest} = userKwargs
```

**Use Cases:**

- Readable function calls
- Configuration objects
- Builder patterns
- API design

**Implementation Notes:**

- Keywords as special map type
- Compile-time or runtime checking
- Integration with partial application

---

### 46. Namespace Blocks

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
A lightweight way to group functions under a dotted prefix without introducing a full module or import system. This is especially aligned with Primal because dotted identifiers already exist (`list.map`, `str.uppercase`) and the language currently lives in a single-file global namespace.

**Proposed Syntax:**

```primal
namespace math {
  square(x) = x * x
  cube(x) = x * square(x)
}

math.square(4)                            // 16
math.cube(3)                              // 27

namespace http.headers {
  contentType = "content-type"
  isJson(value) = value == "application/json"
}

http.headers.contentType
http.headers.isJson("application/json")

namespace stats {
  mean(xs) =
    num.div(list.reduce(xs, 0, num.add), list.length(xs))
}
```

**Use Cases:**

- Organizing larger single-file programs
- Grouping domain-specific helpers
- Avoiding accidental global name collisions
- Making user code feel consistent with the standard library

**Implementation Notes:**

- This can be a purely syntactic expansion: `namespace math { square(x) = ... }` becomes `math.square(x) = ...`.
- Unqualified references inside the block can resolve to the same namespace first, then to globals.
- Nested namespace blocks compose naturally because dotted identifiers are already legal names.
- This adds structure without forcing a full module system, so it fits Primal's current single-file philosophy very well.

---

### 47. Function Introspection

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Expose metadata about function values. Primal already has first-class functions, but once a function is passed around there is very little users can ask about it. Introspection would make higher-order code, debugging, and tooling much nicer.

**Proposed Syntax:**

```primal
f = num.add

function.name(f)                          // "num.add"
function.arity(f)                         // 2
function.parameters(f)                    // ["a", "b"]
function.isNative(f)                      // true
function.signature(f)                     // "num.add(a: Number, b: Number)"

greet(name) = "Hello, " + name

function.name(greet)                      // "greet"
function.arity(greet)                     // 1
function.parameters(greet)                // ["name"]
function.isNative(greet)                  // false

list.map([num.add, num.sub, greet], function.name)
```

**Use Cases:**

- REPL tooling
- Debug output
- Higher-order libraries
- Documentation generation
- Better error messages around callables

**Implementation Notes:**

- `FunctionNode` already stores `name` and `parameters`, so most of this proposal is exposing existing runtime metadata.
- `function.signature` can reuse the formatting already present in `FunctionNode.toString()`.
- Later extensions could add documentation text, source location, or namespace data.
- This is a very high-leverage addition for relatively little implementation work.

---

## Testing & Verification

### 37. Property-Based Testing

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
Built-in support for generating random test data and checking properties hold for all inputs.

**Proposed Syntax:**

```primal
// Basic property test
@property
reverseReverse(lst: List<Number>) =
  list.reverse(list.reverse(lst)) == lst

// Property with custom generator
@property
sortedIsSorted(lst: List<Number>) =
  isSorted(list.sort(lst, num.compare))

// Generators
gen.number()                              // any number
gen.number(0, 100)                        // range
gen.string()                              // any string
gen.string(gen.alphaNum(), 1, 20)         // alphanumeric, 1-20 chars
gen.list(gen.number())                    // list of numbers
gen.list(gen.number(), 0, 10)             // 0-10 elements
gen.map(gen.string(), gen.number())
gen.oneOf([1, 2, 3])                      // choose from list
gen.frequency([(3, gen.number()), (1, gen.string())])  // weighted

// Custom generators
personGen = gen.map3(
  gen.string(gen.alpha(), 1, 50),
  gen.number(0, 120),
  gen.bool(),
  (name, age, active) -> {name: name, age: age, active: active}
)

// Conditional generation
evenGen = gen.filter(gen.number(), num.isEven)
nonEmptyGen = gen.filter(gen.list(gen.number()), list.isNotEmpty)

// Sized generation (grows with test size)
gen.sized((size) -> gen.list(gen.number(), 0, size))

// Running properties
prop.check(reverseReverse)
// Output: OK, passed 100 tests

prop.check(reverseReverse, {tests: 1000})
// More iterations

// Shrinking (finds minimal failing case)
@property
buggyProperty(n: Number) = n < 100
// Failing input shrinks: 2847 -> 234 -> 105 -> 100

// Labeling (for coverage statistics)
@property
insertProperty(x: Number, lst: List<Number>) =
  let sorted = list.sort(lst, num.compare)
  let inserted = sortedInsert(x, sorted)
  label(if (list.isEmpty(lst)) "empty" else "non-empty") &
  isSorted(inserted) & list.contains(inserted, x)

// Implication (skip invalid inputs)
@property
divisionProperty(a: Number, b: Number) =
  (b != 0) ==> (a / b * b == a)

// Expecting failure
@property @expectFailure
knownBug(x: Number) = false

// Collecting statistics
@property
distribution(x: Number) =
  collect(if (x > 0) "positive" else "non-positive", true)
```

**Use Cases:**

- Finding edge cases
- Testing algebraic properties
- Fuzz testing
- API contract verification

**Implementation Notes:**

- Integrate with generator monad
- Shrinking for minimal counterexamples
- Reproducible with seeds

---

### 38. Soft Invariants / Contracts

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Declarative pre-conditions, post-conditions, and invariants that can be checked at runtime or documented.

**Proposed Syntax:**

```primal
// Pre-condition
@require(n >= 0)
@require(n < 1000, "n must be reasonable")
factorial(n) = if (n <= 1) 1 else n * factorial(n - 1)

// Post-condition
@ensure(result > 0)
@ensure(result >= n, "result must be at least n")
fibonacci(n) = ...

// Both
@require(b != 0)
@ensure(result * b == a)
divide(a, b) = a / b

// Invariants on data
@invariant(self.balance >= 0)
type Account = {balance: Number, owner: String}

// Contract as expression
contract(
  pre: x > 0,
  post: (result) -> result > x,
  body: x * 2
)

// Soft contracts (warn, don't fail)
@softRequire(lst.length < 1000, "performance warning")
processLarge(lst) = ...

// Contract modes (configurable)
// contract.mode = :enforce (throw on violation)
// contract.mode = :warn (log warning)
// contract.mode = :document (no runtime check)
// contract.mode = :off (completely disabled)

// Dependent contracts
@require(list.length(weights) == list.length(values))
weightedSum(weights, values) = ...

// Higher-order contracts
@require(is.function(f))
@ensure((result) -> is.function(result))
compose(f, g) = (x) -> f(g(x))

// Contract blame (who violated?)
@require(is.string(name), blame: :caller)
greet(name) = "Hello, " + name

// Old values in postcondition
@ensure((result) -> result == old(balance) + amount)
deposit(account, amount) = ...
```

**Use Cases:**

- API documentation
- Runtime validation
- Design by contract
- Debugging

**Implementation Notes:**

- Configurable enforcement level
- Integrate with error messages
- Support for `old` values

---

### 39. Snapshot Testing

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Compare output against previously saved "golden" outputs. Useful for testing complex outputs.

**Proposed Syntax:**

```primal
// Basic snapshot test
@snapshot("render_user")
testRenderUser() = renderUser({name: "Alice", age: 30})

// First run: saves output to __snapshots__/render_user.snap
// Subsequent runs: compares against saved snapshot

// Update snapshots (when intentional changes)
// Run with: primal test --update-snapshots

// Inline snapshots (stored in test file)
@inlineSnapshot
testFormat() = formatData(input)
// Primal updates the test file with actual output

// Named snapshots in one test
testMultiple() = do {
  snapshot("case1", render(data1))
  snapshot("case2", render(data2))
  snapshot("case3", render(data3))
}

// Custom serializer
@snapshot("custom", serializer: jsonPretty)
testCustom() = complexDataStructure()

// Snapshot with matcher (partial matching)
@snapshot("partial", match: :substring)
testPartial() = generateReport()

// Diff on failure
// Shows:
// - Expected (from snapshot)
// + Actual (from test)
// With line-by-line diff

// Snapshot directory structure
// __snapshots__/
//   test_file_name/
//     snapshot_name.snap

// Programmatic snapshot
snapshot.assert("name", value)
snapshot.update("name", value)            // force update
snapshot.read("name")                     // get stored value
```

**Use Cases:**

- UI component testing
- Serialization output
- Report generation
- API response testing

**Implementation Notes:**

- File-based storage
- Clear diff output
- Update workflow

---

### 48. Doctests / Executable Examples

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
Executable examples embedded directly next to code or in markdown docs. This fits Primal especially well because the language is educational, REPL-friendly, and expression-oriented.

**Proposed Syntax:**

```primal
//> square(3) => 9
//> square(0) => 0
square(n) = n * n

//> classify(0) => "zero"
//> classify(5) => "positive"
//> classify(-2) => "negative"
classify(n) =
  if (n == 0) "zero" else if (n > 0) "positive" else "negative"

// Expected error
//> list.first([]) !! Runtime error: Cannot get element from empty list
```

**Use Cases:**

- Tutorial and reference documentation
- Preventing examples from going stale
- Lightweight regression testing
- REPL transcripts that remain correct over time

**Implementation Notes:**

- The runner can reuse the existing compiler and REPL formatting logic.
- `expr => expected` compares formatted results, while `expr !! error` expects a failure message or substring.
- A CLI mode such as `primal doctest file.pri` or `primal doctest docs/**/*.md` would be enough for an MVP.
- This complements property-based and snapshot testing rather than replacing them.

---

## Syntax Sugar & Ergonomics

### 40. Case Expressions

| Property   | Rating   |
| ---------- | -------- |
| Fit        | **High** |
| Complexity | **Low**  |
| Impact     | **High** |

**Description:**
Multi-way conditional expressions that are more readable than deeply nested `if ... else ...` chains. This proposal has a very attractive MVP because the simplest form can desugar directly to nested `if` calls.

**Proposed Syntax:**

```primal
// Condition-only form
grade(score) = case
  | score >= 90 -> "A"
  | score >= 80 -> "B"
  | score >= 70 -> "C"
  | else -> "F"

// Subject form
describe(n) = case n of
  | 0 -> "zero"
  | 1 -> "one"
  | 2 -> "two"
  | _ -> "many"

// Another condition-only example
classify(x, y) = case
  | x == 0 & y == 0 -> "origin"
  | x == 0          -> "y-axis"
  | y == 0          -> "x-axis"
  | x > 0 & y > 0 -> "quadrant I"
  | else          -> "other"

// Future-friendly tagged-data form
parseResult(r) = case r of
  | [#ok, value] -> value
  | [#error, _] -> defaultValue
  | _ -> defaultValue
```

**Use Cases:**

- Replacing nested if-else
- State machines
- Input classification
- Readable conditionals

**Implementation Notes:**

- The condition-only form can desugar directly to nested `if(condition) then else ...`.
- The `case value of` form can start as chained equality tests before full pattern matching exists.
- Default arms should use `_` or `else`; they should be required unless the compiler can prove exhaustiveness.
- Destructuring and real pattern matching should be treated as a second phase, not part of the MVP.

---

### 41. When Expressions

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Conditional expression for when you only care about the true case (like Ruby's unless/when).

**Proposed Syntax:**

```primal
// when: execute if condition true, return nothing otherwise
when(condition, value)

// Usage
result = when(score > 90, "Excellent!")
// If score > 90: "Excellent!"
// Otherwise: nothing (or unit)

// unless: opposite of when
unless(condition, value)
result = unless(list.isEmpty(lst), list.first(lst))

// when with multiple conditions
result = when {
  | score > 90 -> "A"
  | score > 80 -> "B"
}
// Returns first matching, or nothing

// when-let: bind and check
whenLet(maybeValue, (v) -> process(v))
// If maybeValue is some(x), calls process(x)
// If nothing, returns nothing

// Example
result = whenLet(map.get(data, "name"), (name) ->
  "Hello, " + name
)

// unless-let
unlessLet(errorValue, (e) -> logError(e))

// when-some (for multiple optionals)
result = whenSome(
  [map.get(m, "x"), map.get(m, "y")],
  ([x, y]) -> x + y
)
// Only executes if all are some

// when in pipeline
data
  |> process
  |> when(condition, transform)
  |> finalize
```

**Use Cases:**

- Optional execution
- Null checks
- Conditional transformation
- Guard clauses

**Implementation Notes:**

- Simple desugaring
- Works with Maybe/Option type
- Pipeline friendly

---

### 42. With Expressions

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
Local sequential bindings inside an expression. This is one of the most useful missing pieces in an expression-oriented language because it removes repetition without forcing helper values into the global namespace.

**Proposed Syntax:**

```primal
// Basic with expression
result = with {
  x = 10
  y = 20
  z = x + y
} in x * y * z

// With for computed temporary values
quadraticRoots(a, b, c) = with {
  discriminant = b * b - 4 * a * c
  sqrtD = num.sqrt(discriminant)
  denom = 2 * a
} in [(-b + sqrtD) / denom, (-b - sqrtD) / denom]

distance2D(point) = with {
  x = point[0]
  y = point[1]
} in num.sqrt(x * x + y * y)
```

**Use Cases:**

- Complex calculations with intermediates
- Avoiding repeated expressions
- Keeping helper names out of the global scope
- Readable complex expressions

**Implementation Notes:**

- The MVP should support sequential value bindings only.
- Each binding is visible to later bindings and to the final body.
- This is not just parser sugar in the current compiler; it needs an internal local-binding form or an equivalent semantic transformation.
- Local helper functions and destructuring can be layered on later, but the first version should stay small and predictable.

---

### 43. Placeholder Arguments

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
A compact shorthand for anonymous functions. This is excellent syntax once Primal has anonymous functions or an equivalent internal lambda form, but it should be treated as sugar rather than a standalone feature.

**Proposed Syntax:**

```primal
list.map(numbers, _ + 1)
list.filter(numbers, num.isEven(_))

list.reduce(numbers, 0, _1 + _2)
list.sort(names, str.compare(_1, _2))
list.zip(as, bs, [_1, _2])

// Multiple uses of same placeholder = same argument
list.map(numbers, _ * _)                  // x -> x * x

// Explicit argument positions for multi-argument cases
list.reduce(numbers, 1, _1 * _2)
```

**Use Cases:**

- Concise lambdas
- Point-free style
- Readable transformations
- Quick predicates

**Implementation Notes:**

- `_` creates a single-argument anonymous function; `_1`, `_2`, ... create explicit positional arguments.
- Placeholder scope should be the smallest enclosing placeholder expression.
- This proposal is best shipped after anonymous functions; otherwise it becomes a one-off syntax feature with no general lambda model.
- The parser should reject ambiguous cases rather than guessing what the user meant.

---

### 44. Method Chaining Syntax

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **Medium** |
| Complexity | **Medium** |
| Impact     | **High**   |

**Description:**
Fluent call chains can make transformation pipelines easier to read, but this feature is less trivial in Primal than it first appears. The current language already uses dots inside identifiers (`list.map`, `str.uppercase`), so `x.f(y)` is not just a small parser rewrite.

**Proposed Syntax:**

```primal
numbers.filter(isEven).map(double)

result = numbers
  .filter(num.isEven)
  .map(num.inc)
  .take(10)

// Standard-library aliases
"hello".uppercase()                       // str.uppercase("hello")
"hello".length()                          // str.length("hello")
42.abs()                                  // num.abs(42)
[1, 2, 3].reverse()                       // list.reverse([1, 2, 3])

// Mixed style
list.map(numbers, double)                 // traditional
numbers.map(double)                       // chained
```

**Use Cases:**

- Data transformation pipelines
- Fluent interfaces
- More linear reading order
- Lower cognitive load for nested calls

**Implementation Notes:**

- This requires either:
  - removing `.` from ordinary identifiers and introducing real postfix access parsing, or
  - special parser logic that distinguishes `list.map` as a single identifier from `value.map(...)` as chaining syntax.
- Bare method names like `map` and `uppercase` also require a resolution strategy from receiver type to namespace (`List -> list.*`, `String -> str.*`, `Number -> num.*`).
- Because of this, a pipeline operator may be a simpler first step than full method chaining.
- If adopted, the first version should probably target standard-library receivers only, not arbitrary user-defined dispatch.

---

### 49. From-End Indexing

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Negative indexes count backward from the end for strings and lists. This is unusually well aligned with the current parser because `xs[-1]` already parses today; only runtime semantics reject it.

**Proposed Syntax:**

```primal
[10, 20, 30][-1]                         // 30
[10, 20, 30][-2]                         // 20
"hello"[-1]                              // "o"
"hello"[-5]                              // "h"

last(xs) = xs[-1]
secondLast(xs) = xs[-2]
```

**Use Cases:**

- Last-element access
- Tail-oriented string work
- Cleaner indexing in small scripts
- Removing the need for repeated `length - 1` calculations

**Implementation Notes:**

- For lists and strings, negative index `-1` maps to `length - 1`.
- `-length` is the first element; smaller values remain out of bounds.
- The `@` / `[]` runtime function already centralizes indexing, so this is mostly a change in `element_at`.
- This keeps the surface area small by improving an existing form rather than inventing a new one.

---

### 50. Native Set / Vector Literal Syntax

| Property   | Rating     |
| ---------- | ---------- |
| Fit        | **High**   |
| Complexity | **Low**    |
| Impact     | **Medium** |

**Description:**
Literal syntax for `Set` and `Vector` values. Both runtime types already exist, but users currently have to call `set.new([...])` and `vector.new([...])`. Literal sugar would make them feel like first-class language constructs.

**Proposed Syntax:**

```primal
// Set literals
s1 = set{1, 2, 3}
s2 = set{1, 2, 2, 3}                     // duplicates collapsed
s3 = set{}

// Vector literals
v1 = vec[1, 2, 3]
v2 = vec[3, 4]

set.contains(s1, 2)                      // true
vector.magnitude(v2)                     // 5
vector.add(vec[1, 2], vec[3, 4])         // vec[4, 6]
```

**Use Cases:**

- Mathematical code
- Geometry and graphics
- Membership-heavy logic
- Cleaner examples and teaching material

**Implementation Notes:**

- `set{...}` can desugar to `set.new([...])`.
- `vec[...]` can desugar to `vector.new([...])`.
- This proposal is cheap because `SetNode` and `VectorNode` already exist in the runtime.
- Prefix forms avoid conflicts with existing map `{...}` and list `[...]` literals, and they are simpler than introducing `<...>` tokenization.

---

## Summary

This document proposes 50 new features for the Primal programming language, organized into 7 categories:

| Category                | Count | High Impact                                           |
| ----------------------- | ----- | ----------------------------------------------------- |
| Data Types & Structures | 11    | Matrices, Trees, Bytes                                |
| Functional Patterns     | 8     | Trampolining, Lenses, Transducers                     |
| Effects & Control Flow  | 6     | Validation, Async, Algebraic Effects                  |
| Type System             | 6     | Newtypes, Row Polymorphism                            |
| Language Primitives     | 8     | Namespace Blocks, Symbols, Debug/Trace                |
| Testing & Verification  | 4     | Property-Based Testing, Doctests                      |
| Syntax Sugar            | 7     | Case Expressions, With Expressions, From-End Indexing |

**Recommended Priority (High Fit + High Impact + Low/Medium Complexity):**

1. Namespace Blocks - near-zero runtime cost and solves real organization pain
2. Debug/Trace Expressions - immediate developer productivity
3. Bytes / Binary Data - fills a real gap around files, hashing, and I/O
4. Validation Type - essential for real applications
5. Case Expressions - cleaner conditionals with a straightforward desugaring story
6. With Expressions - local bindings without polluting the global namespace
7. Trampolining - enables deep recursion safely
8. Symbols/Atoms - efficient tags and keys, especially for tagged data
9. From-End Indexing - high-value improvement to an existing form
10. Doctests / Executable Examples - especially strong for Primal's educational focus

`Placeholder Arguments` and `Method Chaining` remain attractive, but they both become much cleaner once Primal also has anonymous functions and/or a pipeline operator.
