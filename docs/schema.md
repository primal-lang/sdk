---
title: Knowledge Base Schema
tags:
  - meta
sources: []
---

# Knowledge Base Schema

**TLDR**: This document defines the structure and conventions for the Primal SDK knowledge base, including page format, wikilinks, and content integrity rules.

## Directory Structure

- **`dev/`** — SDK development knowledge (internal)
  - Audience: SDK contributors
  - **`architecture/`** — Implementation details and design rationale
    - `pipeline/` — Compiler stages (reader, lexical, syntactic, semantic, runtime)
    - `patterns/` — Design patterns (state machine, analyzer)
    - `runtime/` — Runtime system (terms, bindings, native functions)
    - `typing/` — Type system (representations, runtime checking)
    - `error/` — Error handling (hierarchy, propagation)
    - `platform/` — Platform abstraction (CLI vs web)
    - `testing/` — Test infrastructure
  - **`roadmap/`** — Future language features

- **`lang/`** — Language knowledge (user-facing)
  - Audience: Primal users
  - Language overview, reference documentation
  - Design philosophy, core concepts

## Page Format

Every page must have:

1. **YAML frontmatter** at the top:
   ```yaml
   ---
   title: Page Title
   tags:
     - tag1
     - tag2
   sources:
     - lib/path/to/file.dart
   ---
   ```

- `title`: Human-readable title
- `tags`: Freeform categorization tags (multi-line list format)
- `sources`: Paths to source files, relative to repo root (multi-line list format)

**List format**: Always use multi-line YAML lists, never inline arrays like `[a, b]`.

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
