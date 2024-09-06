<p align="center">
  <a href="https://primal-lang.org"><img src="https://primal-lang.org/img/rounded.png" alt="Primal" height="170"></a>

<p align="center">
<a href="https://github.com/primal-lang/sdk/blob/main/LICENSE.md" target="_blank"><img height=20 src="https://img.shields.io/badge/license-MIT-green.svg" /></a>
<a href="https://github.com/primal-lang/sdk/releases/tag/v0.3.0"><img src="https://img.shields.io/badge/Latest-0.3.0-blue" /></a>
</p>

# Primal

- [Overview](#overview)
- [Goal](#goal)
- [Technical envelope](#technical-envelope)
- [Philosophy](#philosophy)
- [Syntax](#syntax)
- [Main function](#main-function)
- [Typing system](#typing-system)
- [Runtime](#runtime)

## Overview

**Primal** is a minimalist, lightweight, functional programming language that is designed to be simple and easy to learn. It is inspired by [Lambda Calculus](https://en.wikipedia.org/wiki/Lambda_calculus), a mathematical formalism that is used to define functions and perform computations.

It is a declarative language, which means that it focuses on what should be done rather than how it should be done. This makes it easier to read and understand, especially for beginners.

It is free and open-source under the [MIT license](https://en.wikipedia.org/wiki/MIT_License), which means that you can use it for any purpose, commercial or non-commercial, without any restrictions. You can also modify the source code and distribute it as you see fit.

It is still under development, so there may be bugs and missing features. If you encounter any issues, please report them on [GitHub](https://github.com/primal-lang/sdk/issues/new). If you have any suggestions or ideas for improvement, please let us know by sending us feedback using the [web form](https://primal-lang.org/feedback).

## Goal

The language is designed primarily for educational purposes. It aims to teach programming concepts without the complexity of more advanced languages. It emphasizes simplicity and minimalist syntax, making it a good choice for beginners who are learning the fundamentals of programming. It is not intended to be used in production environments, but it can be used for small scripts.

## Technical envelope

The language has the following characteristics:

*   Lazy evaluated
*   Untyped
*   Single threaded
*   Expression oriented
*   Interpreted
*   Interactive

## Philosophy

Everything in **Primal** is a function, which can be composed to create more complex functions. Functions cannot be overloaded (i.e. only one function with a given name can exist in a program). Currently there are no operators. Instead, the language offers a function with equivalent functionality (e.g. the sum function is the equivalent of the + operator). The full list of functions can be found in the [reference](https://primal-lang.org/reference) page.

Being a functional language, **Primal** does not have loop constructions. Instead, it uses recursion to perform repetitive tasks, allowing for a more declarative style of programming.

## Syntax

The syntax is designed to be simple and easy to read and consists of function declarations, function calls, and expressions that are evaluated to produce a result.

A function definition is composed of:

*   **Function name:** which must match the regular expression `[a-zA-Z]+[\w]*`
*   **Function parameters (optional):** a list of expressions, each of them matching the regular expression `[a-zA-Z]+[\w]*`
*   **Function body:** an expression which consist of either a constant value or a function call

Here is an example of a function with parameters:

```javascript
cube(n) = pow(n, 3)
```

And here is an example of a function without parameters:

```javascript
pi = 3.14159
```

## Main function

There is a special function in the language called main. It is optional and has no parameters. It is the entry point of the program, and it is executed when the program is run. The main function can call other functions and perform computations to produce a result.

If the main function is not present, the program will still run, but no computations will be performed. In this case, the program will run in interactive mode, where the user can enter expressions and see the results of their evaluation.

## Typing system

**Primal** has a dynamic runtime type checking. This means that users cannot explicitly declare types for parameters or return values in the code. Instead, the system performs type checks during execution to ensure that values match the expected types when passed to functions.

This approach offers flexibility and ease of use but relies on runtime checks to catch type-related issues, which can lead to errors that are only caught during execution.

## Runtime

**Primal** is an interpreted language. The compiler translates the source code into an intermediate representation that is then executed by the interpreter. The interpreter is responsible for executing the intermediate representation and producing the output of the program.

This allows for fast development and testing cycles since changes to the source code can be quickly compiled and executed without the need for a separate build step.