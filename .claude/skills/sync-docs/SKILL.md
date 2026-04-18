---
name: sync-docs
description: Synchronizes documentation in `docs/` with the source of truth in `lib/`, spawning parallel agents per doc file.
---

Synchronize the documentation in `docs/` so it accurately reflects the current implementation in `lib/`. The code is the **source of truth** — documentation must be updated to match it, never the other way around.

## Source Mappings

| Doc file                          | Source directory                                     |
| --------------------------------- | ---------------------------------------------------- |
| `docs/lang/reference/<name>.md`   | `lib/compiler/library/<name>/`                       |
| `docs/dev/compiler/reader.md`     | `lib/compiler/reader/`                               |
| `docs/dev/compiler/lexical.md`    | `lib/compiler/lexical/`                              |
| `docs/dev/compiler/syntactic.md`  | `lib/compiler/syntactic/`                            |
| `docs/dev/compiler/semantic.md`   | `lib/compiler/semantic/`, `lib/compiler/lowering/`   |
| `docs/dev/compiler/runtime.md`    | `lib/compiler/runtime/`                              |
| `docs/dev/compiler/models.md`     | `lib/compiler/models/`                               |
| `docs/dev/compiler.md`            | `lib/compiler/compiler.dart` and all compiler stages |
| `docs/dev/example.md`             | All compiler stages (end-to-end trace)               |

## Execution

1. **Spawn parallel agents** — one agent per doc file listed above. All agents run concurrently.

2. **Each agent must**:
   a. Read its assigned doc file to understand the current documented content and writing style
   b. Read all Dart files in the corresponding source directory (see mapping above)
   c. Compare the documentation against the implementation
   d. Update the doc file to reflect the current state of the code

## Sync Rules

- **Add** documentation for any function, class, stage, or behavior that exists in `lib/` but is missing from the doc
- **Update** documentation where the implementation has diverged (renamed parameters, changed signatures, modified behavior, new error cases)
- **Remove** documentation for anything that no longer exists in `lib/`
- **Preserve style**: match the existing tone, structure, heading hierarchy, and formatting conventions of each doc file — do not impose a different style
- **Index files** (`docs/dev/compiler.md`, `docs/lang/reference.md`): ensure every sub-page is listed and no stale links remain. Add entries for new modules; remove entries for deleted modules
- **Example file** (`docs/dev/example.md`): verify that the pipeline stages, data structures, and evaluation steps shown in the walkthrough still match the implementation. Update any that have drifted

## Quality Guidelines

- Function signatures must exactly match the implementation (parameter names, order, types)
- Error types and conditions must reflect what the code actually throws
- Do not add speculative documentation for features that do not exist yet
- Do not document internal implementation details that are not relevant to users (private helpers, internal state)
- Keep examples concise and accurate — if an example no longer compiles, fix it
