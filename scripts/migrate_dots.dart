import 'dart:io';

import 'package:primal/compiler/library/standard_library.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/extensions/string_extensions.dart';

const String usage = '''
Usage: dart scripts/migrate_dots.dart [options] <path>...

Rewrites dotted identifiers in Primal source to their underscore form, so
`num.abs(-5)` becomes `num_abs(-5)`. Dots inside decimal literals, string
literals and comments are left alone. Directories are searched recursively
for `.prm` files.

A file is refused, and left untouched, when the rewrite would produce a name
the file already uses under a different spelling, when two distinct names
would collapse onto one, when the file defines a name that a standard library
function owns after the rename, or when the source ends inside an unterminated
string literal or block comment.

Options:
  --dry-run        Report what would change without writing any file
  --help, -h       Show this help
''';

/// Every option [run] accepts. Anything else starting with `-` is rejected
/// rather than ignored: silently dropping a mistyped `--dryrun` would rewrite
/// the caller's whole tree while they believed nothing was being written.
const Set<String> knownOptions = {'--dry-run', '--help', '-h'};

/// Half-open range `[start, end)` of an identifier token within a source.
class IdentifierSpan {
  final int start;
  final int end;

  const IdentifierSpan({
    required this.start,
    required this.end,
  });
}

/// The outcome of scanning a source for identifier tokens.
class ScanResult {
  final List<IdentifierSpan> spans;

  /// Set when the source ends inside a string literal or block comment.
  ///
  /// Such a source cannot be migrated safely: the unterminated construct
  /// swallows every identifier after it, so a silent "0 dots" would hide the
  /// names that were never rewritten.
  final String? unterminated;

  const ScanResult({
    required this.spans,
    this.unterminated,
  });
}

/// The outcome of migrating a single source.
///
/// A refusal carries the original [source] unchanged and a non-empty
/// [collisions] list describing why the rewrite was not applied.
class MigrationResult {
  final String source;
  final int replacements;
  final List<String> collisions;

  const MigrationResult({
    required this.source,
    required this.replacements,
    this.collisions = const [],
  });

  bool get isRefused => collisions.isNotEmpty;
}

/// The dotted spelling of [name] rewritten to its underscore form.
///
/// Idempotent, so it can be applied to names that have already been migrated.
String underscored(String name) => name.replaceAll('.', '_');

/// Every standard library name, as it exists after the rename.
///
/// Read from [StandardLibrary] rather than from a hard-coded table, so the
/// tool cannot drift from the library it validates against.
Set<String> standardLibraryNames() => StandardLibrary.get()
    .map((FunctionTerm function) => underscored(function.name))
    .toSet();

/// Scans [source] for identifier tokens, using the lexing rules that were in
/// force *before* the dot was removed from the identifier character set.
///
/// Numbers, string literals, comments and a leading shebang line are skipped,
/// so a dot in `1.5`, in `"a.b"` or in `// i.e. foo` is never reported.
ScanResult scan(String source) {
  final List<IdentifierSpan> result = [];
  final int length = source.length;
  int index = _shebangEnd(source);

  while (index < length) {
    final String character = source[index];

    if (character.isLetter) {
      final int start = index;

      while ((index < length) && _isIdentifierPart(source[index])) {
        index++;
      }

      result.add(IdentifierSpan(start: start, end: index));
    } else if (character.isDigit) {
      index = _skipNumber(source, index);
    } else if (character.isSingleQuote || character.isDoubleQuote) {
      final int next = _skipString(source, index);

      if (next == _unterminated) {
        return ScanResult(
          spans: result,
          unterminated:
              'the source ends inside a string literal opened at '
              '${_locationOf(source, index)}',
        );
      }

      index = next;
    } else if (_startsLineComment(source, index)) {
      index = _skipLineComment(source, index);
    } else if (_startsBlockComment(source, index)) {
      final int next = _skipBlockComment(source, index);

      if (next == _unterminated) {
        return ScanResult(
          spans: result,
          unterminated:
              'the source ends inside a block comment opened at '
              '${_locationOf(source, index)}',
        );
      }

      index = next;
    } else {
      index++;
    }
  }

  return ScanResult(spans: result);
}

