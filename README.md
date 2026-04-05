<p align="center">
  <a href="https://primal-lang.org"><img src="https://primal-lang.org/img/rounded.png" alt="Primal" height="170"></a>
</p>

<p align="center">
<a href="https://github.com/primal-lang/sdk/blob/main/LICENSE.md" target="_blank"><img height=20 src="https://img.shields.io/badge/License-MIT-green.svg" /></a>
<a href="https://github.com/primal-lang/sdk/releases/tag/v0.4.2"><img src="https://img.shields.io/badge/Latest-0.4.2-blue" /></a>
</p>

# Primal

- [Overview](#overview)
- [Goal](#goal)
- [Technical envelope](#technical-envelope)
- [Getting started](#getting-started)
- [Philosophy](#philosophy)
- [Syntax](#syntax)
- [Main function](#main-function)
- [Typing system](#typing-system)
- [Runtime](#runtime)

## Overview

`Primal` is a minimalist, lightweight, functional programming language that is designed to be simple and easy to learn. It is inspired by [Lambda Calculus](https://en.wikipedia.org/wiki/Lambda_calculus), a mathematical formalism that is used to define functions and perform computations.

It is a declarative language, which means that it focuses on what should be done rather than how it should be done. This makes it easier to read and understand, especially for beginners.

It is free and open-source under the [MIT license](https://en.wikipedia.org/wiki/MIT_License), meaning that you can use it for any purpose, commercial or non-commercial, without any restrictions. You can also modify the source code and distribute it as you see fit.

It is still under development, so there may be bugs and missing features. If you encounter any issues, please report them on [GitHub](https://github.com/primal-lang/sdk/issues/new). If you have any suggestions or ideas for improvement, please let us know by sending us feedback using the [web form](https://primal-lang.org/feedback).

## Goal

The language is designed primarily for educational purposes. It aims to teach programming concepts without the complexity of more advanced languages. It emphasizes simplicity and minimalist syntax, making it a good choice for beginners who are learning the fundamentals of programming. It is not intended to be used in production environments, but it can be used for small scripts.

## Technical envelope

The language has the following characteristics:

- Dynamically typed
- Single threaded
- Interpreted
- Expression oriented
- Garbage collected
- Interactive

## Getting started

Pre-built binaries are available for Linux, macOS, and Windows. Download the appropriate release from the [GitHub releases](https://github.com/primal-lang/sdk/releases) page, extract it, and add the `bin` folder to your PATH. Then run the interpreter with a source file as an argument:

```bash
primal program.prm
```

If no source file is provided, the interpreter starts in interactive mode.

## Philosophy

Everything in `Primal` is a function, which can be composed to create more complex functions. Functions are first-class values, meaning they can be passed as arguments to other functions and returned as results. The language includes a comprehensive set of over 200 core functions, providing developers with a wide range of useful tools. The full list can be found in the [reference](https://primal-lang.org/reference) page.

Being a functional language, `Primal` does not have loop constructions. Instead, it uses recursion to perform repetitive tasks, allowing for a more declarative style of programming.

All values in `Primal` are immutable. Once a value is created, it cannot be changed. This design choice simplifies reasoning about programs and avoids common bugs related to shared mutable state.

## Syntax

The syntax is designed to be simple and easy to read and consists of function declarations that are evaluated to produce a result.

A function declaration is composed of:

- **Name:** which must match the regular expression `[a-zA-Z][\w\.]*`
- **Parameters (optional):** a list of identifiers, each matching the regular expression `[a-zA-Z][\w\.]*`
- **Body:** an expression which consists of combinations of:
  - Constants: `"Hello"`, `42`, `true`, `[1, 2, 3]`, etc
  - Operations: `foo + 3`, `!foo`, `foo >= bar`, etc
  - Function calls: `foo(x)`, `bar(10)`, etc
  - Conditionals: `if (foo) bar else baz`

Here is an example of a function with parameters:

```javascript
cube(n) = pow(n, 3)
```

And here is an example of a function without parameters:

```javascript
pi = 3.14159;
```

Here is an example of a conditional expression:

```javascript
abs(n) = if (n >= 0) n else -n
```

## Main function

There is a special function in the language called main, which serves as the entry point of a program when it is run. The main function is optional and can be declared with any number of parameters, including none. If present, it can call other functions and perform computations to produce a result.

If the main function is not present, the program will still run, but no computations will be performed. In this case, the program will run in interactive mode, where the user can enter expressions and see the results of their evaluation.

## Typing system

`Primal` has a dynamic runtime type checking. This means that users cannot explicitly declare types for parameters or return values in the code. Instead, the system performs type checks during execution to ensure that values match the expected types when passed to functions.

This approach offers flexibility and ease of use but relies on runtime checks to catch type-related issues, which can lead to errors that are only caught during execution.

These are the available types at runtime:

Primitives:

- Boolean
- Number
- String

Collections:

- List
- Map
- Set
- Stack
- Queue
- Vector

System:

- File
- Directory
- Timestamp
- Function

## Runtime

`Primal` is an interpreted language. The source code is first parsed into an intermediate representation, which is then evaluated by the interpreter to produce the output of the program.

This allows for fast development and testing cycles since changes to the source code can be immediately executed without the need for a separate build step.

The interpreter manages memory automatically through garbage collection, freeing developers from manual memory management.

When running in interactive mode (i.e. when no main function is defined), the interpreter provides a REPL (Read-Eval-Print Loop) where users can type expressions at a prompt and see their results immediately.
