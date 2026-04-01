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
6. Tuples/records with destructuring
   This would give Primal a lightweight way to model structured
   data without forcing everything through maps. It also opens the
   door to cleaner function returns and helper composition.
7. Named and default arguments
   str.padLeft("42", width: 5, fill: "0")
   This matters because the standard library is already large, and
   many calls are hard to read positionally.
