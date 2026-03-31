# Primal Language Feature Proposal

## Goal

This proposal pushes Primal toward maximum expressive power through syntax and ergonomics, while staying aligned with the language's current identity:

- expression-oriented
- functional
- immutable
- lazy
- single-file-friendly
- easy to read for learners

The intent is not to make Primal larger in every direction. The intent is to make common Primal programs dramatically less verbose and more local.

## Decision Summary

These decisions were chosen for the current proposal:

| Area | Decision |
| :--- | :--- |
| Pipeline | `|>` always inserts the left value as the first argument |
| Expression blocks | `do ... end` blocks are allowed |
| Block contents | `do ... end` supports local value bindings only, not local function definitions |
| Destructuring | Supported in `do ... end` and value bindings inside `where` |
| Pattern kinds | Lists, maps, nested patterns, `_` wildcard, `...rest` |
| `where` scope | `where` is sequential |
| `where` contents | Both local values and local functions |
| Local functions in `where` | Function names are hoisted within the `where` block; value bindings remain top-to-bottom |
| Destructuring mismatch | Runtime error |
| Priority | Syntax and ergonomics first, with maximum expressive power |

## Recommended Feature Set

### 1. `where` Blocks

`where` should become the main way to keep helpers local to an expression.

#### Syntax

```primal
quicksort(xs) =
  if (list.isEmpty(xs))
    []
  else
    quicksort(smaller) + pivot + quicksort(greater)
where
  pivot = list.first(xs)
  rest = list.rest(xs)
  smaller = [x for x in rest if x < pivot]
  greater = [x for x in rest if x >= pivot]
```

`where` should also allow local functions:

```primal
main = score([1, -2, 3, -4])
where
  isPositive(n) = n > 0
  score(xs) = list.reduce(list.filter(xs, isPositive), 0, num.add)
```

#### Semantics

- `where` attaches to an expression.
- Entries are evaluated sequentially.
- Value bindings are visible only after they are declared.
- Local function names are hoisted within the same `where` block.
- Local function bodies may reference:
  - any local function in the same `where` block
  - any earlier value binding in the same `where` block
  - outer scope bindings
- Local function bodies may not reference later value bindings.
- `where` supports both value bindings and local function definitions.
- Value bindings inside `where` may use destructuring patterns.

#### Consequences

This works:

```primal
main = result
where
  a = 1
  b = a + 2
  result = b * 3
```

This does not:

```primal
main = result
where
  b = a + 2
  a = 1
  result = b * 3
```

This works because function names are hoisted:

```primal
main = isEven(4)
where
  isEven(n) = if (n == 0) true else isOdd(n - 1)
  isOdd(n) = if (n == 0) false else isEven(n - 1)
```

This does not, because `base` is a later value:

```primal
main = f(1)
where
  f(n) = n + base
  base = 10
```

### 2. `do ... end` Expression Blocks

`do ... end` should be the main way to write local step-by-step value computation without introducing global names.

#### Syntax

```primal
main = do
  xs = [1, 2, 3, 4]
  evens = list.filter(xs, isEven)
  doubled = list.map(evens, double)
  doubled
end
```

Blocks should also support wildcard bindings for sequencing effectful expressions:

```primal
main = do
  _ = console.writeLn("starting")
  value = console.read()
  value
end
```

#### Semantics

- A block contains zero or more value bindings followed by one final expression.
- Bindings are sequential.
- Later bindings can use earlier bindings.
- The last expression is the block result.
- Names declared in the block do not escape.
- Local function definitions are not allowed in `do ... end`.
- Destructuring is allowed in block bindings.

### 3. Destructuring Patterns

Destructuring should be shared by:

- `do ... end` bindings
- value bindings inside `where`
- comprehension generators

#### Supported Patterns

List patterns:

```primal
[a, b] = [10, 20]
[head, ...tail] = [1, 2, 3, 4]
[_, second, ...rest] = [10, 20, 30, 40]
```

Map patterns:

```primal
{"x": x, "y": y} = {"x": 3, "y": 4}
{"x": x, ...rest} = {"x": 1, "y": 2, "z": 3}
```

Nested patterns:

```primal
[name, {"age": age, "tags": [firstTag, ...otherTags]}] =
  ["Alice", {"age": 30, "tags": ["admin", "editor"]}]
```

#### Rules

- `_` discards a matched value.
- `...rest` captures remaining list elements or remaining map entries.
- `...rest` may appear at most once in a pattern.
- In list patterns, `...rest` must be in the final position.
- In map patterns, `...rest` captures unmatched entries.
- Map patterns require listed keys to exist.
- Extra map keys are ignored unless captured by `...rest`.
- List patterns require exact length unless `...rest` is present.
- Reusing the same bound name in a single pattern should be a semantic error.

#### Error Model

Pattern mismatch should raise a runtime error.

Examples:

```primal
main = do
  [a, b] = [1]
  a + b
end
```

