---
name: kb-lang
description: Document language knowledge in the user-facing knowledge base. Use when explaining language design or concepts to users.
---

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
