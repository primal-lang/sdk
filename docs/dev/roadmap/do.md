---
title: Do Blocks
tags:
  - roadmap
  - syntax
sources: []
---

# Do Blocks

**TLDR**: `do ... end` blocks provide sequential evaluation with local bindings, allowing step-by-step computation within a function body where each binding can reference earlier ones, yielding the final expression as the block result.

Primal is expression-oriented, but practical scripting still needs a readable way to sequence I/O and local bindings.

**Design notes:**

- `do ... end` is most useful if it also supports local bindings.
- The block should evaluate top-to-bottom and yield the last expression.
- This overlaps with `where` and any future `let`-like feature; those designs should be coordinated rather than implemented independently.
- This is a larger change than it looks because it introduces nested scope and ordered evaluation as explicit syntax.

`do ... end` should be the main way to write local step-by-step value computation without introducing global names.

#### Syntax

```primal
main() =
do
    xs = [1, 2, 3, 4]
    evens = list.filter(xs, isEven)
    doubled = list.map(evens, double)
    doubled
end
```

Blocks should also support wildcard bindings for sequencing effectful expressions:

```primal
main() = do
            _ = console.writeLn("starting")
            value = console.read()
            value
         end
```

#### Semantics

- A block contains zero or more value bindings followed by one final expression.
- Bindings are sequential.
- Later bindings can use earlier bindings.
- The last expression is the block result.
- Names declared in the block do not escape.
- Local function definitions are not allowed in `do ... end`.
- Destructuring is allowed in block bindings.

# More

**Current Fit:** Medium-Low | **Complexity:** High | **Impact:** High

Allow evaluating expressions in order and returning the last one:

```
main() = do
            console.writeLn("Enter name:")
            name = console.read()
            console.writeLn("Hello, " + name)
            name
         end
```
