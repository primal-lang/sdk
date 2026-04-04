---
name: audit-bugs
description: Audits the codebase for bugs, inconsistencies, and potential runtime issues. Focuses on logic errors, Dart gotchas, and compiler-specific patterns.
---

1. **When invoked**: Use the Task tool to spawn an audit subagent with the full instructions below. The subagent should perform all phases sequentially.

---

## Focus Area 1: Logic & Control Flow

- **Boolean Contradictions**: Scan for logical contradictions (e.g., `if (x && !x)`), unnecessary double-negations, or assignments where comparisons were intended (`if (x = 5)`).
- **Off-By-One Errors**: Inspect loops, `ListIterator` usage, and index-based access for potential out-of-bounds errors. Pay special attention to `hasNext`, `isAtEnd`, and `advance()`/`back()` usage.
- **Unreachable Code**: Detect code after `return`, `throw`, `continue`, or `break` statements.
- **Switch/Case Completeness**: Identify switch statements on enums that don't cover all cases and lack a default branch.
- **Redundant Conditions**: Find `if/else` blocks that execute the same code in both branches, or conditions that are always true/false.

---

## Focus Area 2: Dart-Specific Gotchas

- **Null Safety Gaps**: Find nullable types accessed without null checks (`!`, `??`, `?.`, or prior `if` check). Pay attention to `T?` return types from methods like `ListIterator.peek` and `ListIterator.previous`.
- **Type Promotion Breaks**: Identify cases where a null check doesn't promote because the variable is reassigned or is a non-local variable.
- **Late Initialization**: Find `late` variables that might be accessed before initialization.
- **Collection Safety**: Detect `.first`, `.last`, `.single` on potentially empty collections without guards. Check for `.firstWhere()` / `.singleWhere()` without `orElse`.
- **Cascade Pitfalls**: Flag cascades (`..`) that might fail if an intermediate call returns null.

---

## Focus Area 3: Compiler Pipeline Integrity

- **State Machine Completeness**: For lexical/syntactic analyzers, verify all states handle all possible inputs (no missing transitions that would cause silent failures or infinite loops).
- **AST Node Consistency**: Verify all `Node` subclasses implement required methods (`evaluate()`, `substitute()`, etc.) correctly. Check that `type` getters return the correct `Type`.
- **Evaluation Safety**: In `NativeFunctionNode` implementations, verify:
  - All arguments are evaluated before use (`arguments[i].evaluate()`)
  - Type checks match parameter declarations
  - Return types match the documented behavior
- **Error Propagation**: Ensure errors thrown in one pipeline stage don't get silently caught and ignored. Verify `try/catch` blocks either re-throw, log, or handle appropriately.

---

## Focus Area 4: Resource & Performance

- **Unbounded Recursion**: Identify recursive functions (especially in runtime evaluation) that lack depth guards and could cause stack overflow on malicious input.
- **Inefficient Evaluation**: Flag repeated `.evaluate()` calls on the same node (should evaluate once and store).
- **String Concatenation in Loops**: Detect string building via `+` in loops (should use `StringBuffer`).
- **Collection Allocation in Hot Paths**: Find unnecessary `List` or `Map` creation inside `evaluate()` methods.

---

## Focus Area 5: Consistency & Conventions

- **Naming Inconsistencies**: Flag variations in naming patterns (e.g., `numDiv` vs `num_div`, `isEven` vs `is_even`).
- **Pattern Violations**: Identify library functions that don't follow the `NativeFunctionNode` / `NativeFunctionNodeWithArguments` pattern.
- **Parameter Declaration Mismatches**: Verify `Parameter.number()`, `Parameter.string()`, etc. match the actual type checks in `evaluate()`.
- **Missing `const` Constructors**: Flag classes with only `final` fields that should have `const` constructors.

---

## Cross-Reference Verification

Before reporting an issue:

1. Check if the "bug" is handled by a parent component or later pipeline stage
2. Verify the behavior against the documentation in `docs/`
3. Consider whether the pattern matches existing, intentional code elsewhere

Only report issues you are confident about.

---

## Output Format

Write findings to `audit-report.md` in the project root:

```markdown
# Bug Audit Report

**Scope**: [files/directory audited]
**Date**: [current date]

## Summary

| Severity | Count |
| :------- | ----: |
| Critical |     X |
| Warning  |     Y |
| Info     |     Z |

## Critical Issues

[Issues that will cause incorrect behavior, crashes, or data corruption]

### [File Path]

**Line X**: [Issue title]

- **Issue**: [Explanation of the bug]
- **Impact**: [What could go wrong]
- **Fix**: [Code snippet showing the fix]

## Warnings

[Issues that could cause problems under specific conditions]

## Info

[Minor improvements and defensive programming suggestions]
```

---

## Guidelines

- Only report real, actionable issues — not stylistic preferences
- Respect existing project conventions (see `CLAUDE.md`)
- Do NOT modify any code — only report findings
- Prioritize by severity: correctness and safety first
- Run `dart analyze` first and incorporate any static analysis warnings

---

## Post-Fix Requirements

After fixing an issue identified by this audit:

1. **Write Tests**: Add tests that cover the fixed problem
   - Include a test for the successful/correct behavior
   - Include a test for the failure case that was previously broken
2. **Update Documentation**: If the fix changes behavior or adds constraints, update the relevant documentation in `docs/`
