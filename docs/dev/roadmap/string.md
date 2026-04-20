---
title: String Enhancements
tags:
  - roadmap
  - stdlib
sources: []
---

# String Enhancements

**TLDR**: Extended string syntax including template literals with interpolation (`` `Hello, ${name}!` ``), multiline strings preserving line breaks, and raw strings (`r"C:\path"`) that disable escape processing for regexes and file paths.

Primal already has solid string escape handling. Extending the lexer to support raw and multiline forms would provide immediate value for scripts, regexes, JSON snippets, and embedded text.

**Design notes:**

- Indentation trimming rules should be explicit.
- Raw strings should disable escape processing entirely.
- Triple-quoted strings should preserve line breaks naturally.
- This is a very good near-term feature because the value is high and the scope is contained.

# String interpolation

## Alternative 1: JavaScript (template literals)

```primal
greeting(name) = `Hello, ${name}!`
```

# Multiline strings

```primal
greeting(name) = `Line 1
Line 2`
```

# Raw strings

```primal
path() = r"C:\Users\name"
pattern() = r"\d+\.\d+"
```
