# Syntactic Analyzer Improvement Plan

This document details issues found in the syntactic analyzer and the plan to fix them.

**Files involved:**

- `lib/compiler/syntactic/expression_parser.dart`
- `lib/compiler/syntactic/syntactic_analyzer.dart`
- `lib/compiler/syntactic/expression.dart`

---

## Summary: Implementation Order

I recommend implementing these fixes in the following order:

1. **Issue 5** (zero-param functions) - Simple, isolated change
2. **Issue 6** (trailing commas) - Simple, isolated changes
3. **Issue 3 & 4** (call/index chaining) - Rewrite `call()` function
4. **Issue 1 & 2** (operator precedence) - Reorder and split precedence functions
5. ~~**Issue 7** (map keys) - Requires changes to data structures~~ **DONE** - Implemented using `List<MapEntryExpression>`

### Files to Modify

| File                                             | Issues                       |
| ------------------------------------------------ | ---------------------------- |
| `lib/compiler/syntactic/syntactic_analyzer.dart` | Issue 5                      |
| `lib/compiler/syntactic/expression_parser.dart`  | Issues 1, 2, 3, 4, 6, ~~7~~  |
| `lib/compiler/syntactic/expression.dart`         | ~~Issue 7~~ (done)           |

### Testing Considerations

After implementing these fixes, add or update tests for:

1. Operator precedence: `a > b & c`, `a | b & c`, `a == b > c`
2. Chained operations: `a[0][1]`, `f()()`, `f()[0]`, `a[0]()`
3. Zero-param functions: `f() = 1`
4. Trailing commas: `[1,]`, `{a: 1,}`, `f(x,)`
5. Map literals with duplicate keys (if semantic analysis is added)

---

## Documentation Update

After implementing these changes, update `docs/compiler/syntactic.md` to reflect:

1. Corrected precedence table
2. Split of `logic` into `logicOr` and `logicAnd`
3. Support for zero-parameter function syntax
4. Support for trailing commas
5. ~~Changed internal representation of map literals (if Option A is chosen)~~ **DONE** - `MapExpression` now uses `List<MapEntryExpression>`
