---
name: delta-review
description: Reviews staged and unstaged changes in this Dart project, checking for correctness, architecture, security, performance, readability, and style issues.
---

1. **When invoked**: Use the Task tool to spawn a review subagent with the full instructions below. The subagent should:
   a. Run `git diff HEAD` to see changes to tracked files
   b. Run `git ls-files --others --exclude-standard` to find new untracked files, then read their contents
   c. If there are no changes, report LGTM and stop
   d. Run `dart analyze` and include any issues in the report
   e. Proceed with the Analysis Phase

2. **Analysis Phase**: Read CLAUDE.md and analysis_options.yaml for project conventions. Then, for every changed file, review the diff and check for:
   - **Correctness**: Logic errors, off-by-one mistakes, missing edge cases, broken control flow, incorrect conditions, proper error handling. For compiler phases (reader, lexical, syntactic, semantic, runtime), verify state machine transitions are complete and deterministic. For library functions, verify type checks match the expected `Type` and `evaluate()` returns the correct `Node` subtype.
   - **Architecture**: Violations of project conventions, misuse of existing abstractions (`Analyzer<I,O>`, `State<I,O>`, `Node`, `Expression`, `Bindings`), circular dependencies, duplicated code that should be shared. Ensure new library functions follow the `NativeFunctionNode` pattern. Verify platform-specific code uses conditional imports (`dart.library.html`) rather than runtime checks.
   - **Security**: Injection risks in file/directory operations, missing input validation in library functions, exposed secrets, unsafe handling of user-provided `.prm` source code or REPL input.
   - **Performance**: Expensive operations in hot paths (runtime `evaluate()`, lexical/syntactic analysis loops), unnecessary allocations in recursive evaluation, unbounded recursion without depth guards, inefficient collection operations in library functions.
   - **Readability**: Unclear or overly complex code, poorly named functions and variables, missing or misleading comments, hard-to-follow control flow in state machines or expression parsing.
   - **Style**: Violations of analysis_options.yaml rules (single quotes, trailing commas, const constructors, final locals, return type declarations, null-aware operators), naming inconsistencies with existing code, dead code introduced, hardcoded values that belong in constants or the type system.

3. **Context Verification**: Before flagging an issue, read the surrounding code to confirm it is a real problem and not handled elsewhere. Minimize false positives. Pay special attention to the compiler pipeline — an apparent issue in one phase may be intentionally delegated to a later phase.

4. **Reporting**: Present the subagent's findings in a Markdown table:
   | File Path | Line # | Severity | Category | Description & Suggested Fix |
   | :--- | :--- | :--- | :--- | :--- |

   Severity levels: **Critical** (will cause bugs/crashes), **Warning** (potential issue or code smell), **Nit** (style/convention).
   If no issues are found, say LGTM and skip the table.
   End with a one-line summary: "X critical, Y warnings, Z nits across N files."

5. **Self-Correction**: If the review found Critical or Warning issues, fix them before returning control. Do NOT re-run the review after fixing. The user will request another review if needed.

6. **Formatting**: Before returning control to the user, run `dart format .` to ensure all code is properly formatted.