```primal
main = do
  {"x": x} = {"y": 10}
  x
end
```

Both should fail with a dedicated runtime error such as `PatternMatchError`.

### 4. Pipeline Operator `|>`

Primal already has a large prefix-style standard library. A pipeline operator would make real programs much easier to read.

#### Syntax

```primal
main =
  input
  |> str.trim()
  |> str.lowercase()
  |> str.split(",")
```

#### Semantics

`a |> f()` desugars to:

```primal
f(a)
```

`a |> f(b, c)` desugars to:

```primal
f(a, b, c)
```

`a |> g |> h()` desugars left-to-right:

```primal
h(g(a))
```

#### Parsing Rule

- `|>` should be left-associative.
- It should have lower precedence than calls, indexing, arithmetic, comparison, and logic.
- It should bind tighter than a trailing `where` clause.

### 5. Placeholder Partial Application with `_`

This is the fastest route to lambda-level expressiveness without forcing full anonymous-function syntax first.

#### Syntax

```primal
inc = num.add(_, 1)
isShort = str.length(_) < 5
pair = [_, _]
takeFrom = list.at(_, _)
```

It should also work with operators:

```primal
inc = _ + 1
between = (_ >= 0) & (_ <= 10)
prependZero = [0, ..._]
```

#### Semantics

Any expression containing one or more placeholder occurrences becomes a function value.

Examples:

```primal
num.add(_, 1)
```

desugars conceptually to:

```primal
lambda(a) = num.add(a, 1)
```

and

```primal
list.reduce(_, 0, _)
```

becomes a function of two parameters, assigned left-to-right by placeholder appearance.

#### Rules

- Placeholder parameters are ordered left-to-right.
- Multiple placeholders are allowed.
- `_` inside a pattern is a wildcard, not a function placeholder.
- Placeholder-based functions should close over the surrounding lexical scope.

Example:

```primal
main =
  if (list.isEmpty(xs))
    []
  else
    list.filter(xs, _ > pivot)
where
  xs = [1, 4, 2, 9]
  pivot = 3
```

### 6. Guarded Function Clauses with `when`

Guards give Primal a natural recursive style without forcing nested `if` ladders everywhere.

#### Syntax

```primal
abs(n) when n >= 0 = n
abs(n) when n < 0 = -n
```

Fallback clauses should be allowed:

```primal
sign(n) when n > 0 = 1
sign(n) when n < 0 = -1
sign(n) = 0
```

Local functions inside `where` should support the same form:

```primal
main = classify(10)
where
  classify(n) when n < 0 = "negative"
  classify(n) when n == 0 = "zero"
  classify(n) = "positive"
```

#### Rules

- Clauses with the same function name and arity must be contiguous.
- Clauses are tried top-to-bottom.
- The first matching guard wins.
- A clause without `when` acts as the fallback case.
- Guarded clauses are not general overloading; they are multiple clauses of one logical function.

#### Lowering

This:

```primal
sign(n) when n > 0 = 1
sign(n) when n < 0 = -1
sign(n) = 0
```

should lower to the equivalent of:

```primal
sign(n) = if (n > 0) 1 else if (n < 0) -1 else 0
```

### 7. Comprehensions

Comprehensions should provide concise, local collection-building syntax.

#### List Comprehensions

```primal
[x * x for x in xs if x > 0]
```

Multiple generators should be allowed:

```primal
[[x, y] for x in xs, y in ys if x < y]
```

Pattern destructuring should work in generators:

```primal
[name for {"name": name, "active": true} in users]
```

#### Map Comprehensions

```primal
{k: v * 2 for [k, v] in pairs}
```

With filtering:

```primal
{k: v for [k, v] in pairs if v > 0}
```

#### Rules

- Generator clauses use `for pattern in expression`.
- Filter clauses use `if expression`.
- Clauses are evaluated left-to-right.
- Generators should use the same pattern engine as block and `where` bindings.
- V1 should support list sources directly.
- Ranges should also be valid comprehension sources.

### 8. Ranges, Slices, and Spread

These features remove a large amount of current verbosity around collection construction and access.

#### Ranges

```primal
1..5      // [1, 2, 3, 4, 5]
1..<5     // [1, 2, 3, 4]
5..1      // [5, 4, 3, 2, 1]
```

#### Range Rules

- Ranges are numeric.
- `..` is inclusive.
- `..<` is exclusive at the end.
- Step is inferred as `+1` or `-1`.
- V1 does not need custom step syntax.

#### Slices

```primal
xs[2:5]
xs[:3]
xs[3:]
"hello"[1:4]
```

#### Slice Rules

- Supported on lists and strings.
- Omitted start means from the beginning.
- Omitted end means to the end.
- V1 should reject negative indices to stay consistent with current indexing rules.

#### Spread

List spread:

```primal
[0, ...xs, 99]
```

Map spread:

```primal
{"name": name, ...defaults, "active": true}
```

