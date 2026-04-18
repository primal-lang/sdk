# LLM Wiki Implementation Checklist

This document tracks the implementation progress of the LLM Wiki knowledge base system as described in `LLM-WIKI-PLAN.md`.

---

## Step 1: Move Existing Files

Reorganize existing documentation into the new `docs/dev/` and `docs/lang/` structure.

### 1.1 Create Directory Structure

- [ ] Create `docs/dev/architecture/` directory
- [ ] Create `docs/lang/design/` directory

### 1.2 Move Files to `docs/dev/`

- [ ] Move `docs/example.md` → `docs/dev/example.md`
- [ ] Move `docs/compiler.md` → `docs/dev/compiler.md`
- [ ] Move `docs/compiler/` → `docs/dev/compiler/`
- [ ] Move `docs/roadmap/` → `docs/dev/roadmap/`

### 1.3 Move Files to `docs/lang/`

- [ ] Move `docs/primal.md` → `docs/lang/primal.md`
- [ ] Move `docs/reference.md` → `docs/lang/reference.md`
- [ ] Move `docs/reference/` → `docs/lang/reference/`

---

## Step 2: Retrofit Existing Docs

Add YAML frontmatter and TLDR sections to moved files.

### 2.1 Language Docs (`docs/lang/`)

- [ ] Add frontmatter and TLDR to `docs/lang/primal.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/list.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/map.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/set.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/vector.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/stack.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/queue.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/arithmetic.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/comparison.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/logic.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/operators.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/string.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/json.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/base64.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/hash.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/uuid.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/file.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/directory.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/path.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/environment.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/console.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/timestamp.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/control.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/error.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/debug.md`
- [ ] Add frontmatter and TLDR to `docs/lang/reference/casting.md`

### 2.2 Developer Docs (`docs/dev/`)

- [ ] Add frontmatter and TLDR to `docs/dev/example.md`
- [ ] Add frontmatter and TLDR to `docs/dev/compiler.md`
- [ ] Add frontmatter and TLDR to `docs/dev/compiler/lexical.md`
- [ ] Add frontmatter and TLDR to `docs/dev/compiler/syntactic.md`
- [ ] Add frontmatter and TLDR to `docs/dev/compiler/semantic.md`
- [ ] Add frontmatter and TLDR to `docs/dev/compiler/runtime.md`
- [ ] Add frontmatter and TLDR to `docs/dev/compiler/models.md`
- [ ] Add frontmatter and TLDR to `docs/dev/compiler/reader.md`

### 2.3 Roadmap Docs (`docs/dev/roadmap/`)

- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/destructuring.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/pattern.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/modules.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/tuples.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/enums.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/option.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/try.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/ranges.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/string.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/regex.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/record.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/typing.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/currification.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/inspection.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/http.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/testing.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/transpilation.md`
- [ ] Add frontmatter and TLDR to `docs/dev/roadmap/do.md`

---

## Step 3: Create New Files

### 3.1 Schema File

- [ ] Create `docs/schema.md` with knowledge base conventions

### 3.2 Index Files

- [ ] Create `docs/dev/index.md` (Developer Knowledge Base navigation hub)
- [ ] Create `docs/lang/index.md` (Language Knowledge Base navigation hub)

---

## Step 4: Create Skills

### 4.1 kb-dev Skill

- [ ] Create `.claude/skills/kb-dev/` directory
- [ ] Create `.claude/skills/kb-dev/SKILL.md` with skill definition

### 4.2 kb-lang Skill

- [ ] Create `.claude/skills/kb-lang/` directory
- [ ] Create `.claude/skills/kb-lang/SKILL.md` with skill definition

### 4.3 kb-lint Skill

- [ ] Create `.claude/skills/kb-lint/` directory
- [ ] Create `.claude/skills/kb-lint/SKILL.md` with skill definition

---

## Step 5: Update Existing Files

### 5.1 Update CLAUDE.md

- [ ] Update `#Context` section: `docs/primal.md` → `docs/lang/primal.md`
- [ ] Update `#Context` section: `docs/reference.md` → `docs/lang/reference.md`
- [ ] Add reference to `docs/schema.md` for knowledge base structure
- [ ] Add `## Knowledge Base` section with automatic behavior prompts

### 5.2 Update sync-docs Skill

- [ ] Update `.claude/skills/sync-docs/SKILL.md` source mappings table
- [ ] Update references: `docs/compiler.md` → `docs/dev/compiler.md`
- [ ] Update references: `docs/reference.md` → `docs/lang/reference.md`

### 5.3 Update README.md

- [ ] Check and update any documentation path references in `README.md`

---

## Step 6: Update Internal Links

### 6.1 Fix Cross-References

- [ ] Verify links in `docs/lang/reference.md` to `reference/*.md` still work
- [ ] Verify links in `docs/dev/compiler.md` to `compiler/*.md` still work
- [ ] Find and fix any broken `../primal.md` references
- [ ] Find and fix any broken `../reference.md` references
- [ ] Find and fix any broken `../compiler.md` references

### 6.2 Verification

- [ ] Run `grep -r "\[.*\](.*\.md)" docs/` to find all markdown links
- [ ] Verify no broken references exist

---

## Step 7: Verification

### 7.1 Skill Testing

- [ ] Run `/kb-dev` with test content → verify page created and index updated
- [ ] Run `/kb-lang` with test content → verify page created with proper slug
- [ ] Run `/kb-lint` → verify it detects issues (orphans, broken links, missing frontmatter)

### 7.2 Integration Testing

- [ ] Run `/sync-docs` → verify it works with new paths
- [ ] Test wikilink grep: `grep "\[\[" docs/` should find cross-references
- [ ] Verify all index files have correct links
- [ ] Verify existing docs accessible at new paths

---

## Summary

| Phase | Tasks | Status |
|-------|-------|--------|
| Step 1: Move Files | 7 | Pending |
| Step 2: Retrofit Docs | 46 | Pending |
| Step 3: Create New Files | 3 | Pending |
| Step 4: Create Skills | 6 | Pending |
| Step 5: Update Existing | 7 | Pending |
| Step 6: Fix Links | 7 | Pending |
| Step 7: Verification | 7 | Pending |
| **Total** | **83** | **Pending** |
