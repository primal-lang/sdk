---
name: audit-tests
description: Audits test files in a specified folder, spawning parallel agents to identify missing test cases and edge cases.
---

Audit the test files in a user-specified folder, identify gaps in test coverage, and implement missing tests. Each test file is assigned to a dedicated subagent that runs in parallel.

## Initialization

1. **Require a folder parameter** — if not provided, ask the user to specify a folder path before proceeding. Do not guess or assume a default folder.
2. **Validate the folder** — verify the folder exists and contains `*_test.dart` files (search recursively).
3. **List test files** — use Glob to find all test files in the specified folder.

## Execution

1. **Spawn parallel agents** — one agent per test file found. All agents run concurrently.

2. **Each agent must**:
   a. Read and understand its assigned test file
   b. Identify the corresponding source files in `lib/` being tested (infer from imports and test subjects)
   c. Read all relevant source files to understand the full implementation
   d. Consult relevant documentation in `docs/` if needed (see mappings below) to understand expected behavior
   e. Analyze existing tests for completeness
   f. Implement missing tests directly in the assigned test file

## Documentation Reference

Agents may consult these docs to understand expected behavior:

| Source directory              | Documentation                |
| ----------------------------- | ---------------------------- |
| `lib/compiler/reader/`        | `docs/compiler/reader.md`    |
| `lib/compiler/lexical/`       | `docs/compiler/lexical.md`   |
| `lib/compiler/syntactic/`     | `docs/compiler/syntactic.md` |
| `lib/compiler/semantic/`      | `docs/compiler/semantic.md`  |
| `lib/compiler/runtime/`       | `docs/compiler/runtime.md`   |
| `lib/compiler/models/`        | `docs/compiler/models.md`    |
| `lib/compiler/library/<name>` | `docs/reference/<name>.md`   |

## Coverage Rules

Each agent should ensure the following are tested:

**Functionality Coverage**:

- All public functions and methods in the source file(s) have corresponding tests
- All code branches (if/else, switch cases, guard clauses) are exercised
- All error conditions and exception paths are tested

**Edge Cases**:

- Empty inputs (empty strings, empty collections, zero values)
- Boundary values (first/last elements, min/max numbers)
- Null handling (where applicable)
- Single-element cases
- Large inputs (stress testing where relevant)

**Error Cases**:

- Invalid inputs that should trigger errors
- Type mismatches
- Out-of-bounds access
- Missing required values

## Implementation Guidelines

- **Follow existing patterns**: Match the test structure, naming conventions, and helper functions already used in the test file
- **Use descriptive names**: Test names should clearly describe what is being tested and expected outcome
- **Group related tests**: Use `group()` to organize test cases logically
- **One assertion focus**: Each test should focus on verifying one specific behavior
- **Preserve existing tests**: Do not modify or remove existing tests unless they are incorrect

## Output

When all agents complete, provide a summary:

```
# Test Audit Summary

## Files Audited

- [list of test files processed]

## Tests Added

| File | Tests Added | Categories                         |
| ---- | ----------- | ---------------------------------- |
| ...  | X           | [edge cases, error handling, etc.] |

## Remaining Gaps

[Any coverage gaps that could not be automatically addressed]
```
