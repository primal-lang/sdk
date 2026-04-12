I want to implement a new function called `debug` that takes an expression and a label. The function will evaluate the expression and print its value along with the label if provided.

Example:

```primal
debug(expression, label)
```

This prints this to the console

```
[debug] label: value
```

And returns the value of the expression.

Real life example:

```primal
foo(n) = if (n > 0)
            debug(foo(n - 1), "Calling foo with: " + (n - 1))
         else
            "Finished"

main() = foo(3)
```

In this example, when `main()` is called, it will print the following to the console:

```
[debug] Calling foo with: 2: "Finished"
[debug] Calling foo with: 1: "Finished"
[debug] Calling foo with: 0: "Finished"
```
