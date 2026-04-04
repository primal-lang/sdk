```primal
factorial(1) = 0
factorial(n) = mul(n, factorial(dec(n)))
```

```primal
length([]) = 0
length(a) = 1 + length(pop(a))
```

```primal
if(true, a, b) = a
if(false, a, b) = b
```
