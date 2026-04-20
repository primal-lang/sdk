---
name: kb-dev
description: Document developer knowledge in the SDK knowledge base. Use when explaining architecture, design patterns, or implementation rationale.
---

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
