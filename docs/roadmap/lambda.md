i want to implement lambda functions into the language.

what are the pros and cons of each of these alternatives?

# Alternative 1: Using parentheses

```primal
(x, y, x + y) // param1, param2, ..., body
```

```primal
(x, y, x + y)(5, 6) // 11
```

# Alternative 2: Using braces

```primal
{x, y = x + y} // param1, param2, ..., body
```

Using `=`

```primal
{x, y = x + y}(5, 6) => 11
```

Using `->`

```primal
{x, y -> x + y}(5, 6) => 11
```

# Alternative 3: Using `\` to indicate the beginning of a lambda function

```primal
\x y -> x + y
```

```primal
(\x y -> x + y)(5, 6) => 11
```

# Alternative 4: Using `->` with parentheses

```primal
(x, y) -> x + y
```

```primal
((x, y) -> x + y)(5, 6) => 11
```

Questions:

- should we surround it with parentheses, braces, or nothing?
- should we use a special symbol to separate parameters from the body (e.g., `->`, `=`, `,`), or just rely on the position of the parameters and body?
- Do you have other alternatives?
- Which one you think it's the best for Primal and why?
