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

2. **Analysis Phase**: Read CLAUDE.md and analysis_options.yaml for project conventions. Then, for every changed file, review the diff against two layers: a general defect taxonomy (Layer A) and the Primal/Dart project lens (Layer B). The tiers in Layer A describe *what to hunt for* and roughly how much it matters — they are orthogonal to the severity assigned per finding in step 4. Rough mapping: Tier A and Tier B findings are usually **Critical** or **Warning**; Tier C is usually **Warning** or **Nit**, and only when it demonstrates a real behavioral defect.

   **Layer A — Defect taxonomy**

   - **Tier A — Runtime correctness**
     - **Logic errors:** off-by-one mistakes, inverted conditions, wrong operators or variables, swapped arguments, incorrect units, precedence mistakes, stale copy-paste logic, wrong loop bounds, integer vs. double division (`~/` vs `/`), and skipped side effects.
     - **Null and numeric hazards:** unchecked nullable access, bang-operator (`!`) misuse, `late` fields read before initialization, absent values confused with empty or zero, null collection elements, `NaN`/`Infinity` propagation, `int` overflow on the web/JS runtime, and precision loss in `num`/`double` conversions.
     - **Boundary and encoding cases:** empty, singleton, duplicate, sorted, zero, negative, maximum, malformed, or very large inputs; whitespace; Unicode/combining characters and surrogate-pair handling while lexing; `.prm` source with unusual code points.
     - **Error handling:** swallowed or over-broad catches (`empty_catches`, `avoid_catching_errors`), failure reported as success, partial state without rollback, cleanup in `finally` masking the original error (`control_flow_in_finally`, `throw_in_finally`), and unbounded retries.
     - **Concurrency / async:** unawaited futures (`unawaited_futures`), missing or incorrect `await`, fire-and-forget `async` work whose errors are dropped, and uncancelled stream subscriptions (`cancel_subscriptions`).
     - **Resource management:** leaked file handles, streams, sinks, and subscriptions; missing `close()` or cleanup on failure paths; unbounded growth of caches or `Bindings`.
     - **State and lifecycle:** stale state, invalid or incomplete state-machine transitions in the reader/lexical/syntactic/semantic phases, initialization-order errors, cache invalidation, and mutation of a collection during iteration.
   - **Tier B — Contracts, data integrity, and security**
     - **Contract mismatches:** caller and callee disagree on units, ranges, indexing, nullability, ownership, or return shape; `Parameter.number()`/`Parameter.string()` declarations that don't match the actual type checks in `reduce()`; a `Term`'s `type` getter or `reduce()` returning the wrong `Type`/`Term` subtype.
     - **Validation and coercion:** malformed external input (`.prm` source, REPL input, file contents), lossy conversion, locale-dependent parsing, missing range checks, unbounded allocations, and pathological or invalid regexes (`valid_regexps`).
     - **Resource and configuration parity:** missing `switch`/enum cases or absent default branches (`no_duplicate_case_values`), incomplete lookup tables, and drifted defaults across the pipeline.
     - **Security defects:** path traversal or injection in file/directory operations, unsafe handling of user-provided `.prm`/REPL input reaching a dangerous sink, exposed secrets, and unbounded recursion or allocation reachable from untrusted source (a DoS vector in `reduce()`).
   - **Tier C — Broader behavioral anomalies**
     - **Dead or unreachable behavior:** report only when it demonstrates a behavioral defect — a missing feature path, impossible intended state transition, ineffective guard, or silently skipped operation. Don't report harmless dead code on its own (`dead_code: error` already flags it).
     - **API or library misuse:** violated preconditions, skipped cleanup, wrong call order, ignored return values, or reliance on changed semantics of `Analyzer<I,O>`, `State<I,O>`, `Term`, `Expression`, or `Bindings`.
     - **Debt markers:** investigate `TODO`/`FIXME`/`HACK` only when they identify a reachable latent defect (note `todo: ignore` in analysis_options.yaml).

   **Layer B — Primal/Dart project lens**

   - **Architecture**: Violations of project conventions, misuse of existing abstractions (`Analyzer<I,O>`, `State<I,O>`, `Term`, `Expression`, `Bindings`), circular dependencies, duplicated code that should be shared. Ensure new library functions follow the `NativeFunctionTerm` / `NativeFunctionTermWithArguments` pattern. Verify platform-specific code uses conditional imports (`dart.library.html`) rather than runtime checks.
   - **Performance**: Expensive operations in hot paths (runtime `reduce()`, lexical/syntactic analysis loops), repeated `.reduce()` calls on the same term (reduce once and store), string building with `+` in loops (use `StringBuffer`), unnecessary `List`/`Map` allocations in recursive evaluation, and unbounded recursion without depth guards.
   - **Readability**: Unclear or overly complex code, poorly named functions and variables, missing or misleading comments, hard-to-follow control flow in state machines or expression parsing, overly long functions that should be decomposed.
   - **Style**: Violations of analysis_options.yaml rules (single quotes, trailing commas, const constructors, final locals, return type declarations, null-aware operators), the explicit-types and no-abbreviations rules from CLAUDE.md, naming inconsistencies with existing code, dead code introduced, and hardcoded values that belong in constants or the type system.

   **Per-change interrogation**: For every changed hunk, ask:
   - What empty, null, boundary, huge, malformed, or out-of-order input makes this fail?
   - Which assumption about input, state, ownership, ordering, or environment (native vs. web runtime) can be violated?
   - Can a failure surface as success or leave partial state?
   - Is every acquired resource (stream, sink, subscription, file handle) released on every path?
   - Do caller and callee agree on units, ranges, nullability, indexing, and ownership? Do `Parameter` declarations match `reduce()`'s actual type use?
   - Is every `switch`/enum case and state-machine transition handled?
   - Can untrusted `.prm`/REPL input reach a dangerous sink or unbounded recursion?
   - Does unreachable behavior reveal missing or ineffective shipped behavior?

   **Analysis Guidance**: When looking for issues, focus on changes that:
   - Meaningfully impact the accuracy, performance, security, or maintainability of the code.
   - Are discrete and actionable (not general codebase concerns or combinations of multiple issues).
   - Match the level of rigor present in the rest of the codebase (e.g., don't expect detailed comments and input validation in a repository of one-off scripts).
   - The author would likely fix if made aware.
   - Can be identified without relying on unstated assumptions about the codebase or author's intent.
   - Provably affect other parts of the code (don't speculate that a change may disrupt something — identify the affected code).
   - Are clearly not intentional changes by the original author.

3. **Context Verification**: Before flagging an issue, read the surrounding code to confirm it is a real problem and not handled elsewhere. Minimize false positives. Pay special attention to the compiler pipeline — an apparent issue in one phase may be intentionally delegated to a later phase.

4. **Reporting**: Present the subagent's findings in a Markdown table:
   | File Path | Line # | Severity | Category | Description & Suggested Fix |
   | :--- | :--- | :--- | :--- | :--- |

   Severity levels: **Critical** (will cause bugs/crashes), **Warning** (potential issue or code smell), **Nit** (style/convention).
   If no issues are found, say LGTM and skip the table.
   End with a one-line summary: "X critical, Y warnings, Z nits across N files."

5. **Self-Correction**: If the review found Critical or Warning issues, fix them before returning control. Do NOT re-run the review after fixing. The user will request another review if needed.

6. **Formatting**: Before returning control to the user, run `dart format .` to ensure all code is properly formatted.
