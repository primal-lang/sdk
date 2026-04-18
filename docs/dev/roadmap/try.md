---
title: Try Expression
tags: [roadmap, error-handling]
sources: []
---

# Try Expression

**TLDR**: Enhanced try/catch syntax for error handling, allowing pattern matching on error types and optional error values in `error.throw`, with potential integration into let-bindings for inline error checking.

Make second parameter of `error.throw` optional to be able to do `error.throw(-1)`

```primal
try
    exp
catch "test"
    exp1
catch 42
    exp2
....
```

```primal
try(
    exp,
    ErrorType1, exp1,
    ErrorType2, exp2,
    ....
)
```

Can it be achieved with "let"?

```primal
let
    result = foo()
in
    if (result is Error)
        "Failure"
    else
        "Success"
```
