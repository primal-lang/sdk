# LLM Wiki Implementation Plan

This document captures the plan for implementing an LLM-maintained knowledge base for the Primal SDK project. It is designed to be read by a future Claude session to continue implementation.

## Background: The LLM Wiki Pattern

Instead of using RAG (retrieving and re-synthesizing documents on every query), the LLM incrementally builds and maintains a **persistent knowledge base** — a structured collection of interlinked markdown files that compounds knowledge over time.

**Key insight**: Every time a new Claude session starts, there is zero memory of past investigations, design discussions, and rationale. The knowledge base captures this so it persists across sessions.

**Roles**:

- Human: Curator, decision-maker, source provider
- Claude: Knowledge base maintainer, synthesizer, bookkeeper
- The wiki: Persistent knowledge that survives across sessions

## Current State

The project already has:

- `CLAUDE.md` — instructions for Claude behavior (equivalent to the "schema" in LLM Wiki)
- `docs/` — existing documentation (reference, compiler, roadmap)
- `.claude/skills/` — automation skills like `/sync-docs`, `/generate-changelog`
- `CHANGELOG.md` — chronological record of changes

What's missing:

- No persistent capture of design rationale, architecture decisions
- No cross-linked entity pages
- Knowledge from sessions disappears

## Chosen Approach: Structured

Two separate knowledge bases within `docs/`:

1. **`docs/dev/`** — SDK development knowledge (internal)
   - Architecture documentation (patterns, implementation, and rationale)

2. **`docs/lang/`** — Language knowledge (user-facing)
   - Existing docs (primal.md, reference/)
   - Language design philosophy and core concepts

## Target Directory Structure

```
docs/
  schema.md                   # Instructions for knowledge base maintenance

  dev/                        # SDK development knowledge (internal)
    index.md                  # Navigation hub
    example.md                # ← moved from docs/example.md (compiler walkthrough)
    compiler.md               # ← moved from docs/compiler.md
    compiler/                 # ← moved from docs/compiler/
    roadmap/                  # ← moved from docs/roadmap/
    architecture/             # Design patterns, implementation details, and rationale (lazy evaluation, type classes, immutability, etc.)

  lang/                       # Language knowledge (user-facing)
    index.md                  # Navigation hub
    primal.md                 # ← moved from docs/primal.md
    reference.md              # ← moved from docs/reference.md
    reference/                # ← moved from docs/reference/
    design/                   # Language design philosophy and core concepts (new)
```

## Skills to Create

### Dev Knowledge Base Skills

#### `/kb-dev` — Document Developer Knowledge

- Creates pages in `docs/dev/` (architecture/, compiler/, or root level as appropriate)
- Covers implementation details, design patterns, and rationale
- Updates `docs/dev/index.md`

### Lang Knowledge Base Skills

#### `/kb-lang` — Document Language Knowledge

- Creates pages in `docs/lang/` (design/, reference/, or root level as appropriate)
- Covers design philosophy, concepts, and user-facing documentation
- User-facing tone, with examples
- Updates `docs/lang/index.md`

### Maintenance Skills

#### `/kb-lint` — Wiki Health Auditor

**Structure checks:**

