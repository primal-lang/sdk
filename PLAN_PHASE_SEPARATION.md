# Plan: Compiler Phase Separation Refactoring

This document outlines a detailed plan to achieve clean separation between compiler pipeline phases by eliminating boundary violations identified in the analysis.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Issues Summary](#2-issues-summary)
3. [Implementation Steps](#3-implementation-steps)
   - [Phase 1: Remove `FunctionNode` from `SemanticIdentifierNode`](#phase-1-remove-functionnode-from-semanticidentifiernode)
   - [Phase 2: Extract `FunctionSignature` as a Shared Model](#phase-2-extract-functionsignature-as-a-shared-model)
   - [Phase 3: Refactor `IntermediateCode` to Be Pure Semantic Output](#phase-3-refactor-intermediatecode-to-be-pure-semantic-output)
   - [Phase 4: Move Lowering Orchestration to `compiler.dart`](#phase-4-move-lowering-orchestration-to-compilerdart)
   - [Phase 5: Eliminate `validateExpression` from `SemanticAnalyzer`](#phase-5-eliminate-validateexpression-from-semanticanalyzer)
   - [Phase 6: Decouple `RuntimeFacade` from `Compiler`](#phase-6-decouple-runtimefacade-from-compiler)
   - [Phase 7: Remove `Character.lexeme` Accessor](#phase-7-remove-characterlexeme-accessor)
4. [Testing Strategy](#4-testing-strategy)
5. [Documentation Updates](#5-documentation-updates)
6. [Implementation Order](#6-implementation-order)
7. [Risk Mitigation](#7-risk-mitigation)

---

## 1. Overview

The compiler has five pipeline phases:

```
Source Reader → Lexical Analyzer → Syntactic Analyzer → Semantic Analyzer → Runtime
```

Currently, the **semantic phase** has boundary violations where it directly depends on runtime types (`FunctionNode`, `Node`). This creates tight coupling and violates the principle that each phase should only depend on its input phase and shared models.

**Target State:**

```
         ┌──────────────────────────────────────────────────────────────────┐
         │                        Shared Models                             │
         │  (Location, Parameter, Type, FunctionSignature, Analyzer, etc.)  │
         └──────────────────────────────────────────────────────────────────┘
                    ↓              ↓              ↓              ↓
              ┌─────────┐    ┌─────────┐    ┌──────────┐    ┌─────────┐
  String  →   │ Reader  │ →  │ Lexical │ →  │ Syntactic│ →  │ Semantic│ → IntermediateCode
              └─────────┘    └─────────┘    └──────────┘    └─────────┘
                                                                  ↓
                                                            ┌──────────┐
                                              (Lowerer) →   │ Runtime  │ → Result
                                                            └──────────┘
```

---

## 2. Issues Summary

| ID | Location | Issue | Severity |
|----|----------|-------|----------|
| I1 | `semantic_node.dart:2` | Imports `runtime/node.dart` for `FunctionNode` reference | High |
| I2 | `intermediate_code.dart:2` | Imports `runtime/node.dart`, stores `Map<String, FunctionNode>` | High |
| I3 | `semantic_analyzer.dart:6` | Imports `runtime/node.dart` for `validateExpression()` | High |
| I4 | `lowerer.dart:4` | Imports `syntactic/expression.dart` for `lowerExpression()` | Medium |
| I5 | `runtime_facade.dart:1` | Imports `compiler.dart` creating circular dependency risk | Medium |
| I6 | `reader/character.dart:1` | Imports `lexical/lexeme.dart` for convenience accessor | Low |

---

## 3. Implementation Steps

### Phase 1: Remove `FunctionNode` from `SemanticIdentifierNode`

**Goal:** `SemanticIdentifierNode` should not hold a reference to `FunctionNode`.

**Current State:**
```dart
// semantic_node.dart
class SemanticIdentifierNode extends SemanticNode {
  final String name;
  final FunctionNode? resolvedFunction;  // ← Violation
}
```

**Target State:**
```dart
// semantic_node.dart
class SemanticIdentifierNode extends SemanticNode {
  final String name;
  final FunctionSignature? resolvedSignature;  // ← Use shared model
}
```

**Steps:**

1. **Create `FunctionSignature` in shared models** (see Phase 2 first)

2. **Update `SemanticIdentifierNode`:**
   - File: `lib/compiler/semantic/semantic_node.dart`
   - Remove import of `runtime/node.dart`
   - Change `resolvedFunction: FunctionNode?` to `resolvedSignature: FunctionSignature?`

3. **Update `SemanticAnalyzer.checkExpression()`:**
   - File: `lib/compiler/semantic/semantic_analyzer.dart`
   - Where `SemanticIdentifierNode` is created with `resolvedFunction`, create a `FunctionSignature` instead
   - Change: `resolvedFunction: allFunctions[name]` → `resolvedSignature: allSignatures[name]`

4. **Update all callers that access `resolvedFunction`:**
   - Search for `.resolvedFunction` usages
   - Replace with `.resolvedSignature` where appropriate

**Files Modified:**
- `lib/compiler/semantic/semantic_node.dart`
- `lib/compiler/semantic/semantic_analyzer.dart`

**Tests to Update:**
- `test/compiler/semantic_analyzer_test.dart` - update assertions checking `resolvedFunction`

---

### Phase 2: Extract `FunctionSignature` as a Shared Model

**Goal:** Create a lightweight, phase-agnostic representation of function signatures.

**Rationale:** Currently `FunctionNode` serves as both:
- A runtime evaluation node (has `evaluate()` method)
- A function signature descriptor (name + parameters)

These concerns should be separated.

**Steps:**

1. **Create `lib/compiler/models/function_signature.dart`:**

```dart
import 'package:primal/compiler/models/parameter.dart';

/// A phase-agnostic function signature.
///
/// Used during semantic analysis to validate calls without
/// depending on runtime node types.
class FunctionSignature {
  final String name;
  final List<Parameter> parameters;

  const FunctionSignature({
    required this.name,
    required this.parameters,
  });

  int get arity => parameters.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionSignature &&
          name == other.name &&
          _parametersEqual(parameters, other.parameters);

  @override
  int get hashCode => Object.hash(name, Object.hashAll(parameters));

  static bool _parametersEqual(List<Parameter> a, List<Parameter> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].name != b[i].name) return false;
    }
    return true;
  }

  @override
  String toString() => '$name(${parameters.map((p) => p.name).join(', ')})';
}
```

2. **Add export to `lib/compiler/models/models.dart`** (if barrel exists) or create one

3. **Update `StandardLibrary` to expose signatures:**
   - File: `lib/compiler/library/standard_library.dart`
   - Add method: `static List<FunctionSignature> getSignatures()`
   - This method returns signatures without requiring runtime node dependency

4. **Add `toSignature()` method to `FunctionNode`:**
   - File: `lib/compiler/runtime/node.dart`
   - Add: `FunctionSignature toSignature() => FunctionSignature(name: name, parameters: parameters);`

**Files Created:**
- `lib/compiler/models/function_signature.dart`

**Files Modified:**
- `lib/compiler/library/standard_library.dart`
- `lib/compiler/runtime/node.dart`

**Tests to Add:**
- `test/compiler/models/function_signature_test.dart`
  - Test equality
  - Test arity computation
  - Test toString formatting

---

### Phase 3: Refactor `IntermediateCode` to Be Pure Semantic Output

**Goal:** `IntermediateCode` should contain only semantic-level data, not runtime nodes.

**Current State:**
```dart
class IntermediateCode {
  final Map<String, SemanticFunction> customFunctions;
  final Map<String, FunctionNode> standardLibrary;  // ← Violation
  final List<GenericWarning> warnings;
}
```

**Target State:**
```dart
class IntermediateCode {
  final Map<String, SemanticFunction> customFunctions;
  final Map<String, FunctionSignature> standardLibrarySignatures;  // ← Pure semantic
  final List<GenericWarning> warnings;
}
```

**Steps:**

1. **Update `IntermediateCode`:**
   - File: `lib/compiler/semantic/intermediate_code.dart`
   - Remove import of `runtime/node.dart`
   - Change `standardLibrary: Map<String, FunctionNode>` to `standardLibrarySignatures: Map<String, FunctionSignature>`
   - Update `factory IntermediateCode.empty()` to use `StandardLibrary.getSignatures()`
   - Update helper methods:
     - `getStandardLibraryFunction()` → `getStandardLibrarySignature()`

2. **Update `SemanticAnalyzer.analyze()`:**
   - File: `lib/compiler/semantic/semantic_analyzer.dart`
   - Build `Map<String, FunctionSignature>` for analysis instead of `Map<String, FunctionNode>`
   - Pass signatures to `IntermediateCode` constructor

3. **Update `RuntimeInputBuilder`:**
   - File: `lib/compiler/semantic/runtime_input_builder.dart`
   - Now needs to fetch actual `FunctionNode` instances from `StandardLibrary.get()` when building runtime input
   - This is the appropriate place to access runtime nodes

4. **Update callers of `IntermediateCode`:**
   - `RuntimeFacade` - update to use new method names
   - Any other files accessing `standardLibrary`

**Files Modified:**
- `lib/compiler/semantic/intermediate_code.dart`
- `lib/compiler/semantic/semantic_analyzer.dart`
- `lib/compiler/semantic/runtime_input_builder.dart`
- `lib/compiler/semantic/runtime_facade.dart`

**Tests to Update:**
- `test/compiler/intermediate_code_test.dart`
  - Update to use `standardLibrarySignatures`
  - Update factory assertions

---

### Phase 4: Move Lowering Orchestration to `compiler.dart`

**Goal:** The `Lowerer` should only convert `SemanticNode → Node`, not `Expression → Node`.

**Current State:**
```dart
// lowerer.dart
class Lowerer {
  Node lowerExpression(Expression expression);  // ← Bridges syntactic→runtime
  Node lowerNode(SemanticNode node);            // ← Correct: semantic→runtime
  CustomFunctionNode lowerFunction(SemanticFunction function);
}
```

**Rationale:** `lowerExpression()` bypasses semantic analysis entirely, which is used by `RuntimeFacade.evaluate()` for REPL expressions. This should instead go through proper semantic analysis.

**Steps:**

1. **Remove `lowerExpression()` from `Lowerer`:**
   - File: `lib/compiler/semantic/lowerer.dart`
   - Remove the `lowerExpression()` method entirely
   - Remove import of `syntactic/expression.dart`
   - Keep only `lowerNode()` and `lowerFunction()`

2. **Update `RuntimeFacade.evaluate()`:**
   - File: `lib/compiler/semantic/runtime_facade.dart`
   - Instead of: `lowerer.lowerExpression(expression)`
   - Use: Full pipeline through semantic analysis
   - The expression should go: `Expression → SemanticAnalyzer.checkExpression() → SemanticNode → Lowerer.lowerNode() → Node`

3. **Create helper in `Compiler` for expression evaluation:**
   - File: `lib/compiler/compiler.dart`
   - Add method that compiles an expression through semantic checking:
   ```dart
   Node compileExpression(Expression expression, Map<String, FunctionSignature> availableFunctions) {
     // Semantic check
     final SemanticNode semanticNode = semanticAnalyzer.checkExpression(...);
     // Lower
     return const Lowerer().lowerNode(semanticNode);
   }
   ```

4. **Update `RuntimeFacade` to use new compiler method:**
   - Pass the expression through proper pipeline

**Files Modified:**
- `lib/compiler/semantic/lowerer.dart`
- `lib/compiler/semantic/runtime_facade.dart`
- `lib/compiler/compiler.dart`

**Tests to Update:**
- `test/compiler/lowerer_expression_test.dart`
  - Remove or refactor tests for `lowerExpression()`
  - Ensure expression lowering is tested through proper pipeline

---

### Phase 5: Eliminate `validateExpression` from `SemanticAnalyzer`

**Goal:** Remove the static `validateExpression()` method that operates on runtime `Node` types.

**Current State:**
```dart
// semantic_analyzer.dart
static Node validateExpression(Node node, Map<String, FunctionNode> functions) {
  // Validates runtime Node, creates SemanticNode, then lowers back to Node
}
```

**Rationale:** This method exists because REPL expressions need validation, but it creates a backwards dependency (semantic → runtime → semantic → runtime). The proper flow should be:

```
REPL input → Syntactic Expression → Semantic Analysis → Lowering → Runtime Node
```

**Steps:**

1. **Update `RuntimeFacade.evaluate()` to use proper pipeline:**
   - After Phase 4, this should already be using the correct flow
   - Remove call to `SemanticAnalyzer.validateExpression()`

2. **Remove `validateExpression()` static method:**
   - File: `lib/compiler/semantic/semantic_analyzer.dart`
   - Delete the entire `validateExpression()` method

3. **Remove `checkNode()` method:**
   - File: `lib/compiler/semantic/semantic_analyzer.dart`
   - Delete `checkNode()` and all its helper methods:
     - `_checkIdentifierNode()`
     - `_checkCallNode()`
     - `_checkCalleeIdentifierNode()`
     - `_checkListNode()`
     - `_checkMapNode()`
     - `_isNonCallableNode()`
     - `_isNonIndexableNode()`
     - `_nodeTypeName()`
   - These duplicate logic from `checkExpression()` variants

4. **Remove import of `runtime/node.dart` from `semantic_analyzer.dart`:**
   - After removing `checkNode()`, this import is no longer needed

**Files Modified:**
- `lib/compiler/semantic/semantic_analyzer.dart`
- `lib/compiler/semantic/runtime_facade.dart`

**Tests to Update:**
- `test/compiler/semantic_analyzer_test.dart`
  - Remove tests for `validateExpression()`
  - Ensure expression validation is tested through `RuntimeFacade` or `Compiler`

---

### Phase 6: Decouple `RuntimeFacade` from `Compiler`

**Goal:** Remove the import of `compiler.dart` from `runtime_facade.dart`.

**Current State:**
```dart
// runtime_facade.dart
import 'package:primal/compiler/compiler.dart';

Expression mainExpression(List<String> arguments) {
  const Compiler compiler = Compiler();
  // Uses compiler.expression() to build main call
}
```

**Rationale:** `RuntimeFacade` is in the semantic phase but imports the top-level `Compiler`, creating a potential circular dependency.

**Steps:**

1. **Inject expression parser as a dependency:**
   - File: `lib/compiler/semantic/runtime_facade.dart`
   - Option A: Accept a parsing function in constructor
   - Option B: Move `RuntimeFacade` outside semantic phase

   **Recommended: Option A**
   ```dart
   typedef ExpressionParser = Expression Function(String input);

   class RuntimeFacade {
     final IntermediateCode intermediateCode;
     final ExpressionParser _parseExpression;
     // ...

     factory RuntimeFacade(
       IntermediateCode code,
       ExpressionParser parseExpression,
     ) { ... }
   }
   ```

2. **Update callers to provide parser:**
   - File: `lib/main/main_cli.dart`
   - File: `lib/main/main_web.dart`
   ```dart
   final RuntimeFacade facade = RuntimeFacade(
     code,
     (input) => const Compiler().expression(input),
   );
   ```

3. **Remove import of `compiler.dart`:**
   - File: `lib/compiler/semantic/runtime_facade.dart`

**Alternative: Move `RuntimeFacade` to a new location**

If `RuntimeFacade` is considered orchestration rather than semantic analysis:
- Move to `lib/compiler/facade/runtime_facade.dart` or
- Move to `lib/compiler/runtime_facade.dart` (sibling to `compiler.dart`)

This would make the import of `compiler.dart` acceptable since it's at the same level.

**Files Modified:**
- `lib/compiler/semantic/runtime_facade.dart`
- `lib/main/main_cli.dart`
- `lib/main/main_web.dart`

**Tests to Update:**
- `test/compiler/runtime_facade_test.dart`
  - Update factory calls to provide parser function

---

### Phase 7: Remove `Character.lexeme` Accessor

**Goal:** Remove backwards dependency from reader to lexical phase.

**Current State:**
```dart
// reader/character.dart
import 'package:primal/compiler/lexical/lexeme.dart';

class Character extends Located {
  Lexeme get lexeme => Lexeme(value: value, location: location);
}
```

**Rationale:** This is a convenience accessor that violates phase separation. The lexical analyzer should create `Lexeme` instances, not the reader.

**Steps:**

1. **Search for usages of `Character.lexeme`:**
   - Find all places where this accessor is used
   - These should be in the lexical analyzer

2. **Replace usages with direct `Lexeme` construction:**
   - In lexical analyzer, replace:
     ```dart
     character.lexeme
     ```
   - With:
     ```dart
     Lexeme(value: character.value, location: character.location)
     ```

3. **Remove the `lexeme` accessor:**
   - File: `lib/compiler/reader/character.dart`
   - Delete the `get lexeme` accessor
   - Remove import of `lexical/lexeme.dart`

**Files Modified:**
- `lib/compiler/reader/character.dart`
- `lib/compiler/lexical/lexical_analyzer.dart` (if it uses `character.lexeme`)

**Tests to Update:**
- `test/compiler/source_reader_test.dart`
  - Remove any tests that rely on `Character.lexeme`

---

## 4. Testing Strategy

### New Tests to Create

| Test File | Purpose |
|-----------|---------|
| `test/compiler/models/function_signature_test.dart` | Unit tests for `FunctionSignature` class |
| `test/compiler/phase_separation_test.dart` | Integration tests verifying phase boundaries |

### Phase Separation Integration Tests

Create `test/compiler/phase_separation_test.dart`:

```dart
/// Tests that verify clean phase separation in the compiler.
///
/// These tests check that each phase only imports from:
/// - Its own files
/// - Previous phases
/// - Shared models
library;

import 'package:test/test.dart';
import 'dart:io';

void main() {
  group('Phase Separation', () {
    test('reader does not import from lexical, syntactic, semantic, or runtime', () {
      final violations = checkImports('lib/compiler/reader', [
        'lexical/',
        'syntactic/',
        'semantic/',
        'runtime/',
      ]);
      expect(violations, isEmpty);
    });

    test('lexical does not import from syntactic, semantic, or runtime', () {
      final violations = checkImports('lib/compiler/lexical', [
        'syntactic/',
        'semantic/',
        'runtime/',
      ]);
      expect(violations, isEmpty);
    });

    test('syntactic does not import from semantic or runtime', () {
      final violations = checkImports('lib/compiler/syntactic', [
        'semantic/',
        'runtime/',
      ]);
      expect(violations, isEmpty);
    });

    test('semantic does not import from runtime', () {
      final violations = checkImports('lib/compiler/semantic', [
        'runtime/',
      ]);
      expect(violations, isEmpty);
    });
  });
}

List<String> checkImports(String directory, List<String> forbidden) {
  // Implementation: scan files and check imports
}
```

### Existing Tests to Update

| Test File | Changes Required |
|-----------|------------------|
| `test/compiler/semantic_analyzer_test.dart` | Remove `validateExpression` tests; update `resolvedFunction` → `resolvedSignature` |
| `test/compiler/intermediate_code_test.dart` | Update `standardLibrary` → `standardLibrarySignatures` |
| `test/compiler/lowerer_expression_test.dart` | Refactor to test expression lowering through full pipeline |
| `test/compiler/runtime_facade_test.dart` | Update factory calls to provide parser function |
| `test/compiler/source_reader_test.dart` | Remove `Character.lexeme` tests if any |

### Test Execution Order

After each phase, run:

```bash
dart test
```

Ensure all tests pass before proceeding to the next phase.

---

## 5. Documentation Updates

### Files to Update

#### `docs/compiler.md`

**Section: Pipeline Diagram**

Update to show `FunctionSignature` as a shared model:

```
Source Code
    |
    v
 SourceReader ........ Characters with locations          → compiler/source_reader.md
    |
    v
 Lexical Analyzer .... Tokens (keywords, literals, ...)   → compiler/lexical.md
    |
    v
 Syntactic Analyzer .. Function definitions with ASTs     → compiler/syntactic.md
    |
    v
 Semantic Analyzer ... Semantic IR with FunctionSignature → compiler/semantic.md
    |                                                        ↑
    v                                                        │
 Lowerer ............. Runtime nodes for evaluation       ──┘
    |
    v
 Runtime ............. Evaluation via node substitution   → compiler/runtime.md
```

**Section: Type System**

Add `FunctionSignature` documentation.

#### `docs/compiler/semantic.md`

**Updates Required:**

1. Update "Intermediate Code" section:
   - Document `standardLibrarySignatures` instead of `standardLibrary`
   - Explain that runtime nodes are obtained during lowering, not stored in `IntermediateCode`

2. Update "Lowerer" section:
   - Remove mention of `lowerExpression()`
   - Clarify that lowering only converts `SemanticNode → Node`

3. Add "Phase Boundaries" section:
   - Document that semantic phase does not import from runtime
   - Explain the `FunctionSignature` abstraction

**New Section: FunctionSignature**

```markdown
## FunctionSignature

**File**: `lib/compiler/models/function_signature.dart`

A lightweight, phase-agnostic representation of a function's calling interface:

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String` | Function name |
| `parameters` | `List<Parameter>` | Parameter definitions |

Used during semantic analysis to validate function calls without depending on runtime types.

### Relationship to FunctionNode

| Aspect | FunctionSignature | FunctionNode |
|--------|-------------------|--------------|
| Phase | Semantic | Runtime |
| Purpose | Call validation | Execution |
| Evaluation | No | Yes (`evaluate()`) |
| Parameters | `List<Parameter>` | `List<Parameter>` |
```

#### `docs/compiler/runtime.md`

Add note explaining that `RuntimeInput` is built from `IntermediateCode` during the lowering step orchestrated by `Compiler` or `RuntimeFacade`.

### New Documentation

#### Create `docs/compiler/models.md`

Document shared models used across phases:

```markdown
# Shared Compiler Models

**Directory**: `lib/compiler/models/`

Models in this directory are shared across multiple compiler phases.

## Location

Represents a position in source code (row, column).

## Parameter

Represents a function parameter (name, type constraint).

## FunctionSignature

Represents a function's calling interface (name, parameters).

## Type

Base class for type representations.

## Analyzer

Abstract base class for pipeline stages.
```

---

## 6. Implementation Order

Execute phases in this order to minimize breaking changes:

| Order | Phase | Dependencies | Risk |
|-------|-------|--------------|------|
| 1 | Phase 2: Create `FunctionSignature` | None | Low |
| 2 | Phase 1: Update `SemanticIdentifierNode` | Phase 2 | Medium |
| 3 | Phase 3: Refactor `IntermediateCode` | Phases 1, 2 | Medium |
| 4 | Phase 7: Remove `Character.lexeme` | None | Low |
| 5 | Phase 4: Move lowering orchestration | Phase 3 | High |
| 6 | Phase 5: Eliminate `validateExpression` | Phases 4, 5 | High |
| 7 | Phase 6: Decouple `RuntimeFacade` | Phases 4, 5 | Medium |

### Rationale

1. **Phase 2 first**: Creates the foundation (`FunctionSignature`) needed by subsequent phases
2. **Phase 1 second**: Updates semantic node to use new model
3. **Phase 3 third**: Refactors intermediate code, depends on phases 1 and 2
4. **Phase 7 early**: Independent, low-risk change that can be done anytime
5. **Phase 4 later**: Requires phases 1-3 to be stable
6. **Phase 5 after Phase 4**: Depends on lowering changes
7. **Phase 6 last**: Can be done after semantic phase is clean

---

## 7. Risk Mitigation

### High-Risk Changes

**Phase 4 & 5: Lowering and validateExpression removal**

- **Risk:** REPL and web interface may break
- **Mitigation:**
  1. Add integration tests for REPL before starting
  2. Test web compilation after each sub-step
  3. Keep old code paths temporarily with `@Deprecated` annotation
  4. Remove deprecated code only after full test coverage passes

### Rollback Strategy

Each phase should be a separate commit (or commit group) that can be reverted independently:

```
commit: "feat(models): add FunctionSignature"
commit: "refactor(semantic): use FunctionSignature in SemanticIdentifierNode"
commit: "refactor(semantic): remove FunctionNode from IntermediateCode"
commit: "refactor(reader): remove Character.lexeme accessor"
commit: "refactor(lowerer): remove lowerExpression method"
commit: "refactor(semantic): remove validateExpression static method"
commit: "refactor(facade): inject expression parser"
```

### Verification Checklist

After completing all phases, verify:

- [ ] `dart analyze` reports no issues
- [ ] `dart test` passes all tests
- [ ] `dart run lib/main/main_cli.dart example.pr` works for a sample program
- [ ] Web build compiles successfully
- [ ] REPL mode works correctly
- [ ] No circular dependencies detected
- [ ] Phase separation tests pass

---

## Appendix: File Change Summary

| File | Action | Phase |
|------|--------|-------|
| `lib/compiler/models/function_signature.dart` | Create | 2 |
| `lib/compiler/semantic/semantic_node.dart` | Modify | 1 |
| `lib/compiler/semantic/semantic_analyzer.dart` | Modify | 1, 3, 5 |
| `lib/compiler/semantic/intermediate_code.dart` | Modify | 3 |
| `lib/compiler/semantic/runtime_input_builder.dart` | Modify | 3 |
| `lib/compiler/semantic/lowerer.dart` | Modify | 4 |
| `lib/compiler/semantic/runtime_facade.dart` | Modify | 4, 5, 6 |
| `lib/compiler/compiler.dart` | Modify | 4 |
| `lib/compiler/reader/character.dart` | Modify | 7 |
| `lib/compiler/library/standard_library.dart` | Modify | 2 |
| `lib/compiler/runtime/node.dart` | Modify | 2 |
| `lib/main/main_cli.dart` | Modify | 6 |
| `lib/main/main_web.dart` | Modify | 6 |
| `test/compiler/models/function_signature_test.dart` | Create | 2 |
| `test/compiler/phase_separation_test.dart` | Create | Final |
| `test/compiler/semantic_analyzer_test.dart` | Modify | 1, 5 |
| `test/compiler/intermediate_code_test.dart` | Modify | 3 |
| `test/compiler/lowerer_expression_test.dart` | Modify | 4 |
| `test/compiler/runtime_facade_test.dart` | Modify | 6 |
| `docs/compiler.md` | Update | Final |
| `docs/compiler/semantic.md` | Update | Final |
| `docs/compiler/runtime.md` | Update | Final |
| `docs/compiler/models.md` | Create | Final |
