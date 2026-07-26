# Context

- For an overview of the Primal language (syntax, typing, runtime), consult `README.md`.
- For details on a specific core function, consult `docs/lang/index.md` and its linked pages.
- For knowledge base structure and conventions, consult `docs/schema.md`.

# Critical Instructions

## Code Style

- **Explicit Types**: Always use explicit type annotations (e.g., `final String name`, not `final name`).
- **No Abbreviations**: Use full words for identifiers (`function`, `argument`, `expression`, `index`, not `fn`, `arg`, `expr`, `idx`).

## Knowledge Base

- When discussing architecture, design patterns, or implementation rationale, run `kb-dev`
- When explaining language design or concepts, run `kb-lang`
- **Two outputs rule**: Every significant explanation should produce both a chat response AND a wiki update
