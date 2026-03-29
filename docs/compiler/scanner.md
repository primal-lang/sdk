# Scanner

**File**: `lib/compiler/scanner/scanner_analyzer.dart`

The scanner converts a raw input string into a flat list of `Character` objects, each annotated with its row and column position.

- Iterates over UTF-8 runes and wraps each in a `Character(value, row, column)`.
- Handles shebang lines (`#!` on the first line) by skipping them.
- Injects newline characters between rows so downstream stages can rely on consistent line boundaries.

The output preserves every character from the source (including whitespace), with location information used later for error reporting.
