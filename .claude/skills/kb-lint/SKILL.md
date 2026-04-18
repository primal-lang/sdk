---
name: kb-lint
description: Audit knowledge base health and report issues. Checks for orphan pages, broken wikilinks, missing frontmatter, and stale sources.
---

# kb-lint

Audit knowledge base health and report issues.

## Trigger

User explicitly runs `/kb-lint`.

## Checks

### Structure

- **Orphan pages**: Pages with no inbound wikilinks (except index files)
- **Broken wikilinks**: `[[path/page]]` where target doesn't exist
- **Missing from index**: Pages not listed in their index.md
- **Dead index entries**: Index entries pointing to non-existent pages
- **Isolated pages**: Pages with no outbound wikilinks (may be fine for leaf pages)

### Content

- **Missing frontmatter**: Pages without YAML frontmatter block
- **Missing sources**: Frontmatter without `sources:` field
- **Missing tags**: Frontmatter without `tags:` field
- **Missing TLDR**: No `**TLDR**:` line after title
- **Empty pages**: Only frontmatter, no body content

### Freshness

- **Stale sources**: `sources:` files modified after page was last updated
- **Dead sources**: `sources:` files that no longer exist

**Implementation**: Use `git log -1 --format=%ct <file>` to get the last commit timestamp for both the doc page and its source files. Compare timestamps to detect staleness. For files not in git, fall back to file system mtime.

## Output

Report issues grouped by category with file paths and line numbers:

```
## Structure Issues

- docs/dev/architecture/thunks.md: Orphan page (no inbound links)
- docs/dev/index.md:15: Broken link [[dev/nonexistent]]

## Content Issues

- docs/lang/design/laziness.md: Missing TLDR
- docs/dev/compiler/lexical.md: Missing sources in frontmatter

## Freshness Issues

- docs/dev/compiler/runtime.md: Stale source lib/compiler/runtime/evaluator.dart (modified 2024-01-15)
```

## Auto-fix

Run `/kb-lint fix` to automatically fix issues:

- Add missing pages to index.md
- Remove dead wikilinks
- Create stub pages for broken links
- Add empty frontmatter template to pages missing it

Without the `fix` argument, `/kb-lint` only reports issues without modifying files.
