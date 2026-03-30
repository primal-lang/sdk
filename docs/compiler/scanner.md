# Scanner

**File**: `lib/compiler/scanner/scanner_analyzer.dart`

The scanner is the first stage of the compiler pipeline. It converts a raw input string into a flat list of `Character` objects, each annotated with its row and column position.

## Pipeline Contract

`Scanner` extends `Analyzer<String, List<Character>>`, conforming to the generic `Analyzer` interface shared by all compiler stages. Both `Scanner` and `Character` use `const` constructors; the output list is the only mutable structure.

## Splitting Strategy

The scanner first normalizes line endings by converting `\r\n` and `\r` to `\n`, then splits into rows. If the final row is empty (trailing newline in source), it is removed before processing. The scanner then iterates rune-by-rune within each row using Unicode rune iteration. Each rune is wrapped in a `Character(value, location)`.

## Location Tracking

Row and column positions are 1-based, matching how editors display positions. `Character` extends the `Localized` base class, which holds a `Location(row, column)` shared across compiler models.

## Shebang Handling

If the first row starts with `#!`, the entire line is skipped. No characters from a shebang line appear in the output.

## Newline Injection

A `\n` character is appended after every non-skipped row, including the last. This means the output always ends with a newline, even if the source did not, so downstream stages can rely on consistent line boundaries.

## Output

The output preserves every character from the source (including whitespace), with location information used later for error reporting. `Character` provides a `get lexeme` getter that converts it to a `Lexeme`, bridging directly into the lexical analyzer.
