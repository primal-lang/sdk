# Context

- For an overview of the Primal language (syntax, typing, runtime), consult `docs/primal.md`.
- For details on a specific core function, consult `docs/reference.md` and its linked pages.

# Critical Instructions

## Planning

- **Plan & Pause**: Propose a clear, step-by-step plan before making any code changes. Stop after planning and proceed only after I verify.
- **Ambiguity Handling**: If any requirement is ambiguous, risky, or unclear, state your assumptions explicitly and ask for confirmation before proceeding.

## Rules

- **Strict Scope**: Do not add features, refactor, or reorganize beyond what was explicitly requested.
- **Explicit Types**: Always use explicit type annotations for local variables (e.g., `final String name ...` not `final name ...`).
- **No Abbreviations**: Use full words for all identifiers. Avoid abbreviations like `fn`, `arg`, `expr`, `idx`, `loc`, `ref`, `env`, `dir`, `dest`, `op`, `exp`, etc. Use `function`, `argument`, `expression`, `index`, `location`, `reference`, `environment`, `directory`, `destination`, `operator`, `result`, etc.
- **Code Review**: After completing code changes, run `delta-review` before responding.
