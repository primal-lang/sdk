# SourceReader

**File**: `lib/compiler/reader/reader.dart`

The source reader is the first stage of the compiler pipeline. It converts a raw input string into a flat list of `Character` objects, each annotated with its row and column position.

## Pipeline Contract

`SourceReader` extends `Analyzer<String, List<Character>>`, conforming to the generic `Analyzer` interface shared by all compiler stages. Both `SourceReader` and `Character` use `const` constructors; the output list is the only mutable structure.

## Splitting Strategy

The reader first normalizes line endings by converting `\r\n` and `\r` to `\n`, then splits into rows. If the final row is empty (trailing newline in source), it is removed before processing. It then iterates by grapheme cluster within each row using `package:characters`. This ensures that multi-codepoint sequences like emoji (e.g., `💾`) are treated as single characters with correct column positions. Each grapheme is wrapped in a `Character(value, location)`. Tab characters are treated as single characters occupying one column, not expanded to spaces.

## Location Tracking

Row and column positions are 1-based, matching how editors display positions. `Character` extends the `Located` base class, which holds a `Location(row, column)` shared across compiler models.

## Shebang Handling

If the first row starts with `#!`, the entire line is skipped. No characters from a shebang line appear in the output.

## Newline Injection

A `\n` character is appended after every non-skipped row, including the last. This means the output always ends with a newline, even if the source did not, so downstream stages can rely on consistent line boundaries.

## Output

The output preserves every character from the source (including whitespace), with location information used later for error reporting. Both `Character` and `Location` support value equality (`==` and `hashCode`), making them suitable for use in tests and collections. `Character.toString()` returns the value and its location (e.g., `"a" at [1, 1]`).
