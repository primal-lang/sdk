---
name: delta-review
description: TODO
---

1. **When invoked**: Use the Task tool to spawn a review subagent with the full instructions below. The subagent should:
   a. Run `git diff HEAD` to see changes to tracked files
   b. Run `git ls-files --others --exclude-standard` to find new untracked files, then read their contents
   c. If there are no changes, report LGTM and stop
   d. Otherwise, proceed with the Analysis Phase

2. **Analysis Phase**: Read CLAUDE.md, architecture.md, and specs.md for project conventions. Then, for every changed file, review the diff and check for:
   - **Correctness**: Logic errors, off-by-one mistakes, missing edge cases, broken control flow, incorrect conditions, proper error handling.
   - **Architecture**: Violations of project conventions, misuse of existing abstractions, circular dependencies, prop mutation, duplicated code that should be shared.
   - **Security**: Injection risks, missing input validation, exposed secrets or API keys, unsafe user input handling.
   - **Performance**: Unnecessary re-renders, expensive operations in hot paths, memory leaks, missing cleanup, unoptimized algorithms or data structures.
   - **Readability**: Unclear or overly complex code, poorly named functions and variables, missing or misleading comments, hard-to-follow control flow.
   - **Style**: Naming inconsistencies, dead code introduced, missing localization keys, hardcoded values that belong in balancing.js or constants.js.

3. **Context Verification**: Before flagging an issue, read the surrounding code to confirm it is a real problem and not handled elsewhere. Minimize false positives.

4. **Reporting**: Present the subagent's findings in a Markdown table:
   | File Path | Line # | Severity | Category | Description & Suggested Fix |
   | :--- | :--- | :--- | :--- | :--- |

   Severity levels: **Critical** (will cause bugs/crashes), **Warning** (potential issue or code smell), **Nit** (style/convention).
   If no issues are found, say LGTM and skip the table.
   End with a one-line summary: "X critical, Y warnings, Z nits across N files."

5. **Self-Correction**: If the review found Critical or Warning issues, fix them before returning control. Do NOT re-run the review after fixing. The user will request another review if needed.