/// Returns the span of every identifier token in [source].
///
/// Identifiers after an unterminated string or block comment are not reported;
/// use [scan] when that distinction matters.
List<IdentifierSpan> identifierSpans(String source) => scan(source).spans;

/// The names [source] defines, in their post-rewrite form.
///
/// A definition is an identifier followed by a parenthesised parameter list
/// and a single `=`, which is the only shape `SyntacticAnalyzer` accepts.
Set<String> definedNames(String source) {
  final Set<String> result = {};

  for (final IdentifierSpan span in identifierSpans(source)) {
    if (_isDefinitionAt(source, span)) {
      result.add(underscored(source.substring(span.start, span.end)));
    }
  }

  return result;
}

/// Rewrites every dotted identifier in [source] to its underscore form.
///
/// Pass [libraryNames] to avoid rebuilding the standard library for every
/// file in a sweep.
MigrationResult migrate(String source, {Set<String>? libraryNames}) {
  final Set<String> library = libraryNames ?? standardLibraryNames();
  final ScanResult scanned = scan(source);

  if (scanned.unterminated != null) {
    return MigrationResult(
      source: source,
      replacements: 0,
      collisions: [scanned.unterminated!],
    );
  }

  final List<IdentifierSpan> spans = scanned.spans;

  // Names already spelled without a dot: what a rewritten name can collide
  // with inside this file.
  final Set<String> undotted = {};
  // Rewritten name -> every dotted spelling that produces it. More than one
  // means two distinct names collapse onto a single one.
  final Map<String, Set<String>> produced = {};
  final Set<String> defined = {};

  for (final IdentifierSpan span in spans) {
    final String name = source.substring(span.start, span.end);
    final String renamed = underscored(name);

    if (name.contains('.')) {
      produced.putIfAbsent(renamed, () => <String>{}).add(name);
    } else {
      undotted.add(name);
    }

    if (_isDefinitionAt(source, span)) {
      defined.add(renamed);
    }
  }

  final List<String> collisions = [];

  for (final MapEntry<String, Set<String>> entry in produced.entries) {
    final String renamed = entry.key;
    final List<String> spellings = entry.value.toList()..sort();

    if (spellings.length > 1) {
      collisions.add(
        '${spellings.map((String name) => '"$name"').join(' and ')} would '
        'both become "$renamed"',
      );
    }

    // A file part-way through migration may spell the same standard library
    // function both ways. Both denote the same function afterwards, so that
    // is not a collision — unless the file also defines the name itself,
    // which the standard library check below reports.
    if (undotted.contains(renamed) &&
        !(library.contains(renamed) && !defined.contains(renamed))) {
      collisions.add(
        '"${spellings.first}" would become "$renamed", which this file '
        'already uses',
      );
    }
  }

  for (final String name in defined) {
    if (library.contains(name)) {
      collisions.add(
        '"$name" is defined here, but is a standard library function after '
        'the rename',
      );
    }
  }

  if (collisions.isNotEmpty) {
    collisions.sort();

    return MigrationResult(
      source: source,
      replacements: 0,
      collisions: collisions,
    );
  }

  final StringBuffer buffer = StringBuffer();
  int cursor = 0;
  int replacements = 0;

  for (final IdentifierSpan span in spans) {
    final String name = source.substring(span.start, span.end);

    if (!name.contains('.')) {
      continue;
    }

    buffer
      ..write(source.substring(cursor, span.start))
      ..write(underscored(name));
    replacements += '.'.allMatches(name).length;
    cursor = span.end;
  }

  buffer.write(source.substring(cursor));

  return MigrationResult(
    source: buffer.toString(),
    replacements: replacements,
  );
}

/// Returned by [_skipString] and [_skipBlockComment] when the construct is
/// never closed. Valid results are always greater than the start index.
const int _unterminated = -1;

