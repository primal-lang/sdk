---
name: audit-coverage
description: Audits test coverage across all pipeline stages, identifies gaps, and implements missing tests to achieve 100% coverage.
---

1. **When invoked**: Use the Task tool to spawn an audit subagent with the full instructions below. The subagent should perform all phases sequentially.

---

## Phase 1: Coverage Analysis

1. Run `dart test --coverage` to generate coverage data
2. Run `dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib` to format coverage
3. Parse the coverage report to identify:
   - Files with less than 100% line coverage
   - Specific uncovered lines and branches
   - Overall coverage percentage

---

## Phase 2: Pipeline Propagation Analysis

For each language feature (literals, operators, control flow, collections, etc.), verify it is tested at all applicable pipeline stages:

| Feature | Reader | Lexical | Syntactic | Semantic | Runtime |
| ------- | ------ | ------- | --------- | -------- | ------- |
| Strings | ✓/✗    | ✓/✗     | ✓/✗       | ✓/✗      | ✓/✗     |
| Numbers | ✓/✗    | ✓/✗     | ✓/✗       | ✓/✗      | ✓/✗     |
| ...     |        |         |           |          |         |

**Rules**:

- Lexical tests should cover tokenization of all literal types, operators, and delimiters
- Syntactic tests should cover parsing of all expression types and function definitions
- Semantic tests should cover validation errors (undefined identifiers, type mismatches, etc.)
- Runtime tests should cover evaluation and error handling

**Flag**: Features tested in early stages but missing from later stages.

---

## Phase 3: Feature Coverage Analysis

1. Read all files in `docs/reference/*.md` to extract documented core functions
2. For each documented function, search for corresponding tests in `test/runtime/`
3. Generate a coverage matrix:

| Category   | Function | Has Test | Edge Cases | Error Cases |
| ---------- | -------- | -------- | ---------- | ----------- |
| Arithmetic | num.abs  | ✓/✗      | ✓/✗        | ✓/✗         |
| ...        |          |          |            |             |

**Flag**: Functions without tests or missing edge/error case coverage.

---

## Phase 4: Error Coverage Analysis

1. Find all error classes:
   - `lib/compiler/errors/*.dart` (LexicalError, SyntacticError, SemanticError)
   - `lib/compiler/library/error/*.dart` (runtime errors)
2. For each error type, verify there is at least one test that triggers it
3. Generate a report:

| Error Type         | File               | Has Test |
| ------------------ | ------------------ | -------- |
| InvalidNumberError | lexical_error.dart | ✓/✗      |
| ...                |                    |          |

**Flag**: Error types without corresponding test cases.

---

## Phase 5: Edge Case Audit

For each tested feature, verify these edge cases are covered:

**Primitives**:

- Empty string `""`
- Zero `0`, negative numbers `-1`, very large numbers `1e308`
- Boolean literals `true`, `false`

**Collections**:

- Empty collections `[]`, `{}`, `set.new()`, `stack.new()`, `queue.new()`, `vector.new()`
- Single-element collections
- Nested collections `[[1], [2]]`, `{"a": {"b": 1}}`
- Large collections (performance edge case)

**Operations**:

- Division by zero
- Modulo by zero
- Index out of bounds (negative, beyond length)
- Operations on empty collections (`list.head([])`, `list.tail([])`)

**Control Flow**:

- Deeply nested if/else
- Recursive functions at base case and recursive case

**Functions**:

- Zero-argument functions
- Functions with many arguments
- Higher-order functions
- Partial application / currying

**Flag**: Missing edge case tests.

---

## Phase 6: Test Quality Audit

1. **Naming**: Verify test names are descriptive (not `test 1`, `test 2`)
2. **Assertions**: Verify tests have meaningful assertions (not just `expect(result, isNotNull)`)
3. **Isolation**: Verify tests don't depend on execution order
4. **Duplication**: Identify tests that check the same thing redundantly

---

## Phase 7: Report Generation

Generate a summary report in this format:

```
# Test Audit Report

## Coverage Summary
- Overall: X%
- Compiler: X%
- Runtime: X%

## Pipeline Gaps
[List features missing tests at certain stages]

## Missing Feature Tests
[List undocumented functions without tests]

## Missing Error Tests
[List error types without tests]

## Missing Edge Cases
[List edge cases that need tests]

## Quality Issues
[List naming, assertion, or duplication issues]

## Implementation Plan
[Prioritized list of tests to add, ordered by impact on coverage]
```

---

## Phase 8: Test Implementation

After generating the report, implement missing tests to achieve 100% coverage:

1. **Prioritize by coverage impact**: Start with files that have the lowest coverage
2. **Follow existing patterns**: Use the same test helpers (`getTokens`, `getFunctions`, `getIntermediateRepresentation`, `getRuntime`, `checkResult`, `checkTokens`, etc.)
3. **Use existing test structure**:
   - Place compiler tests in `test/compiler/`
   - Place runtime tests in `test/runtime/` organized by category
   - Use `@Tags(['compiler'])` or `@Tags(['runtime'])` appropriately
4. **Test naming**: Use descriptive names that explain what is being tested
5. **Group related tests**: Use `group()` to organize related test cases

**Implementation order**:

1. Error type coverage (ensure all errors can be triggered)
2. Core function coverage (ensure all documented functions are tested)
3. Edge case coverage (ensure boundary conditions are handled)
4. Pipeline propagation (ensure features are tested at all stages)
5. Uncovered lines (target specific uncovered code paths)

---

## Phase 9: Verification

After implementing tests:

1. Run `dart test` to verify all tests pass
2. Run `dart test --coverage` again to measure new coverage
3. Report the coverage improvement: "Coverage improved from X% to Y%"
4. If coverage is not 100%, return to Phase 8 and continue implementing tests
5. Run `dart format .` to ensure code style

---

## Output

When complete, provide:

1. The full audit report (Phase 7)
2. Summary of tests added (file, test count, coverage impact)
3. Final coverage percentage
4. Any remaining gaps that could not be automatically addressed (with explanation)
