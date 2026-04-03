# Plan: Fix Compiler Phase Separation Violations

## Overview

Fix 3 critical phase violations to achieve clean separation between compiler phases:

| #   | Violation                  | From → To                             | Severity |
| --- | -------------------------- | ------------------------------------- | -------- |
| 1   | `Expression.toNode()`      | Syntactic → Runtime                   | Medium   |
| 2   | Runtime imports all phases | Runtime → Compiler/Semantic/Syntactic | High     |
| 3   | Bidirectional coupling     | Reader ↔ Lexical                      | Low      |

## Implementation Order

**Phase 1**: Violation 3 (Reader/Lexical) - Independent, lowest risk
**Phase 2**: Violation 1 (Expression.toNode) - Independent, medium risk
**Phase 3**: Violation 2 (Runtime imports) - Depends on Violation 1, highest risk

---

## Violation 3: Reader ↔ Lexical Bidirectional Coupling

### Problem

- `reader/character.dart` imports `lexical/lexeme.dart` (line 1)
- `lexical/lexeme.dart` imports `reader/character.dart` (line 2)
- Creates circular dependency

### Solution: Change `Lexeme.add()` to accept `String` instead of `Character`

### Files to Modify

**1. `lib/compiler/lexical/lexeme.dart`**

- Remove line 2: `import 'package:primal/compiler/reader/character.dart';`
- Change `Lexeme add(Character character)` to `Lexeme add(String charValue)`
- Update implementation: `value + charValue` instead of `value + character.value`

**2. `lib/compiler/lexical/lexical_analyzer.dart`**

- Update all `output.add(input)` calls to `output.add(input.value)`
- Affected locations: ~16 call sites in various State classes

### Tests

**New file**: `test/compiler/lexeme_test.dart`

- Test `add()` appends character value correctly
- Test location preservation
- Test chaining multiple `add()` calls

### Documentation

**Update `docs/compiler/lexical.md`**

- Line 73-74: Change "`.add(Character)`" to "`.add(String)`"

---

## Violation 1: Syntactic → Runtime (`Expression.toNode()`)

### Problem

- `syntactic/expression.dart` imports `runtime/node.dart` (line 3)
- Abstract `toNode()` method (line 8) creates runtime dependency
- 7 expression classes implement `toNode()` creating runtime nodes

### Solution: Move conversion logic to `Lowerer` in semantic phase

### Files to Modify

**1. `lib/compiler/semantic/lowerer.dart`**

- Add import: `import 'package:primal/compiler/syntactic/expression.dart';`
- Add new method `Node lowerExpression(Expression expression)`
- Add private helpers: `_lowerListExpression`, `_lowerMapExpression`, `_lowerCallExpression`

**2. `lib/compiler/syntactic/expression.dart`**

- Remove line 3: `import 'package:primal/compiler/runtime/node.dart';`
- Remove abstract `Node toNode();` declaration (line 8)
- Remove `toNode()` implementations from all 7 expression classes

**3. `lib/compiler/runtime/runtime.dart`**

- Update `evaluate()` method (lines 55-62) to use `Lowerer().lowerExpression(expression)`

**4. `test/helpers/assertion_helpers.dart`**

- Update `checkTypedResult()` to use `Lowerer().lowerExpression(expression)`
- Add import for `Lowerer`

### Tests

**New file**: `test/compiler/lowerer_expression_test.dart`

- Test lowering each expression type (Boolean, Number, String, List, Map, Identifier, Call)
- Test nested expressions
- Test recursive lowering

### Documentation

**Update `docs/compiler/semantic.md`**

- Add section "Expression Lowering" explaining `lowerExpression()` method
- Document use case: ad-hoc expression evaluation at runtime

---

## Violation 2: Runtime → All Phases Imports

### Problem

- `runtime/runtime.dart` imports:
  - `compiler.dart` (line 2) - for ad-hoc expression parsing
  - `semantic/intermediate_code.dart` (line 7)
  - `semantic/lowerer.dart` (line 8)
  - `syntactic/expression.dart` (line 9)

### Solution: Split Runtime into low-level executor and high-level facade

### New Files to Create

**1. `lib/compiler/runtime/runtime_input.dart`**

```dart
class RuntimeInput {
  final Map<String, FunctionNode> customFunctions;
  final Map<String, FunctionNode> standardLibrary;
  // allFunctions getter, containsFunction() method
}
```

**2. `lib/compiler/semantic/runtime_input_builder.dart`**

```dart
class RuntimeInputBuilder {
  RuntimeInput build(IntermediateCode code);  // Uses Lowerer internally
}
```

**3. `lib/compiler/runtime/runtime_facade.dart`**

```dart
class RuntimeFacade {
  // High-level operations that need Compiler access
  String executeMain([List<String>? arguments]);
  Expression mainExpression(List<String> arguments);
  String evaluate(Expression expression);
}
```

### Files to Modify

**1. `lib/compiler/runtime/runtime.dart`**

- Remove imports from compiler, semantic, syntactic phases
- Simplify to accept `RuntimeInput` only
- Keep only: `evaluateNode(Node)`, `format()`, scope management
- Move `mainExpression()` and `evaluate()` to `RuntimeFacade`

**2. `lib/compiler/compiler.dart`**

- Add `RuntimeFacade compileToRuntime(String input)` method

**3. `test/helpers/pipeline_helpers.dart`**

- Update `getRuntime()` to return `RuntimeFacade`
- Update import

**4. Entry points** (`lib/main/main_cli.dart`, `lib/main/main_web.dart`)

- Update to use `RuntimeFacade` for high-level operations

### Tests

**New file**: `test/compiler/runtime_facade_test.dart`

- Test `executeMain()` with/without arguments
- Test `hasMain` property
- Test `evaluate()` with ad-hoc expressions

**Update existing runtime tests**

- Change `Runtime` → `RuntimeFacade` where high-level operations are used

### Documentation

**Update `docs/compiler/runtime.md`**

- Document two-layer architecture: `Runtime` (low-level) and `RuntimeFacade` (high-level)
- Explain separation of concerns
- Update initialization flow diagram

---

## Verification

After each violation fix:

1. **Run tests**: `dart test`
2. **Check imports**: Verify no circular/violating imports remain
3. **Run delta-review**: `/delta-review` for code quality check

### Final Verification

```bash
# Verify no remaining violations
grep -r "import.*runtime/node" lib/compiler/syntactic/
grep -r "import.*compiler\.dart" lib/compiler/runtime/runtime.dart
grep -r "import.*character\.dart" lib/compiler/lexical/
```

---

## Summary of Changes

| Category       | Violation 3 | Violation 1 | Violation 2 |
| -------------- | ----------- | ----------- | ----------- |
| Modified files | 2           | 4           | 5+          |
| New files      | 0           | 0           | 3           |
| New test files | 1           | 1           | 1           |
| Doc updates    | 1           | 1           | 1           |
| Risk           | Low         | Medium      | High        |
| Dependencies   | None        | None        | Violation 1 |
