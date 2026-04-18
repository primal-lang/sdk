---
title: Knowledge Base Schema
tags: [meta]
sources: []
---

# Knowledge Base Schema

**TLDR**: This document defines the structure and conventions for the Primal SDK knowledge base, including page format, wikilinks, and content integrity rules.

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