/// A `[row, column]` label for [index], for diagnostics.
///
/// Counts `\n`, `\r\n` and a lone `\r` as one line break each, so the label
/// matches what [SourceReader] would report after normalisation.
String _locationOf(String source, int index) {
  int row = 1;
  int lineStart = 0;

  for (int position = 0; position < index; position++) {
    final String character = source[position];
    final bool isBreak =
        character.isNewLine ||
        ((character == '\r') &&
            ((position + 1 >= source.length) ||
                !source[position + 1].isNewLine));

    if (isBreak) {
      row++;
      lineStart = position + 1;
    }
  }

  return '[$row, ${index - lineStart + 1}]';
}

/// The index of the first line terminator at or after [start].
///
/// Matches [SourceReader], which normalises `\r\n` and a lone `\r` to `\n`
/// before the lexer ever runs.
int _lineEnd(String source, int start) {
  for (int index = start; index < source.length; index++) {
    if (source[index].isNewLine || (source[index] == '\r')) {
      return index;
    }
  }

  return source.length;
}

/// The pre-change identifier continuation rule.
///
/// The dot is still included here: the migrator has to recognise the very
/// names it is about to rewrite.
bool _isIdentifierPart(String character) =>
    character.isLetter ||
    character.isDigit ||
    character.isDot ||
    character.isUnderscore;

/// Skips a leading `#!` line, matching [SourceReader].
int _shebangEnd(String source) {
  if (!source.startsWith('#!')) {
    return 0;
  }

  return _lineEnd(source, 0);
}

int _skipDigits(String source, int start) {
  int index = start;

  while ((index < source.length) &&
      (source[index].isDigit || source[index].isUnderscore)) {
    index++;
  }

  return index;
}

int _skipNumber(String source, int start) {
  final int length = source.length;
  int index = _skipDigits(source, start);

  // The dot belongs to the number only when a digit follows it, matching
  // DecimalInitState in the lexical analyzer.
  if ((index < length) &&
      source[index].isDot &&
      (index + 1 < length) &&
      source[index + 1].isDigit) {
    index = _skipDigits(source, index + 1);
  }

  if ((index < length) && source[index].isExponent) {
    int exponent = index + 1;

    if ((exponent < length) &&
        (source[exponent].isPlus || source[exponent].isMinus)) {
      exponent++;
    }

    if ((exponent < length) && source[exponent].isDigit) {
      index = _skipDigits(source, exponent);
    }
  }

  return index;
}

/// Returns the index after the closing quote, or [_unterminated].
int _skipString(String source, int start) {
  final int length = source.length;
  final String quote = source[start];
  int index = start + 1;

  while (index < length) {
    if (source[index].isBackslash) {
      index += 2;
    } else if (source[index] == quote) {
      return index + 1;
    } else {
      index++;
    }
  }

  return _unterminated;
}

bool _startsLineComment(String source, int index) =>
    source.startsWith('//', index);

int _skipLineComment(String source, int start) => _lineEnd(source, start);

bool _startsBlockComment(String source, int index) =>
    source.startsWith('/*', index);

/// Returns the index after the closing `*/`, or [_unterminated].
int _skipBlockComment(String source, int start) {
  final int index = source.indexOf('*/', start + 2);

  return (index == -1) ? _unterminated : index + 2;
}

/// Skips whitespace and comments starting at [start].
int _skipTrivia(String source, int start) {
  final int length = source.length;
  int index = start;

  while (index < length) {
    if (source[index].isWhitespace) {
      index++;
    } else if (_startsLineComment(source, index)) {
      index = _skipLineComment(source, index);
    } else if (_startsBlockComment(source, index)) {
      index = _skipBlockComment(source, index);
    } else {
      return index;
    }
  }

  return length;
}

