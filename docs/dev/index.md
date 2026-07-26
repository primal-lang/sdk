---
title: Developer Knowledge Base
tags:
  - index
sources: []
---

# Developer Knowledge Base

**TLDR**: Internal documentation for SDK contributors covering architecture, compiler internals, and design rationale.

## Pipeline

- [[dev/architecture/pipeline/pipeline]] — Compiler architecture overview
- [[dev/architecture/pipeline/example]] — Compiler walkthrough with sample program
- [[dev/architecture/pipeline/reader]] — Source file reading
- [[dev/architecture/pipeline/lexical]] — Lexical analysis (tokenization)
- [[dev/architecture/pipeline/syntactic]] — Syntactic analysis (parsing)
- [[dev/architecture/pipeline/semantic]] — Semantic analysis (type checking, resolution)
- [[dev/architecture/pipeline/runtime]] — Runtime system (evaluation, values)
- [[dev/architecture/pipeline/models]] — Data models (AST nodes, types)

## Architecture

### Design Patterns

- [[dev/architecture/patterns/state-machine-pattern]] — The State<I,O> abstraction used in lexer/parser
- [[dev/architecture/patterns/analyzer-pattern]] — The Analyzer<I,O> base class and stage composition

### Runtime System

- [[dev/architecture/runtime/term-hierarchy]] — Term base class and subclasses
- [[dev/architecture/runtime/bindings-and-substitution]] — Variable environments and substitution
- [[dev/architecture/runtime/thunks-and-lazy-evaluation]] — Lazy evaluation via deferred reduce()
- [[dev/architecture/runtime/native-functions]] — Standard library function implementation

### Type System

- [[dev/architecture/typing/type-representations]] — How types are modeled in the compiler
- [[dev/architecture/typing/runtime-type-checking]] — When and how types are validated

### Error Handling

- [[dev/architecture/error/error-hierarchy]] — Built-in error types and when they're thrown
- [[dev/architecture/error/error-propagation]] — How errors bubble through the runtime

### Platform & Build

- [[dev/architecture/platform/conditional-imports]] — Platform-specific code for CLI vs web
- [[dev/architecture/platform/build-targets]] — Building for different platforms

### Testing

- [[dev/architecture/testing/test-organization]] — Test directory structure and conventions
- [[dev/architecture/testing/integration-tests]] — End-to-end compilation test patterns

## Roadmap

### 0.5.0

- [[dev/roadmap/0.5.0/testing]] — Testing framework

### 0.6.0

- [[dev/roadmap/0.6.0/enums]] — Enum types
- [[dev/roadmap/0.6.0/option]] — Option type
- [[dev/roadmap/0.6.0/record]] — Record types
- [[dev/roadmap/0.6.0/regex]] — Regular expressions
- [[dev/roadmap/0.6.0/string]] — String improvements
- [[dev/roadmap/0.6.0/tuples]] — Tuple types

### 0.7.0

- [[dev/roadmap/0.7.0/http]] — HTTP client
- [[dev/roadmap/0.7.0/modules]] — Module system

### 0.8.0

- [[dev/roadmap/0.8.0/destructuring]] — Destructuring syntax
- [[dev/roadmap/0.8.0/do]] — Do notation
- [[dev/roadmap/0.8.0/ranges]] — Range syntax
- [[dev/roadmap/0.8.0/try]] — Try/catch expressions

### 0.9.0

- [[dev/roadmap/0.9.0/transpilation]] — Transpilation targets

### 1.0.0

- [[dev/roadmap/1.0.0/currification]] — Automatic currying
- [[dev/roadmap/1.0.0/pattern]] — Pattern matching
- [[dev/roadmap/1.0.0/typing]] — Type system enhancements
