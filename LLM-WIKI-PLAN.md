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
   - Existing docs moved here (primal.md, reference/, compiler/, roadmap/)
   - Language design philosophy
   - Core concepts explained

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
    design/                   # Language design philosophy (new)
    concepts/                 # Core concepts explained (new)
```

## Skills to Create

### Dev Knowledge Base Skills

#### `/kb-architecture` — Document Architecture and Design Rationale

- Creates `docs/dev/architecture/<slug>.md`
- Covers both how something works and why it was designed that way
- Updates `docs/dev/index.md`

### Lang Knowledge Base Skills

#### `/kb-concept` — Document a Language Concept

- Creates `docs/lang/concepts/<slug>.md`
- User-facing tone, with examples
- Updates `docs/lang/index.md`

#### `/kb-design` — Document Language Design Philosophy

- Creates `docs/lang/design/<slug>.md`
- Updates `docs/lang/index.md`

## Page Template

Each new page should have YAML frontmatter:

```yaml
---
title: <title>
tags: [tag1, tag2]
related: [other-page.md]
---
```

## Implementation Steps

### Step 1: Move Existing Files

```bash
# Create new structure
mkdir -p docs/dev/architecture
mkdir -p docs/lang/{design,concepts}

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

1. `docs/schema.md` — Knowledge base maintenance instructions
2. `docs/dev/index.md` — Dev knowledge base index
3. `docs/lang/index.md` — Language knowledge base index

### Step 3: Create Skills

Create these skill files in `.claude/skills/`:

1. `.claude/skills/kb-architecture/SKILL.md`
2. `.claude/skills/kb-concept/SKILL.md`
3. `.claude/skills/kb-design/SKILL.md`

### Step 4: Update Existing Files

1. Update `CLAUDE.md`:
   - Change doc paths from `docs/` to `docs/lang/`
   - Add Knowledge Base section with automatic behavior prompts

2. Update `.claude/skills/sync-docs/SKILL.md`:
   - Update reference paths from `docs/reference/` to `docs/lang/reference/`
   - Update compiler paths from `docs/compiler/` to `docs/dev/compiler/`
   - Update example path from `docs/example.md` to `docs/dev/example.md`

3. Update `README.md` if it references docs paths

### Step 5: Update Internal Links

- Update any markdown links in moved files to reflect new paths (e.g., `reference/` → still works since it's relative)

## Automatic Behavior

Add to `CLAUDE.md`:

```markdown
## Knowledge Base

- When discussing architecture, design patterns, or rationale, run `/kb-architecture` to persist the knowledge
- When explaining a language concept, run `/kb-concept` to create user-facing documentation
```

## Verification

After implementation:

1. Run `/kb-decision` with a test decision → verify page created and `docs/dev/index.md` updated
2. Run `/kb-concept` with a test concept → verify page created in `docs/lang/concepts/`
3. Run `/sync-docs` → verify it still works with new paths
4. Check that all index files have correct links
5. Verify existing docs (reference, compiler) still accessible at new paths

## Design Decisions Made

1. **Folder name**: Use existing `docs/` folder, not a new `wiki/` or `knowledge/` folder
2. **No session logging**: This is a knowledge base, not a session log. No `/kb-log` or append-only log file.
3. **Skill prefix**: Use `kb-*` (knowledge base) not `wiki-*`
4. **Reorganize existing docs**: Move existing documentation under `docs/lang/` rather than keeping them at root
