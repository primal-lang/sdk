# Alternative 1

```primal
lambda(x, y, x + y)
```

```primal
lambda(x, y, x + y)(5, 6) // 11
```

# Alternative 2

```primal
{x, y = x + y}
```

```primal
{x, y = x + y}(5, 6) => 11
```

```primal
{x -> x + 1}(5) => 6
```