/// Whether the identifier at [span] is the name of a function definition.
bool _isDefinitionAt(String source, IdentifierSpan span) {
  final int length = source.length;
  int index = _skipTrivia(source, span.end);

  if ((index >= length) || !source[index].isOpenParenthesis) {
    return false;
  }

  index = _skipTrivia(source, index + 1);

  while ((index < length) && !source[index].isCloseParenthesis) {
    if (source[index].isLetter) {
      while ((index < length) && _isIdentifierPart(source[index])) {
        index++;
      }
    } else if (source[index].isComma) {
      index++;
    } else {
      return false;
    }

    index = _skipTrivia(source, index);
  }

  if (index >= length) {
    return false;
  }

  index = _skipTrivia(source, index + 1);

  // A single `=`: `==`, `>=`, `<=` and `!=` are comparisons, not definitions.
  return (index < length) &&
      source[index].isEquals &&
      ((index + 1 >= length) || !source[index + 1].isEquals);
}

/// Collects the `.prm` files under [paths].
///
/// Directories that cannot be listed are reported into [failures] rather than
/// aborting the sweep, so one unreadable subtree does not hide every other
/// file's result.
List<File> _collect(List<String> paths, List<String> failures) {
  final List<File> result = [];

  for (final String path in paths) {
    if (FileSystemEntity.isDirectorySync(path)) {
      try {
        result.addAll(
          // followLinks: false — a symlink loop would otherwise never end.
          Directory(path)
              .listSync(recursive: true, followLinks: false)
              .whereType<File>()
              .where((File file) => file.path.endsWith('.prm')),
        );
      } on FileSystemException catch (error) {
        failures.add('cannot list $path: ${error.message}');
      }
    } else {
      result.add(File(path));
    }
  }

  result.sort((File a, File b) => a.path.compareTo(b.path));

  return result;
}

int run(List<String> arguments) {
  if (arguments.contains('--help') || arguments.contains('-h')) {
    stdout.write(usage);

    return 0;
  }

  for (final String argument in arguments) {
    if (argument.startsWith('-') && !knownOptions.contains(argument)) {
      stderr.writeln('Error: unknown option: $argument');
      stderr.write(usage);

      return 2;
    }
  }

  final bool dryRun = arguments.contains('--dry-run');
  final List<String> paths = arguments
      .where((String argument) => !argument.startsWith('-'))
      .toList();

  if (paths.isEmpty) {
    stderr.write(usage);

    return 2;
  }

  for (final String path in paths) {
    if (!FileSystemEntity.isDirectorySync(path) &&
        !FileSystemEntity.isFileSync(path)) {
      stderr.writeln('Error: no such file or directory: $path');

      return 2;
    }
  }

  final Set<String> library = standardLibraryNames();
  final List<String> failures = [];
  final List<File> files = _collect(paths, failures);
  int totalReplacements = 0;
  int changedFiles = 0;
  int refusedFiles = 0;

  for (final File file in files) {
    final String source;

    // Read and write are guarded per file: an unreadable file, non-UTF-8
    // content, or a read-only target must not abort a sweep that has already
    // rewritten earlier files.
    try {
      source = file.readAsStringSync();
    } on FileSystemException catch (error) {
      failures.add('cannot read ${file.path}: ${error.message}');
      continue;
    }

    final MigrationResult result = migrate(source, libraryNames: library);

    if (result.isRefused) {
      refusedFiles++;
      stderr.writeln('REFUSED ${file.path}');

      for (final String collision in result.collisions) {
        stderr.writeln('  $collision');
      }

      continue;
    }

    if (result.replacements == 0) {
      continue;
    }

    if (!dryRun) {
      try {
        file.writeAsStringSync(result.source);
      } on FileSystemException catch (error) {
        failures.add('cannot write ${file.path}: ${error.message}');
        continue;
      }
    }

    changedFiles++;
    totalReplacements += result.replacements;
    stdout.writeln(
      '${dryRun ? 'would rewrite' : 'rewrote'} ${result.replacements} '
      'dot(s) in ${file.path}',
    );
  }

  stdout.writeln(
    '$totalReplacements dot(s) across $changedFiles of ${files.length} file(s)',
  );

  if (refusedFiles > 0) {
    stderr.writeln('$refusedFiles file(s) refused');
  }

  for (final String failure in failures) {
    stderr.writeln('Error: $failure');
  }

  return ((refusedFiles > 0) || failures.isNotEmpty) ? 1 : 0;
}

void main(List<String> arguments) {
  exitCode = run(arguments);
}
