- Constraint: none of the variables in the expression can be named the same as any of the parameters of the function
- For each expression in the let block, perform the following steps:
  - Resolve the expression using the current context
  - Add the resolved variable to the context
- Resolve the expression in the "in" part of the let expression using the updated context. That's the result of the "let expression"

Examples:

```primal
foo(n) = let
            x = bar(n)
         in
             calculate(x, x + 1)
```

```primal
foo(n) = let
             x = bar(n)
         in
             let
                 y = test(n)
             in
                 calculate(x, x + 1, y, y + 1)
```

```primal
foo(n) = let
             x = bar(n)
             y = test(n)
         in
             calculate(x, x + 1, y, y + 1)
```

```primal
foo(a, b) = let
                x = a + b
                y = x * 2
            in
                num.pow(y, 2)
```

```primal
foo(a, b) = let
                x = process(a, b)
            in
                if (result.isSuccess(x))
                    console.write('Success: ' + result.get(x))
                else
                    console.write('Failure: ' + result.get(x))
```

```primal
frequency(list) = frequency.helper(list, {})

frequency.helper(list, result) =
    if (list.isEmpty(list))
        result
    else
        let
            first = list.first(list)
            tail = list.tail(list)
        in
            let count = if (map.containsKey(result, first))
                            result[first] + 1
                        else
                            1
            in
                frequency.helper(tail, map.set(result, first, count))
```
