---
name: sync-docs
description: Synchronizes documentation in `docs/` with the source of truth in `lib/`, spawning parallel agents per doc file.
---

Synchronize the documentation in `docs/` so it accurately reflects the current implementation in `lib/`. The code is the **source of truth** — documentation must be updated to match it, never the other way around.

## Phase 1: Discovery

Find all doc files that need syncing:

1. Glob all `.md` files under `docs/`
2. Parse YAML frontmatter to extract the `sources:` field
3. **Skip** files where `sources:` is empty or missing — these are index files, design docs, or roadmap pages that don't sync to specific code
4. **Validate** that each `sources:` path exists (file or directory). If a path doesn't exist, report it as a **dead source** error and exclude that doc from syncing

Report discovery results:
```
## Discovery

Found 46 docs with sources.
Skipped 35 docs without sources (index/design/roadmap).

Dead sources (cannot sync):
- docs/lang/reference/oldmodule.md: lib/compiler/library/oldmodule/ does not exist
```

## Phase 2: Staleness Check

For each doc with non-empty `sources:`, determine if it's stale:

1. Get the doc's last commit timestamp: `git log -1 --format=%ct <doc_path>`
2. For each path in `sources:`, get the most recent commit timestamp:
   - If path is a directory, check all files recursively
   - Use `git log -1 --format=%ct <source_path>`
   - For files not in git, fall back to file system mtime
3. **Skip** the doc if all source timestamps are older than the doc timestamp — it's already up to date

Report the staleness check results:
```
## Staleness Check

- docs/lang/reference/list.md: STALE (lib/compiler/library/list/ modified 2024-01-15)
- docs/dev/architecture/pipeline/lexical.md: UP TO DATE
- docs/dev/architecture/pipeline/runtime.md: STALE (lib/compiler/runtime/ modified 2024-01-20)

Syncing 2 stale docs, skipping 1 up-to-date doc.
```

## Phase 3: Parallel Sync

Spawn one agent per stale doc file. All agents run concurrently.

Each agent must:
1. Read its assigned doc file to understand the current documented content and writing style
2. Read all Dart files in the `sources:` paths (files or directories)
3. Compare the documentation against the implementation
4. Update the doc file to reflect the current state of the code

### Sync Rules

- **Add** documentation for any function, class, stage, or behavior that exists in `lib/` but is missing from the doc
- **Update** documentation where the implementation has diverged (renamed parameters, changed signatures, modified behavior, new error cases)
- **Remove** documentation for anything that no longer exists in `lib/`
- **Preserve style**: match the existing tone, structure, heading hierarchy, and formatting conventions of each doc file — do not impose a different style

### Quality Guidelines

- Function signatures must exactly match the implementation (parameter names, order, types)
- Error types and conditions must reflect what the code actually throws
- Do not add speculative documentation for features that do not exist yet
- Do not document internal implementation details that are not relevant to users (private helpers, internal state)
- Keep examples concise and accurate — if an example no longer compiles, fix it

## Phase 4: Validation & Auto-fix

After all sync agents complete, validate all docs and auto-fix issues:

### Structure Checks

1. **Broken wikilinks**: `[[path/page]]` where target doesn't exist
2. **Missing from index**: Pages not listed in their index.md
3. **Dead index entries**: Index entries pointing to non-existent pages
4. **Orphan pages**: Pages with no inbound wikilinks (except index files)
5. **Isolated pages**: Pages with no outbound wikilinks (may be fine for leaf pages)

### Content Checks

6. **Missing frontmatter**: Pages without YAML frontmatter block
7. **Missing sources**: Frontmatter without `sources:` field
8. **Missing tags**: Frontmatter without `tags:` field
9. **Inline arrays**: Frontmatter lists using `[a, b]` instead of multi-line format
10. **Missing TLDR**: No `**TLDR**:` line after title
11. **Empty pages**: Only frontmatter, no body content

### Auto-fix Actions

Fix issues automatically:

- **Missing from index**: Add page to its index.md
- **Dead index entries**: Remove entry from index.md
- **Broken wikilinks**: Create stub page with empty frontmatter template, or remove the link if stub creation fails
- **Missing frontmatter**: Add empty frontmatter template
- **Missing sources**: Add empty `sources:` to frontmatter
- **Missing tags**: Add empty `tags:` to frontmatter
- **Inline arrays**: Convert `field: [a, b]` to multi-line list format

Issues that require manual intervention (report only):

- **Orphan pages**: May need to add inbound links or delete the page
- **Isolated pages**: May be intentional for leaf reference pages
- **Missing TLDR**: Requires writing a summary
- **Empty pages**: Requires writing content

Report results:
```
## Validation

### Auto-fixed

- docs/lang/reference/newmodule.md: Added to docs/lang/index.md
- docs/dev/index.md:15: Removed broken link [[dev/architecture/pipeline/old-page]]
- docs/dev/architecture/new-feature.md: Added missing frontmatter

### Manual Attention Required

- docs/lang/design/laziness.md: Missing TLDR
- docs/dev/architecture/runtime/orphan.md: Orphan page (no inbound links)
```

If no issues are found, report: `Validation passed. All checks passed.`
