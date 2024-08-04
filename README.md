# Primal

## TODO
* "add" as alias of "sum"
* Function isInfinite
* Fix: foo(n,) = mul(n, 2)

* Stop using scope as static
* Accept multiple parameters if, sum, etc

## Lambda Calculus

### Binding
Binding refers to the association of a variable with a function's parameter. When a variable is bound in an expression, it means the variable is defined locally within that function or lambda abstraction.

Example:
In f(x) = x + 1, the variable x is bound. It means that x is a placeholder for any input value that the function will operate on.

### Substitution
Substitution is the process of replacing a variable in an expression with another expression.

Example:
Given f(x) = x + 1 and the input 2, substitution involves replacing the bound variable x with 2 in the body of the function.

### Application
Application is the process of applying a function to an argument. In lambda calculus, function application is written by juxtaposing two expressions.

### Beta reduction
Beta reduction is the process of applying a function to an argument and simplifying the expression by substituting the argument for the bound variable in the function's body.