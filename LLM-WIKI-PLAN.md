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

## Page Conventions

### Filenames

Use slug-based naming (lowercase, hyphens):
- `lazy-evaluation.md` for "Lazy Evaluation"
- `type-classes.md` for "Type Classes"

### Wikilinks

Use `[[page-name]]` for cross-references:
- Links are grep-able: `grep "\[\[lazy" docs/`
- Makes relationships explicit without tooling

### Frontmatter

Each new page should have YAML frontmatter:

```yaml
---
title: Lazy Evaluation
tags: [runtime, performance]
related: [short-circuit-operators, thunks]
sources: [lib/compiler/runtime/lazy_value.dart]
---
```

### TLDR

Every page must start with a **TLDR** (1-3 sentences) immediately after the title. This enables quick scanning without reading full articles.

### Example Page

```markdown
---
title: Lazy Evaluation
tags: [runtime, performance]
related: [short-circuit-operators]
sources: [lib/compiler/runtime/lazy_value.dart, lib/compiler/runtime/thunk.dart]
---

# Lazy Evaluation

**TLDR**: Primal uses lazy evaluation via thunks that wrap unevaluated expressions. Values are computed on first access and cached. This enables short-circuit operators and avoids unnecessary computation.

Primal uses lazy evaluation for [[short-circuit-operators]].
This is implemented using [[thunks]] in the runtime.
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

### Step 2: Create New Files

1. `docs/schema.md` — Knowledge base maintenance instructions:
   - Directory structure (dev/ vs lang/)
   - Page formatting conventions (frontmatter, TLDR, headings)
   - Guidelines for deciding where content belongs
   - Content integrity rules:
     - Never invent information — every claim must trace to conversation, code, or existing docs
     - For gaps, use `[TODO: clarify X]` markers instead of guessing
   - Cross-linking rules:
     - Only create [[wikilinks]] when the target page exists
     - Link when the page title/slug appears naturally in text
     - Do not invent conceptual links that aren't explicitly mentioned
   - Index file guidelines:
     - Each page listed in index.md must have a one-line summary
     - Summaries should be enough to decide if the full page is relevant
     - Update index.md whenever adding/removing pages
2. `docs/dev/index.md` — Dev knowledge base index
3. `docs/lang/index.md` — Language knowledge base index

### Step 3: Create Skills

Create these skill files in `.claude/skills/`:

1. `.claude/skills/kb-dev/SKILL.md`
2. `.claude/skills/kb-lang/SKILL.md`

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

- Update any markdown links in moved files to reflect new paths (e.g., `reference/` → still works since it's relative)

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
3. Run `/sync-docs` → verify it still works with new paths
4. Test wikilink grep: `grep "\[\[" docs/` should find cross-references
5. Check that all index files have correct links
6. Verify existing docs (reference, compiler) still accessible at new paths

## Design Decisions Made

1. **Folder name**: Use existing `docs/` folder, not a new `wiki/` or `knowledge/` folder
2. **No session logging**: This is a knowledge base, not a session log. No `/kb-log` or append-only log file.
3. **Skill prefix**: Use `kb-*` (knowledge base) not `wiki-*`
4. **Reorganize existing docs**: Move existing documentation under `docs/lang/` or `docs/dev/`
5. **Wikilinks**: Use `[[page-name]]` syntax for cross-references (grep-able without tooling)
6. **Slug-based filenames**: Lowercase with hyphens for predictable linking
7. **Content integrity**: No content invention — use `[TODO: ...]` for gaps, trace claims to sources
8. **Mechanical cross-links**: Only link when target exists and is mentioned in text
9. **Source provenance**: Track source files in frontmatter `sources:` field
10. **Two outputs rule**: Every significant explanation produces chat response + wiki update
11. **TLDR requirement**: Every page starts with 1-3 sentence summary for quick scanning
12. **Progressive disclosure**: Index files with one-line summaries enable token-efficient navigation
