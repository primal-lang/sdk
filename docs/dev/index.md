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

- [[dev/roadmap/destructuring]] — Destructuring syntax
- [[dev/roadmap/pattern]] — Pattern matching
- [[dev/roadmap/modules]] — Module system
- [[dev/roadmap/tuples]] — Tuple types
- [[dev/roadmap/enums]] — Enum types
- [[dev/roadmap/option]] — Option type
- [[dev/roadmap/try]] — Try/catch expressions
- [[dev/roadmap/ranges]] — Range syntax
- [[dev/roadmap/string]] — String improvements
- [[dev/roadmap/regex]] — Regular expressions
- [[dev/roadmap/record]] — Record types
- [[dev/roadmap/typing]] — Type system enhancements
- [[dev/roadmap/currification]] — Automatic currying
- [[dev/roadmap/inspection]] — Runtime inspection
- [[dev/roadmap/http]] — HTTP client
- [[dev/roadmap/testing]] — Testing framework
- [[dev/roadmap/transpilation]] — Transpilation targets
- [[dev/roadmap/do]] — Do notation
