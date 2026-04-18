---
title: Pipeline Overview
tags: [architecture, pipeline]
sources:
  [
    lib/compiler/compiler.dart,
    lib/compiler/lowering/runtime_facade.dart,
    lib/compiler/lowering/lowerer.dart,
  ]
---

# Pipeline Overview

**TLDR**: The Primal compiler is a six-stage pipeline that transforms source code through SourceReader, LexicalAnalyzer, SyntacticAnalyzer, SemanticAnalyzer, Lowerer, and Runtime, with data flowing as Characters, Tokens, AST, SemanticIR, Terms, and Values respectively.

## Data Flow

```
Source Code (String)
    |
    v
 SourceReader ........ List<Character>    Characters with locations
    |
    v
 LexicalAnalyzer ..... List<Token>        Tokens (keywords, literals, operators)
    |
    v
 SyntacticAnalyzer ... List<FunctionDefinition>    Function definitions with ASTs
    |
    v
 SemanticAnalyzer .... IntermediateRepresentation  Semantic IR with resolved references
    |
    v
 Lowerer ............. Map<String, FunctionTerm>   Runtime terms for evaluation
    |
    v
 Runtime ............. Term                        Evaluated result
```

## Compilation Entry Point

The primary entry point is `Compiler.compile(String input)` in `lib/compiler/compiler.dart`. This method orchestrates the first four stages:

```dart
IntermediateRepresentation compile(String input) {
  final SourceReader reader = SourceReader(input);
  final List<Character> characters = reader.analyze();

  final LexicalAnalyzer lexicalAnalyzer = LexicalAnalyzer(characters);
  final List<Token> tokens = lexicalAnalyzer.analyze();

  final SyntacticAnalyzer syntacticAnalyzer = SyntacticAnalyzer(tokens);
  final List<FunctionDefinition> functions = syntacticAnalyzer.analyze();

  final SemanticAnalyzer semanticAnalyzer = SemanticAnalyzer(functions);

  return semanticAnalyzer.analyze();
}
```

The `Compiler` class also provides specialized entry points:

- `expression(String input)` - Parses a single expression (used by REPL)
- `functionDefinition(String input)` - Attempts to parse a function definition

## Runtime Orchestration

The `RuntimeFacade` class in `lib/compiler/lowering/runtime_facade.dart` bridges compilation and execution. It receives the `IntermediateRepresentation` from compilation and manages:

1. **Lowering** - Converting semantic IR to runtime terms via the `Lowerer`
2. **Function registration** - Building the combined function map (custom + standard library)
3. **Evaluation** - Executing expressions through the `Runtime`

### Initialization Flow

```dart
factory RuntimeFacade(
  IntermediateRepresentation intermediateRepresentation,
  ExpressionParser parseExpression,
) {
  // Build RuntimeInput containing lowered functions
  final RuntimeInput input = const RuntimeInputBuilder().build(
    intermediateRepresentation,
  );

  // Build combined signature map for validation
  final Map<String, FunctionSignature> allSignatures = {
    ...intermediateRepresentation.standardLibrarySignatures,
    // ... custom function signatures
  };

  return RuntimeFacade._internal(...);
}
```

### Expression Evaluation Flow

When evaluating an expression (e.g., from REPL or `main` execution):

```dart
Term evaluateToTerm(Expression expression) {
  // Reset recursion tracking
  FunctionTerm.resetDepth();

  // Semantic check: Expression -> SemanticNode
  const SemanticAnalyzer analyzer = SemanticAnalyzer([]);
  final SemanticNode semanticNode = analyzer.checkExpression(
    expression: expression,
    // ... validation context
  );

  // Lower: SemanticNode -> Term
  final Lowerer lowerer = Lowerer(_runtimeInput.functions);
  final Term lowered = lowerer.lowerTerm(semanticNode);

  // Evaluate: Term -> Term (reduced)
  return lowered.reduce();
}
```

## Stage Responsibilities

| Stage             | Input                        | Output                       | Primary Responsibility                                            |
| ----------------- | ---------------------------- | ---------------------------- | ----------------------------------------------------------------- |
| SourceReader      | `String`                     | `List<Character>`            | Character extraction with source locations                        |
| LexicalAnalyzer   | `List<Character>`            | `List<Token>`                | Tokenization via state machine                                    |
| SyntacticAnalyzer | `List<Token>`                | `List<FunctionDefinition>`   | Function definition parsing via state machine + recursive descent |
| SemanticAnalyzer  | `List<FunctionDefinition>`   | `IntermediateRepresentation` | Identifier resolution, arity checking, validation                 |
| Lowerer           | `IntermediateRepresentation` | `Map<String, FunctionTerm>`  | Strip locations, resolve function references                      |
| Runtime           | `Term`                       | `Term`                       | Substitution-based evaluation                                     |

## Separation of Concerns

The pipeline maintains clear boundaries:

1. **Compiler stages (1-4)** produce the `IntermediateRepresentation` which retains source locations and semantic metadata
2. **Lowering (stage 5)** strips source locations and produces minimal runtime representation
3. **Runtime (stage 6)** operates purely on terms without source context

This separation enables:

- Error messages with source locations from semantic IR
- Efficient runtime representation without location overhead
- Independent testing of compilation vs execution

## Related Documentation

- [[dev/compiler]] - Detailed compiler architecture
- [[dev/compiler/reader]] - SourceReader implementation
- [[dev/compiler/lexical]] - Lexical analyzer details
- [[dev/compiler/syntactic]] - Syntactic analyzer details
- [[dev/compiler/semantic]] - Semantic analyzer details
- [[dev/compiler/runtime]] - Runtime and evaluation