- Orphan pages (no inbound [[wikilinks]])
- Broken [[wikilinks]] (target page doesn't exist)
- Pages not listed in index.md
- Index entries pointing to non-existent pages
- No outbound links (isolated page)
- Duplicate/similar titles

**Content checks:**

- Missing `sources:` in frontmatter
- Missing `tags:` in frontmatter
- Missing TLDR section
- Empty pages (only frontmatter, no content)

**Freshness checks:**

- Stale sources (`sources:` files modified since page was written)
- Dead sources (`sources:` files that no longer exist)

**Actions:**

- Reports all issues with file paths and line numbers
- Optionally auto-fixes: create stubs, add to index, remove dead links

## Page Conventions

### Filenames

Use slug-based naming (lowercase, hyphens):

- `lazy-evaluation.md` for "Lazy Evaluation"
- `type-classes.md` for "Type Classes"

### Wikilinks

Use `[[path/page-name]]` for cross-references with explicit paths:

- `[[dev/lazy-evaluation]]` — links to `docs/dev/lazy-evaluation.md`
- `[[lang/reference/map]]` — links to `docs/lang/reference/map.md`
- `[[dev/compiler/lexical]]` — links to `docs/dev/compiler/lexical.md`

Path is relative to `docs/` and excludes the `.md` extension. This avoids ambiguity when pages have the same name in different directories.

Links are grep-able: `grep "\[\[dev/lazy" docs/`

### Frontmatter

Each page should have YAML frontmatter:

```yaml
---
title: Lazy Evaluation
tags: [runtime, performance]
sources: [lib/compiler/runtime/lazy_value.dart]
---
```

- **title**: Human-readable page title
- **tags**: Freeform tags for categorization
- **sources**: Paths to source files, relative to repo root (not `docs/`)

### TLDR

Every page must start with a **TLDR** (1-3 sentences) immediately after the title. This enables quick scanning without reading full articles.

### Example Page

```markdown
---
title: Lazy Evaluation
tags: [runtime, performance]
sources: [lib/compiler/runtime/lazy_value.dart, lib/compiler/runtime/thunk.dart]
---

# Lazy Evaluation

**TLDR**: Primal uses lazy evaluation via thunks that wrap unevaluated expressions. Values are computed on first access and cached. This enables short-circuit operators and avoids unnecessary computation.

Primal uses lazy evaluation for [[lang/design/short-circuit-operators]].
This is implemented using [[dev/architecture/thunks]] in the runtime.
```

## Implementation Steps

### Step 1: Move Existing Files

```bash
# Create new structure
mkdir -p docs/dev/architecture
mkdir -p docs/lang/design

# Move to dev/
mv docs/example.md docs/dev/
mv docs/compiler.md docs/dev/
mv docs/compiler/ docs/dev/
mv docs/roadmap/ docs/dev/

# Move to lang/
mv docs/primal.md docs/lang/
mv docs/reference.md docs/lang/
mv docs/reference/ docs/lang/
```

### Step 1b: Retrofit Existing Docs

Add frontmatter and TLDR to moved files that lack them:

**Files to retrofit:**

- `docs/lang/primal.md` — add frontmatter with `sources: []` (user-facing overview)
- `docs/lang/reference.md` — add frontmatter with `sources: [lib/core/]`
- `docs/lang/reference/*.md` — add frontmatter with sources pointing to corresponding `lib/core/` files
- `docs/dev/compiler.md` — add frontmatter with `sources: [lib/compiler/]`
- `docs/dev/compiler/*.md` — add frontmatter with sources pointing to corresponding compiler files
- `docs/dev/example.md` — add frontmatter with `sources: []`

**Frontmatter template for existing docs:**

```yaml
---
title: <Title from first heading>
tags: [<infer from content>]
sources: [<path to source files if applicable>]
---
```

**TLDR policy for existing docs:**

- Add TLDR after the title heading if missing
- Extract from existing content or write a 1-3 sentence summary
- Do not rewrite entire documents — only add frontmatter and TLDR

### Step 2: Create New Files

#### 2.1 `docs/schema.md`

# Knowledge Base Schema

This document defines the structure and conventions for the Primal SDK knowledge base.

## Directory Structure

- **`dev/`** — SDK development knowledge (internal)
  - Architecture patterns, implementation details, design rationale
  - Compiler internals, roadmap items
  - Audience: SDK contributors

- **`lang/`** — Language knowledge (user-facing)
  - Language overview, reference documentation
  - Design philosophy, core concepts
  - Audience: Primal users

## Page Format

Every page must have:

1. **YAML frontmatter** at the top:
   ```yaml
   ---
   title: Page Title
   tags: [tag1, tag2]
   sources: [lib/path/to/file.dart]
   ---
   ```

- `title`: Human-readable title
- `tags`: Freeform categorization tags
- `sources`: Paths to source files, relative to repo root (not `docs/`)

2. **Title heading** (`# Page Title`) matching the frontmatter title

3. **TLDR** (1-3 sentences) immediately after the title, in bold: `**TLDR**: ...`

4. **Body content** with sections as needed

## Wikilinks

Use explicit paths for cross-references: `[[path/page-name]]`

- Path is relative to `docs/`, without `.md` extension
- Examples: `[[dev/lazy-evaluation]]`, `[[lang/reference/map]]`

**Rules:**

- Only create wikilinks when the target page exists
- Link when the page title/slug appears naturally in text
- Do not invent conceptual links that aren't explicitly mentioned

## Content Integrity

- Never invent information — every claim must trace to conversation, code, or existing docs
- For gaps, use `[TODO: clarify X]` markers instead of guessing
- Keep `sources:` field accurate — update when source files change

## Index Files

Each knowledge base has an `index.md` that serves as a navigation hub:

- List every page in the knowledge base
- Include a one-line summary for each page
- Summaries should be enough to decide if the full page is relevant
- Update index.md whenever adding/removing pages

## Filenames

Use slug-based naming (lowercase, hyphens):

- `lazy-evaluation.md` for "Lazy Evaluation"
- `type-classes.md` for "Type Classes"

#### 2.2 `docs/dev/index.md`

```markdown
---
title: Developer Knowledge Base
tags: [index]
sources: []
---

# Developer Knowledge Base

**TLDR**: Internal documentation for SDK contributors covering architecture, compiler internals, and design rationale.

## Compiler

- [[dev/compiler]] — Compiler pipeline overview
- [[dev/compiler/lexical]] — Lexical analysis (tokenization)
- [[dev/compiler/syntactic]] — Syntactic analysis (parsing)
- [[dev/compiler/semantic]] — Semantic analysis (type checking, resolution)
- [[dev/compiler/runtime]] — Runtime system (evaluation, values)
- [[dev/compiler/models]] — Data models (AST nodes, types)
- [[dev/compiler/reader]] — Source file reading

## Architecture

_No pages yet. Use `/kb-dev` to document architecture decisions._

## Roadmap

- [[dev/roadmap/destructuring]] — Destructuring syntax
- [[dev/roadmap/pattern]] — Pattern matching
- [[dev/roadmap/modules]] — Module system
- [[dev/roadmap/tuples]] — Tuple types
- [[dev/roadmap/enums]] — Enum types
- [[dev/roadmap/option]] — Option type
- [[dev/roadmap/try]] — Try/catch expressions
- [[dev/roadmap/ranges]] — Range syntax
- [[dev/roadmap/string]] — String improvements
- [[dev/roadmap/regex]] — Regular expressions
- [[dev/roadmap/record]] — Record types
- [[dev/roadmap/typing]] — Type system enhancements
- [[dev/roadmap/currification]] — Automatic currying
- [[dev/roadmap/inspection]] — Runtime inspection
- [[dev/roadmap/http]] — HTTP client
- [[dev/roadmap/testing]] — Testing framework
- [[dev/roadmap/transpilation]] — Transpilation targets
- [[dev/roadmap/do]] — Do notation

## Examples

- [[dev/example]] — Compiler walkthrough with sample program
```

#### 2.3 `docs/lang/index.md`

```markdown
---
title: Language Knowledge Base
tags: [index]
sources: []
---

# Language Knowledge Base

**TLDR**: User-facing documentation for the Primal programming language.

## Overview

- [[lang/primal]] — Language overview, philosophy, and getting started

## Reference

- [[lang/reference]] — Core library reference index
- [[lang/reference/map]] — Map operations
- [[lang/reference/hash]] — Hashing functions
- [[lang/reference/json]] — JSON encoding/decoding
- [[lang/reference/file]] — File operations
- [[lang/reference/directory]] — Directory operations
- [[lang/reference/environment]] — Environment variables
- [[lang/reference/base64]] — Base64 encoding/decoding
- [[lang/reference/error]] — Error handling

## Design

_No pages yet. Use `/kb-lang` to document language design concepts._
```

### Step 3: Create Skills

#### 3.1 `.claude/skills/kb-dev/SKILL.md`

```markdown
# kb-dev

Document developer knowledge in the SDK knowledge base.

## Trigger

User explicitly runs `/kb-dev`, or after explaining architecture, design patterns, or implementation rationale.

## Process

1. **Determine content**: Identify the topic to document from:
   - The current conversation (design discussion, architecture explanation)
   - User-provided topic or question

2. **Check existing pages**: Search `docs/dev/` for related pages to avoid duplication.

3. **Choose location**:
   - `docs/dev/architecture/` — Design patterns, implementation rationale
   - `docs/dev/compiler/` — Compiler-specific documentation
   - `docs/dev/` — General SDK development topics

4. **Create or update page**:
   - Use slug-based filename: `lazy-evaluation.md`
   - Include frontmatter with `title`, `tags`, `sources`
   - Write TLDR (1-3 sentences)
   - Use wikilinks with explicit paths: `[[dev/architecture/thunks]]`
   - Only link to pages that exist

5. **Update index**: Add entry to `docs/dev/index.md` with one-line summary.

6. **Verify**: Confirm page is accessible and wikilinks resolve.

## Content Rules

- Never invent information — trace every claim to conversation, code, or existing docs
- For gaps, use `[TODO: clarify X]` markers
- Keep technical but accessible to SDK contributors
```

#### 3.2 `.claude/skills/kb-lang/SKILL.md`

```markdown
# kb-lang

Document language knowledge in the user-facing knowledge base.

## Trigger

User explicitly runs `/kb-lang`, or after explaining language design or concepts.

## Process

1. **Determine content**: Identify the topic to document from:
   - The current conversation (language design, concept explanation)
   - User-provided topic or question

2. **Check existing pages**: Search `docs/lang/` for related pages to avoid duplication.

3. **Choose location**:
   - `docs/lang/design/` — Language design philosophy, core concepts
   - `docs/lang/reference/` — Core library function documentation
   - `docs/lang/` — General language topics

4. **Create or update page**:
   - Use slug-based filename: `short-circuit-operators.md`
   - Include frontmatter with `title`, `tags`, `sources`
   - Write TLDR (1-3 sentences)
   - Use wikilinks with explicit paths: `[[lang/design/laziness]]`
   - Only link to pages that exist

5. **Update index**: Add entry to `docs/lang/index.md` with one-line summary.

6. **Verify**: Confirm page is accessible and wikilinks resolve.

## Content Rules

- Never invent information — trace every claim to conversation, code, or existing docs
- For gaps, use `[TODO: clarify X]` markers
- User-facing tone with practical examples
- Assume reader is a Primal user, not SDK contributor
```

#### 3.3 `.claude/skills/kb-lint/SKILL.md`

```markdown
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

## Auto-fix (optional)

If user requests fixes:

- Add missing pages to index.md
- Remove dead wikilinks
- Create stub pages for broken links
- Add empty frontmatter template to pages missing it

### Step 4: Update Existing Files

1. Update `CLAUDE.md`:
   - Update #Context section paths:
     - `docs/primal.md` → `docs/lang/primal.md`
     - `docs/reference.md` → `docs/lang/reference.md`
   - Add reference to `docs/schema.md` for knowledge base structure
   - Add Knowledge Base section with automatic behavior prompts

2. Update `.claude/skills/sync-docs/SKILL.md`:
   - Update reference paths from `docs/reference/` to `docs/lang/reference/`
   - Update compiler paths from `docs/compiler/` to `docs/dev/compiler/`
   - Update example path from `docs/example.md` to `docs/dev/example.md`

3. Update `README.md` if it references docs paths

### Step 5: Update Internal Links

Most relative links will continue to work after the move. Verify and fix these specific cases:

**In `docs/lang/reference.md`:**

- Links to `reference/*.md` → should work (relative path preserved)

**In `docs/dev/compiler.md`:**

- Links to `compiler/*.md` → should work (relative path preserved)

**In any file linking to root-level docs:**

- `../primal.md` → `../lang/primal.md`
- `../reference.md` → `../lang/reference.md`
- `../compiler.md` → `../dev/compiler.md`

**Verification:**

```bash
# Find all markdown links and check for broken references
grep -r "\[.*\](.*\.md)" docs/ | grep -v node_modules
```

## Automatic Behavior

Add to `CLAUDE.md` under `# Critical Instructions`:

```markdown
## Knowledge Base

- When discussing architecture, design patterns, or implementation rationale, run `/kb-dev`
- When explaining language design or concepts, run `/kb-lang`
- **Two outputs rule**: Every significant explanation should produce both a chat response AND a wiki update
```

## Verification

After implementation:

1. Run `/kb-dev` with test content → verify page created with wikilinks and `docs/dev/index.md` updated
2. Run `/kb-lang` with test content → verify page created in `docs/lang/` with proper slug filename
3. Run `/kb-lint` → verify it detects orphan pages, broken links, missing sources/TLDR
4. Run `/sync-docs` → verify it still works with new paths
5. Test wikilink grep: `grep "\[\[" docs/` should find cross-references
6. Check that all index files have correct links
7. Verify existing docs (reference, compiler) still accessible at new paths

## Design Decisions Made

1. **Folder name**: Use existing `docs/` folder, not a new `wiki/` or `knowledge/` folder
2. **No session logging**: This is a knowledge base, not a session log. No `/kb-log` or append-only log file.
3. **Skill prefix**: Use `kb-*` (knowledge base) not `wiki-*`
4. **Reorganize existing docs**: Move existing documentation under `docs/lang/` or `docs/dev/`
5. **Wikilinks with explicit paths**: Use `[[path/page-name]]` syntax (e.g., `[[dev/lazy-evaluation]]`) to avoid ambiguity between directories
6. **Slug-based filenames**: Lowercase with hyphens for predictable linking
7. **Content integrity**: No content invention — use `[TODO: ...]` for gaps, trace claims to sources
8. **Mechanical cross-links**: Only link when target exists and is mentioned in text
9. **Source provenance**: Track source files in frontmatter `sources:` field (paths relative to repo root)
10. **Two outputs rule**: Every significant explanation produces chat response + wiki update
11. **TLDR requirement**: Every page starts with 1-3 sentence summary for quick scanning
12. **Progressive disclosure**: Index files with one-line summaries enable token-efficient navigation
13. **Wiki linting**: `/kb-lint` skill audits for orphans, broken links, missing sources/TLDR
14. **No `related:` field**: Wikilinks in body text are sufficient for relationships; frontmatter only has `title`, `tags`, `sources`
15. **Retrofit existing docs**: Moved files get frontmatter and TLDR added (minimal changes, no rewrites)
