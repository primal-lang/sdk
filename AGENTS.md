# Context

- For an overview of the Primal language (syntax, typing, runtime), consult `docs/primal.md`.
- For details on a specific core function, consult `docs/reference.md` and its linked pages.

# Critical Instructions

## Planning

- **Plan & Pause**: Propose a clear, step-by-step plan before making any code changes. Define success criteria for each step. Stop after planning and proceed only after I verify.
- **Surface Confusion**: If any requirement is ambiguous, risky, or unclear, stop. State your assumptions explicitly. If multiple interpretations exist, present them, don't pick silently. Ask for confirmation before proceeding.
- **Push Back**: If a simpler approach exists, say so. Challenge complexity when warranted.

## Implementation

### Simplicity

Minimum code that solves the problem. Nothing speculative.

- No features, abstractions, or "flexibility" beyond what was asked.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

### Surgical Changes

Touch only what you must. Clean up only your own mess.

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated issues, mention them, don't fix them.
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: every changed line should trace directly to the request.

### Code Style

- **Explicit Types**: Always use explicit type annotations (e.g., `final String name`, not `final name`).
- **No Abbreviations**: Use full words for identifiers (`function`, `argument`, `expression`, `index`, not `fn`, `arg`, `expr`, `idx`).

## Verification

After completing code changes, run `delta-review` before responding.