#### Spread Rules

- Spread is valid only inside list and map literals.
- List spread requires a list value.
- Map spread requires a map value.
- Spread expressions are evaluated in literal order.

### 9. Function Composition Operators `>>` and `<<`

These are useful, but they should come after placeholders and pipelines.

#### Syntax

```primal
sanitize = str.trim >> str.lowercase
project = parse << str.trim
```

#### Semantics

- `f >> g` means `x => g(f(x))`
- `f << g` means `x => f(g(x))`
- V1 should define these for unary functions only

This fits naturally after placeholder partial application exists.

## Cross-Cutting Language Rules

### Scope Model

Primal currently has global top-level functions and parameter substitution. These features require true nested lexical scope.

The recommended scope model is:

- top-level scope for existing functions
- nested lexical scopes for `do ... end` and `where`
- closures for placeholder-based functions
- local function environments inside `where`

### New Diagnostics

The following new diagnostics are recommended:

- `PatternMatchError`
- `DuplicatePatternBindingError`
- `InvalidRestPatternError`
- `InvalidGuardClauseError`
- `InvalidPipelineTargetError`
- `InvalidPlaceholderUsageError`

### Precedence Recommendation

Suggested precedence from low to high:

1. trailing `where`
2. pipeline `|>`
3. equality and comparison
4. logic
5. arithmetic
6. composition `>>` `<<`
7. unary
8. call, indexing, slicing
9. primary literals, comprehensions, ranges, blocks

Exact parser details can shift, but `|>` must stay easy to reason about.

## Recommended Implementation Order

1. Introduce pattern AST/runtime support and nested lexical scopes.
2. Add `do ... end` blocks using value bindings and pattern matching.
3. Add trailing `where` with sequential values and hoisted local functions.
4. Add `|>` pipeline desugaring.
5. Add placeholder partial application and closure capture.
6. Add guarded function clauses and clause grouping.
7. Add ranges, slices, and spread.
8. Add comprehensions.
9. Add `>>` and `<<` composition.

This order builds the semantic foundation first and then layers syntax sugar on top of it.

## Compiler Areas Likely to Change

### Scanner and Lexer

- `lib/compiler/scanner/scanner_analyzer.dart`
- `lib/compiler/lexical/lexical_analyzer.dart`
- `lib/compiler/lexical/token.dart`
- `lib/extensions/string_extensions.dart`

Needed for:

- new keywords: `where`, `when`, `for`, `in`, `do`, `end`
- new operators: `|>`, `>>`, `<<`, `..<`, `...`
- slicing punctuation reuse

### Parser and AST

- `lib/compiler/syntactic/expression_parser.dart`
- `lib/compiler/syntactic/expression.dart`
- `lib/compiler/syntactic/syntactic_analyzer.dart`
- `lib/compiler/syntactic/function_definition.dart`

Needed for:

- block expressions
- trailing `where`
- patterns
- guard clauses
- comprehensions
- ranges and slices
- placeholder expressions

### Semantic Analysis

- `lib/compiler/semantic/semantic_analyzer.dart`

Needed for:

- nested scopes
- local bindings
- local function resolution
- guarded clause grouping
- duplicate binding checks in patterns
- placeholder arity inference

### Runtime

- `lib/compiler/runtime/node.dart`
- `lib/compiler/runtime/bindings.dart`
- `lib/compiler/runtime/scope.dart`
- `lib/compiler/runtime/runtime.dart`

Needed for:

- lexical environments
- block evaluation
- pattern binding
- closures
- local functions inside `where`
- slice and range evaluation

### Errors, Docs, and Tests

- `lib/compiler/errors/`
- `docs/`
- `test/`

Every feature above will need dedicated lexical, syntactic, semantic, and runtime tests.

## Recommended Non-Goals for This Phase

These are deliberately deferred:

- static typing
- type inference
- imports/modules
- transpilation
- richer exception syntax

`try` already exists today as a function, and the bigger gap is expression-local ergonomics rather than type system depth.

## Final Recommendation

If only a subset is implemented in the near term, the highest-value sequence is:

1. `where`
2. `do ... end`
3. destructuring
4. `|>`
5. placeholder partial application
6. guarded clauses

That subset alone would make Primal substantially more expressive while still feeling like Primal.

---

| Tagged unions / enums | Better data modelling than ad-hoc maps
for an educational functional language, and a good foundation for
future matching later.
| Function contracts / requires | Sample programs currently spell
preconditions manually with if + error.throw; this could be first-
class sugar.


  5. Function composition operators
     sanitize = str.trim >> str.lowercase
  8. Tuples/records with destructuring
     This would give Primal a lightweight way to model structured
     data without forcing everything through maps. It also opens the
     door to cleaner function returns and helper composition.
  9. Named and default arguments
     str.padLeft("42", width: 5, fill: "0")
     This matters because the standard library is already large, and
     many calls are hard to read positionally.

