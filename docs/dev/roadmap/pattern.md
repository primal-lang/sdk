---
title: Pattern Matching
tags: [roadmap, syntax]
sources: []
---

# Pattern Matching

**TLDR**: Pattern matching allows defining multiple function clauses that dispatch based on argument values, enabling concise recursive definitions and conditional logic through structural matching on literals and data shapes.

```primal
factorial(1) = 0
factorial(n) = mul(n, factorial(dec(n)))
```

```primal
length([]) = 0
length(a) = 1 + length(pop(a))
```

```primal
if(true, a, b) = a
if(false, a, b) = b
```
