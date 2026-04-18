---
title: Currification
tags:
  - roadmap
  - runtime
sources: []
---

# Currification

**TLDR**: Partial application support allowing functions to be called with fewer arguments than required, returning a new function that expects the remaining arguments, either through automatic currying (`mul(2)`) or placeholder syntax (`add(5, _)`).

The standard library already has higher-order functions such as `list.map`, `list.filter`, and `list.reduce`. Partial application would make them much easier to use with existing multi-argument functions.

**Design notes:**

- Placeholder-based partial application is probably the best fit for Primal's existing syntax.
- It should work for both user-defined and native functions.
- This is one of the first proposals that truly needs closure-like behavior or an equivalent runtime representation.
- If closures are considered too large a step, this can be deferred until local scopes/functions exist.

# Alternative 1: Currification

```primal
double(n) = mul(2) // partial application of mul with 2
```

```primal
main() = double(3) // 6
```

## Alternative 2: Partial Application

Apply some arguments now, get a function that expects the rest:

```
add(a, b) = a + b

addFive() = add(5, _)
main() = addFive()(3)   // returns 8
```
