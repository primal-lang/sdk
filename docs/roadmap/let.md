- Constraint: none of the variables in the expression can be named the same as any of the parameters of the function. is that a valid constraint?
- What other things should we check?
  - not declaring one variable more than once?

Examples:

```primal
foo(n) = let
            x = bar(n)
         in
            x + 1
```

Let expression can be chained:

```primal
foo(n) = let
             x = bar(n)
         in
             let
                 y = test(n)
             in
                 x + y
```

Let expressions can declare more than one variable:

```primal
foo(n) = let
             x = bar(n)
             y = test(n)
         in
             x + y
```

Declared variables can use previously declared variables:

```primal
foo(a, b) = let
                x = a + b
                y = x * 2
            in
                y * 2
```

The expression after "in" can be any expression, including an "if":

```primal
foo(a, b) = let
                x = process(a, b)
            in
                if (result.isSuccess(x))
                    console.write('Success: ' + result.get(x))
                else
                    console.write('Failure: ' + result.get(x))
```

Declared variables can be any expression, including an "if":

```primal
frequency(list, result) =
    if (list.isEmpty(list))
        result
    else
        let
            first = list.first(list)
            tail = list.tail(list)
        in
            let
                count = if (map.containsKey(result, first))
                            result[first] + 1
                        else
                            1
            in
                frequency(tail, map.set(result, first, count))
```
