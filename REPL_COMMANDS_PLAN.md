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
