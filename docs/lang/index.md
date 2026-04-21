---
title: Language Knowledge Base
tags:
  - index
sources: []
---

# Language Knowledge Base

**TLDR**: User-facing documentation for the Primal programming language.

## Overview

- [Primal](../../README.md) — Language overview, philosophy, and getting started

## Reference

Core library functions organized by category. Note: Primal does not support static types, but function signatures in the documentation include type annotations for readability.

### Core

- [[lang/reference/core/operators]] — Operator reference
- [[lang/reference/core/comparison]] — Comparison operations
- [[lang/reference/core/casting]] — Type casting
- [[lang/reference/core/introspection]] — Runtime introspection
- [[lang/reference/core/control]] — Control flow
- [[lang/reference/core/error]] — Error handling

### Primitives

- [[lang/reference/primitives/arithmetic]] — Arithmetic operations
- [[lang/reference/primitives/string]] — String operations
- [[lang/reference/primitives/logic]] — Logical operations

### Collections

- [[lang/reference/collections/list]] — List operations
- [[lang/reference/collections/map]] — Map operations
- [[lang/reference/collections/set]] — Set operations
- [[lang/reference/collections/stack]] — Stack operations
- [[lang/reference/collections/queue]] — Queue operations
- [[lang/reference/collections/vector]] — Vector operations

### Time

- [[lang/reference/time/timestamp]] — Timestamp operations
- [[lang/reference/time/duration]] — Duration operations

### I/O

- [[lang/reference/io/file]] — File operations
- [[lang/reference/io/directory]] — Directory operations
- [[lang/reference/io/path]] — Path operations
- [[lang/reference/io/console]] — Console I/O
- [[lang/reference/io/environment]] — Environment variables
- [[lang/reference/io/debug]] — Debugging utilities

### Encoding

- [[lang/reference/encoding/json]] — JSON encoding/decoding
- [[lang/reference/encoding/base64]] — Base64 encoding/decoding
- [[lang/reference/encoding/hash]] — Hashing functions
- [[lang/reference/encoding/uuid]] — UUID generation

## Design

- [[lang/design/function-definitions]] — Anatomy of function definitions, naming rules, and the main function
- [[lang/design/let]] — Local bindings with let expressions
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
