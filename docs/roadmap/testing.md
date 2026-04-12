# Testing functions

Functions that help to test functions. Ideally used in a test suite to verify the behavior of other functions.

## Function

```primal
assert.equal(foo(), 42, "Message when the test fails")
```

```primal
assert.true(isEven(4), "Expected 4 to be even")
```

```primal
assert.false(isEven(5), "Expected 5 to be odd")
```

```primal
assert.throws(to.number("not a number"), "Expected parsing to fail")
```

```primal
assert.closeTo(actual, expected, delta, errorMessage)
```

```primal
assert.match(string, regex, errorMessage)
```

```primal
assert.contains(element, collection, errorMessage)
```

What other functions could we implement?
