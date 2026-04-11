i want to implement lambda functions into the language.

what are the pros and cons of each of these alternatives?

# Alternative 1

```primal
(x, y, x + y) // param1, param2, ..., body
```

```primal
(x, y, x + y)(5, 6) // 11
```

# Alternative 2

```primal
{x, y = x + y} // param1, param2 = default_value, ..., body
```

```primal
{x, y = x + y}(5, 6) => 11
```

```primal
{x -> x + 1}(5) => 6
```

# Alternative 3

```primal
\x y -> x + y
```

```primal
(\x y -> x + y)(5, 6) => 11
```

# Alternative 4

```primal
(x, y) -> x + y
```

```primal
((x, y) -> x + y)(5, 6) => 11
```
