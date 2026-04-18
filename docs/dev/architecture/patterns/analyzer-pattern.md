---
title: Analyzer Pattern
tags:
  - architecture
  - analyzer
sources:
  - lib/compiler/models/analyzer.dart
  - lib/compiler/reader/source_reader.dart
  - lib/compiler/lexical/lexical_analyzer.dart
  - lib/compiler/syntactic/syntactic_analyzer.dart
  - lib/compiler/semantic/semantic_analyzer.dart
---

# Analyzer Pattern

**TLDR**: Each compiler stage extends the abstract `Analyzer<I, O>` base class, which defines a uniform interface with an `input` field and an `analyze()` method. This pattern enables consistent stage composition and pipeline construction.

## The Analyzer Base Class

The `Analyzer<I, O>` class in `lib/compiler/models/analyzer.dart` defines the contract for all compiler stages:

```dart
abstract class Analyzer<I, O> {
  final I input;

  const Analyzer(this.input);

  O analyze();
}
```

Key elements:

- **`I`** - Input type for the stage
- **`O`** - Output type produced by the stage
- **`input`** - The data to process (stored as a field)
- **`analyze()`** - The transformation method

## Stage Implementations

Each compiler stage extends `Analyzer` with specific input and output types.

### SourceReader

```dart
class SourceReader extends Analyzer<String, List<Character>> {
  const SourceReader(super.input);

  @override
  List<Character> analyze() {
    final List<Character> result = [];
    // ... process input string
    return result;
  }
}
```

| Property       | Value                                              |
| -------------- | -------------------------------------------------- |
| Input type     | `String`                                           |
| Output type    | `List<Character>`                                  |
| Implementation | Iterates over grapheme clusters, assigns locations |

### LexicalAnalyzer

```dart
class LexicalAnalyzer extends Analyzer<List<Character>, List<Token>> {
  const LexicalAnalyzer(super.input);

  @override
  List<Token> analyze() {
    final List<Token> result = [];
    final ListIterator<Character> iterator = ListIterator(input);
    State state = InitState(iterator);

    while (iterator.hasNext) {
      state = state.next;
      if (state is ResultState) {
        result.add(state.output);
        state = InitState(iterator);
      }
    }
    // ... handle end-of-input states
    return result;
  }
}
```

| Property       | Value                 |
| -------------- | --------------------- |
| Input type     | `List<Character>`     |
| Output type    | `List<Token>`         |
| Implementation | State machine pattern |

### SyntacticAnalyzer

```dart
class SyntacticAnalyzer extends Analyzer<List<Token>, List<FunctionDefinition>> {
  const SyntacticAnalyzer(super.tokens);

  @override
  List<FunctionDefinition> analyze() {
    final List<FunctionDefinition> result = [];
    final ListIterator<Token> iterator = ListIterator(input);
    State state = InitState(iterator);

    while (iterator.hasNext) {
      state = state.next;
      if (state is ResultState) {
        result.add(state.output);
        state = InitState(iterator);
      }
    }

    if (state is! InitState) {
      throw const UnexpectedEndOfFileError();
    }

    return result;
  }
}
```

| Property       | Value                                             |
| -------------- | ------------------------------------------------- |
| Input type     | `List<Token>`                                     |
| Output type    | `List<FunctionDefinition>`                        |
| Implementation | State machine + recursive descent for expressions |

### SemanticAnalyzer

```dart
class SemanticAnalyzer extends Analyzer<List<FunctionDefinition>, IntermediateRepresentation> {
  const SemanticAnalyzer(super.input);

  @override
  IntermediateRepresentation analyze() {
    final List<GenericWarning> warnings = [];

    // First pass: extract signatures, check duplicates
    final Map<String, FunctionSignature> customSignatures = {};
    for (final FunctionDefinition function in input) {
      // ... signature extraction and validation
    }

    // Second pass: build semantic IR
    final Map<String, SemanticFunction> customFunctions = {};
    for (final FunctionDefinition function in input) {
      // ... semantic analysis
    }

    return IntermediateRepresentation(
      customFunctions: customFunctions,
      standardLibrarySignatures: standardLibrarySignatures,
      warnings: warnings,
    );
  }
}
```

| Property       | Value                                         |
| -------------- | --------------------------------------------- |
| Input type     | `List<FunctionDefinition>`                    |
| Output type    | `IntermediateRepresentation`                  |
| Implementation | Two-pass traversal with identifier resolution |

## The analyze() Method Contract

The `analyze()` method follows these conventions:

1. **Pure transformation** - Takes input from the field, returns output
2. **No side effects** - Does not modify external state
3. **Throws on error** - Compilation errors are thrown as exceptions
4. **Warnings collected** - Non-fatal issues are accumulated (in SemanticAnalyzer)

## Stage Composition

The `Analyzer` pattern enables clean stage composition in `Compiler.compile()`:

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

Each stage:

1. Receives output from the previous stage
2. Creates an analyzer instance
3. Calls `analyze()` to produce output
4. Passes output to the next stage

## Benefits of the Pattern

1. **Uniform interface** - All stages have the same shape
2. **Const constructible** - Analyzers are immutable value objects
3. **Type safety** - Input/output types are explicit in the class signature
4. **Testable** - Each stage can be tested independently
5. **Composable** - Stages can be chained or rearranged
6. **Debuggable** - Intermediate results can be inspected between stages

## Lowerer: A Different Pattern

The `Lowerer` class does not extend `Analyzer` because it has a different role:

```dart
class Lowerer {
  final Map<String, FunctionTerm> functions;

  const Lowerer(this.functions);

  CustomFunctionTerm lowerFunction(SemanticFunction function) {
    return CustomFunctionTerm(
      name: function.name,
      parameters: function.parameters,
      term: lowerTerm(function.body),
    );
  }

  Term lowerTerm(SemanticNode semanticNode) {
    // ... pattern matching on node type
  }
}
```

The `Lowerer` differs because:

- It is invoked per-function or per-term, not once per stage
- It needs a reference to the shared function map for `FunctionReferenceTerm`
- It is orchestrated by `RuntimeFacade` rather than `Compiler`

## Related Documentation

- [[dev/compiler]] - Overall compiler architecture
- [[dev/architecture/pipeline/pipeline-overview]] - How stages connect
- [[dev/architecture/pipeline/state-machine-pattern]] - State machine implementation details
