---
title: Language Knowledge Base
tags: [index]
sources: []
---

# Language Knowledge Base

**TLDR**: User-facing documentation for the Primal programming language.

## Overview

- [Primal](../../README.md) — Language overview, philosophy, and getting started

## Reference

- [[lang/reference]] — Core library reference index

### Data Structures

- [[lang/reference/list]] — List operations
- [[lang/reference/map]] — Map operations
- [[lang/reference/set]] — Set operations
- [[lang/reference/vector]] — Vector operations
- [[lang/reference/stack]] — Stack operations
- [[lang/reference/queue]] — Queue operations

### Arithmetic & Logic

- [[lang/reference/arithmetic]] — Arithmetic operations
- [[lang/reference/comparison]] — Comparison operations
- [[lang/reference/logic]] — Logical operations
- [[lang/reference/operators]] — Operator reference

### Strings & Encoding

- [[lang/reference/string]] — String operations
- [[lang/reference/json]] — JSON encoding/decoding
- [[lang/reference/base64]] — Base64 encoding/decoding
- [[lang/reference/hash]] — Hashing functions
- [[lang/reference/uuid]] — UUID generation

### I/O & System

- [[lang/reference/file]] — File operations
- [[lang/reference/directory]] — Directory operations
- [[lang/reference/path]] — Path operations
- [[lang/reference/environment]] — Environment variables
- [[lang/reference/console]] — Console I/O
- [[lang/reference/timestamp]] — Timestamp operations

### Control & Debugging

- [[lang/reference/control]] — Control flow
- [[lang/reference/error]] — Error handling
- [[lang/reference/debug]] — Debugging utilities
- [[lang/reference/casting]] — Type casting

## Design

- [[lang/design/function-definitions]] — Anatomy of function definitions, naming rules, and the main function
- [[lang/design/let-and-where]] — Local bindings with let expressions and where clauses
- [[lang/design/operators]] — Arithmetic, comparison, and logical operators with precedence rules
- [[lang/design/dynamic-typing]] — Runtime type checking without type annotations
- [[lang/design/type-hierarchy]] — Overview of all types in Primal
- [[lang/design/immutability]] — All values are immutable; operations return new values
- [[lang/design/expression-oriented]] — Everything is an expression that produces a value
- [[lang/design/first-class-functions]] — Functions as values, higher-order functions, and composition
- [[lang/design/lazy-evaluation]] — Deferred computation with thunks and short-circuit operators
- [[lang/design/recursion]] — Iteration through recursion, common patterns, and higher-order alternatives
- [[lang/design/error-handling]] — Throwing and catching errors with error.throw and try
- [[lang/design/working-with-collections]] — Collection types and transformation patterns
