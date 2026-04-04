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
