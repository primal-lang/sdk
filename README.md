# Dry 🚱
**Dry** is a declararive, purely functional, esoteric programming language. Although **Dry** is a general purpose language, it's mostly intended to be used as a tool for learning functional programming.

## TODO
* Easy implementation overload name/length
* evaluate -> reduce

* Stop using scope as static
* Accept multiple parameters if, sum, etc
* Allow to overload functions

## Backlog
* Lists and objects
* Higher order functions
* Lambdas
    - ((x, y) => x + y)    
    - lambda(x, y, x + 1)
* Compile to JS
    const add = (a, b) => a + b
* Type inference
* Operators (= + - / * ! & |)
* Imports
* Pattern matching
    - x:xs
* Type declaration (maybe, undefined)
* Currying

## Names
* Dry
* Def
* Fun

## Domains
.io
.dev

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

### Properties

#### First-Class functions
Functions must be treated as first-class citizens, meaning they can:
* Be passed as arguments to other functions
* Returned as values from other functions
* Be assigned to variables

#### Function application
The primary means of computation should be through the application of functions to arguments.

#### Immutability
Variables, once defined, should not change their values. This immutability is crucial to avoid side effects.

#### Pure Functions
Functions should be pure, meaning their output is determined solely by their input values without any observable side effects. This ensures referential transparency, where expressions can be replaced with their values without changing the program's behavior.

#### Anonymous functions
The language should support anonymous functions, often referred to as lambdas, allowing functions to be defined without giving them explicit names.

#### Recursion
Since lambda calculus does not have looping constructs, recursion should be a fundamental means of expressing repetition and iterative processes.

#### Expression oriented
Everything should be an expression that returns a value, rather than statements that perform actions.

#### Lazy evaluation
Expressions are not evaluated until their values are needed. This can improve performance by avoiding unnecessary calculations and allows for the creation of infinite data structures.

#### Pattern matching
Checking a value against a pattern and deconstructing data structures.