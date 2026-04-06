# REPL Commands Implementation Plan

This document outlines the implementation plan for adding REPL commands to the Primal CLI. Commands are sorted from easiest to most complex.

---

## Overview of Current Architecture

- **`main_cli.dart`**: Entry point with `_runRepl()` function that handles the REPL loop
- **`Console`**: Handles input/output via `prompt()` method which loops indefinitely
- **`RuntimeFacade`**: Manages function definitions with `_userDefinedFunctions` set and `_runtimeInput.functions` map
- **`Compiler`**: Parses source code into `IntermediateRepresentation` or individual `FunctionDefinition`

---

## Commands (Sorted by Implementation Complexity)

### 10. `:load <file>` (Hard)

**Difficulty**: Hard
**Estimated Lines**: ~50

**Description**: Import definitions from a file without running main. Clears all previous definitions (reset).

**Implementation**:

1. Parse the command to extract the file path
2. Call the existing `reset()` functionality first
3. Read the file using the injected `readFile` function or `FileReader.read`
4. Compile the file using `compiler.compile(source)`
5. For each function in the `IntermediateRepresentation.customFunctions`:
   - Need to convert back to a format that can be added to the runtime
   - Or: Add a method to `RuntimeFacade` to bulk-load from an `IntermediateRepresentation`
6. Handle warnings from compilation
7. Print confirmation with count of loaded functions

**Files to Modify**:

- `lib/compiler/lowering/runtime_facade.dart` (add bulk load method)
- `lib/main/main_cli.dart` (add command handler)

**Key Challenge**: The current architecture creates a new `RuntimeFacade` from an `IntermediateRepresentation`. For `:load`, we need to merge new definitions into an existing runtime. Options:

- **Option A**: Add a method `loadFromIntermediateRepresentation(IntermediateRepresentation ir)` to `RuntimeFacade`
- **Option B**: Create a new `RuntimeFacade` and replace the existing one in `_runRepl`

**Recommended**: Option B is cleaner - recreate the runtime with the loaded file, similar to how it's done when starting the CLI with a file argument. This requires:

- Pass the `sourceReader` function to `_runRepl`
- When `:load` is called, compile the file and create a new `RuntimeFacade`

**Alternative Approach**: Keep the current runtime and iterate over each function definition from the file, calling `defineFunction()` for each. This requires converting `SemanticFunction` back to `FunctionDefinition`.

---

### 11. `:run <file>` (Hard)

**Difficulty**: Hard
**Estimated Lines**: ~60 (including `:load` reuse)

**Description**: Same as `:load` but also runs the main function if available.

**Implementation**:

1. Implement `:load` first
2. After loading, check if the runtime `hasMain`
3. If main exists, call `_executeMain` or `runtime.executeMain()`
4. Handle the case where main doesn't exist (just load, no error)

**Files to Modify**:

- Same as `:load`

**Reuse**: Most of the implementation is shared with `:load`. Consider extracting a helper function `_loadFile(String filePath)` that both commands can use.

---

## Refactoring Considerations

### Command Parser

As the number of commands grows, consider extracting command parsing into a separate class or function:

```dart
class ReplCommand {
  final String name;
  final List<String> arguments;

  static ReplCommand? parse(String input) {
    if (!input.startsWith(':')) return null;
    final parts = input.substring(1).split(' ');
    return ReplCommand(name: parts.first, arguments: parts.skip(1).toList());
  }
}
```

### RuntimeFacade Extensions

New methods to add to `RuntimeFacade`:

1. `Set<String> get userDefinedFunctions` - getter for listing
2. `Map<String, FunctionSignature> get userDefinedSignatures` - for detailed listing
3. `void reset()` - clear all user-defined functions
4. `void deleteFunction(String name)` - remove specific function
5. `void renameFunction(String oldName, String newName)` - rename function
6. `void loadFromSource(String source, Compiler compiler)` - bulk load from source

### Console Extensions

Potentially add:

1. `void clear()` - convenience method for clearing screen

---

## Implementation Order (Recommended)

1. **Phase 1 - Simple Commands** (can be done in one session):
   - `:version`
   - `:help`
   - `:quit` / `:q` / `:exit`
   - `:clear`
   - `:debug on/off`

2. **Phase 2 - Function Management** (requires RuntimeFacade changes):
   - `:list`
   - `:reset`
   - `:delete <name>`
   - `:rename <old> <new>`

3. **Phase 3 - File Operations** (requires significant changes):
   - `:load <file>`
   - `:run <file>`

---

## Testing Strategy

Each command should have unit tests covering:

1. Basic functionality (happy path)
2. Error cases (invalid arguments, non-existent functions, etc.)
3. Edge cases (empty function list, special characters in names, etc.)

Tests should use the existing `Console` injection pattern with a mock console to capture output.

---

## Error Messages

Standardize error messages for REPL commands:

```
Error: Unknown command ':foo'. Type :help for available commands.
Error: Function 'bar' does not exist.
Error: Cannot delete standard library function 'add'.
Error: Function 'baz' already exists.
Error: File not found: 'missing.pri'
Error: Usage: :delete <function_name>
```
