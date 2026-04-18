---
title: Expression-Oriented Programming
tags:
  - design
  - expressions
sources:
  - lib/compiler/syntactic/expression.dart
---

# Expression-Oriented Programming

**TLDR**: Everything in Primal is an expression that produces a value. There are no statements, no void returns, and no side-effect-only constructs. This makes code more composable and predictable.

## Expressions vs Statements

In many languages, there is a distinction between expressions (which produce values) and statements (which perform actions but do not produce values). For example, in such languages an `if` statement might not return anything, and you need a separate assignment to capture a result.

Primal eliminates this distinction. Every construct is an expression that evaluates to a value.

## If/Else Always Returns a Value

In Primal, `if`/`else` is an expression, not a statement. It always produces a value:

```
sign(n) = if (n > 0) "positive" else if (n < 0) "negative" else "zero"
```

This function returns a string directly from the conditional. There is no need for intermediate variables or return statements.

You can use the result of `if`/`else` anywhere you would use any other value:

```
// Using if/else inline
greet(name, formal) =
    string.concat(if (formal) "Dear " else "Hi ", name)

// Nesting if/else expressions
classify(n) =
    if (n < 0)
        "negative"
    else
        if (n == 0) "zero" else "positive"
```

## No Void Returns

Every function in Primal returns a value. There is no concept of a "void" function that performs an action without returning anything.

Even functions that perform I/O return meaningful values:

```
// console.print returns the string it printed
main() = console.print("Hello, world!")
```

This design means you can always compose functions and chain operations.

## Let Expressions Produce Values

The `let` expression binds a name to a value and then evaluates another expression. The result is the value of the final expression:

```
circleArea(radius) =
    let pi = 3.14159 in
    let radiusSquared = pow(radius, 2) in
    pi * radiusSquared
```

The entire `let` construct is an expression. Its value is whatever the expression after `in` evaluates to. This allows for clear, readable computation chains.

## Benefits of Expression Orientation

**Composability**: Since everything returns a value, you can freely combine expressions:

```
// Chaining operations naturally
process(data) =
    list.filter(
        list.map(data, transform),
        isValid
    )
```

**No Implicit Behavior**: There are no hidden effects or "do nothing" returns. Every line of code contributes to producing a result.

**Cleaner Conditionals**: Without the statement/expression split, conditionals are more flexible:

```
// The result of if/else can be used directly
max(a, b) = if (a > b) a else b

// Works in any context
doubled = list.map([1, 2, 3], (n) => if (n > 1) n * 2 else n)
```

## Practical Examples

Here are common patterns that benefit from expression orientation:

**Conditional computation**:

```
shipping(subtotal, isPremium) =
    if (isPremium)
        0
    else
        if (subtotal > 100) 5 else 10
```

**Building values conditionally**:

```
formatPrice(price, showCents) =
    string.concat(
        "$",
        if (showCents)
            num.toString(price)
        else
            num.toString(num.floor(price))
    )
```

**Chained transformations with let**:

```
summarize(scores) =
    let sorted = list.sort(scores, num.compare) in
    let count = list.length(sorted) in
    let total = list.reduce(sorted, 0, num.add) in
    let average = total / count in
    {"count": count, "total": total, "average": average}
```

## Thinking in Expressions

When writing Primal code, think of your program as a series of value transformations. Each function takes inputs and produces an output. Each conditional chooses between values. Each `let` binding names an intermediate value on the way to producing a final result.

This mental model leads to code that is:

- Easier to test (clear inputs and outputs)
- Easier to understand (no hidden state changes)
- Easier to compose (values connect naturally)
