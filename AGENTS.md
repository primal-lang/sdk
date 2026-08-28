# Context

- For an overview of the Primal language (syntax, typing, runtime), consult `README.md`.
- For details on a specific core function, consult `docs/lang/index.md` and its linked pages.
- For knowledge base structure and conventions, consult `docs/schema.md`.

# Critical Instructions

## Code Style

- **Explicit Types**: Always use explicit type annotations (e.g., `final String name`, not `final name`).
- **No Abbreviations**: Use full words for identifiers (`function`, `argument`, `expression`, `index`, not `fn`, `arg`, `expr`, `idx`).

## Verification

Run these after a change. The quiet flags are deliberate: command output is re-sent to the agent on every later turn, so a chatty run is a tax for the rest of the session.

- **Analyze**: `dart analyze`
- **Format**: `dart format lib test`
- **Test**: `dart test -r failures-only [path]` — pass a path or `--tags <tag>` (see `dart_test.yaml`) while iterating; the full suite takes about 7 minutes
- **Delegate wide runs**: hand full-suite and tag-wide runs to the `test-runner` subagent, which reports only the failures. A broad break costs about 200 characters per failing test and there is no `--fail-fast`, so a regression in shared compiler or runtime code can still flood the session
- **Keep `-r failures-only`**: the default reporter prints a line per test update, so a green full suite costs 1,068,918 characters (10,472 lines) instead of 26. Failures still print the message, expectation, file, line and stack frame, and the exit code is unchanged
- **No `print()` in tests**: `failures-only` still shows output from passing tests, and that is what reintroduces the noise. Route runtime console writes through the helpers in `test/helpers/`
- **Everything else is already quiet**: `dart pub get`, `dart analyze`, `dart format` and both `dart compile` targets each print under 150 characters; they need no flags

## Knowledge Base

- When discussing architecture, design patterns, or implementation rationale, run `kb-dev`
- When explaining language design or concepts, run `kb-lang`
- **Two outputs rule**: Every significant explanation should produce both a chat response AND a wiki update
