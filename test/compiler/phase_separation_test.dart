/// Tests that verify clean phase separation in the compiler.
///
/// These tests check that each phase only imports from:
/// - Its own files
/// - Previous phases
/// - Shared models
@Tags(['compiler'])
library;

import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('Phase Separation', () {
    test(
      'reader does not import from lexical, syntactic, semantic, or runtime',
      () {
        final List<String> violations = _checkImports('lib/compiler/reader', [
          'lexical/',
          'syntactic/',
          'semantic/',
          'runtime/',
        ]);
        expect(violations, isEmpty, reason: violations.join('\n'));
      },
    );

    test('lexical does not import from syntactic, semantic, or runtime', () {
      final List<String> violations = _checkImports('lib/compiler/lexical', [
        'syntactic/',
        'semantic/',
        'runtime/',
      ]);
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('syntactic does not import from semantic or runtime', () {
      final List<String> violations = _checkImports('lib/compiler/syntactic', [
        'semantic/',
        'runtime/',
      ]);
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('semantic does not import from runtime', () {
      final List<String> violations = _checkImports(
        'lib/compiler/semantic',
        ['runtime/'],
      );
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('runtime does not import from reader, lexical, or syntactic', () {
      final List<String> violations = _checkImports('lib/compiler/runtime', [
        'reader/',
        'lexical/',
        'syntactic/',
      ]);
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('lowering core does not import from reader or lexical', () {
      // The lowering phase bridges semantic → runtime
      // runtime_facade.dart legitimately imports from syntactic/ to accept
      // Expression and FunctionDefinition as inputs from the compiler pipeline
      final List<String> violations = _checkImports(
        'lib/compiler/lowering',
        ['reader/', 'lexical/'],
      );
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('lowering core does not import from syntactic', () {
      // Exclude runtime_facade.dart which serves as the pipeline entry point
      // and needs to accept syntactic types
      final List<String> violations = _checkImports(
        'lib/compiler/lowering',
        ['syntactic/'],
        exclude: ['runtime_facade.dart'],
      );
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('library does not import from reader, lexical, or syntactic', () {
      // Library functions are runtime implementations
      // They should not depend on compilation phases
      final List<String> violations = _checkImports('lib/compiler/library', [
        'reader/',
        'lexical/',
        'syntactic/',
      ]);
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('errors does not import from runtime', () {
      // Error definitions should not depend on runtime
      // to avoid circular dependencies
      final List<String> violations = _checkImports(
        'lib/compiler/errors',
        ['runtime/'],
        exclude: ['runtime_error.dart'],
      );
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('models does not import from any compiler phase', () {
      // Models are shared utilities and should not depend on compiler phases
      final List<String> violations = _checkImports('lib/compiler/models', [
        'reader/',
        'lexical/',
        'syntactic/',
        'semantic/',
        'runtime/',
        'lowering/',
        'library/',
      ]);
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('warnings does not import from runtime or lowering', () {
      // Warnings are compile-time messages, should not depend on runtime
      final List<String> violations = _checkImports('lib/compiler/warnings', [
        'runtime/',
        'lowering/',
      ]);
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('platform does not import from reader, lexical, or syntactic', () {
      // Platform abstractions are used by runtime, should not depend on parsing phases
      final List<String> violations = _checkImports('lib/compiler/platform', [
        'reader/',
        'lexical/',
        'syntactic/',
      ]);
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('errors does not import from lexical, syntactic, or semantic', () {
      // Error definitions should only depend on models, not specific phases
      // to avoid circular dependencies (phases import errors, not vice versa)
      final List<String> violations = _checkImports(
        'lib/compiler/errors',
        ['lexical/', 'syntactic/', 'semantic/'],
        exclude: [
          'lexical_error.dart',
          'syntactic_error.dart',
          'semantic_error.dart',
        ],
      );
      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });

  group('_checkImports helper', () {
    test('returns error message for non-existent directory', () {
      final List<String> result = _checkImports(
        'lib/compiler/nonexistent_directory',
        ['something/'],
      );
      expect(result, hasLength(1));
      expect(
        result.first,
        contains('Directory does not exist'),
      );
    });

    test('returns empty list when no forbidden imports found', () {
      // reader/ exists and should have no imports from its own forbidden list
      final List<String> result = _checkImports('lib/compiler/reader', [
        'some_nonexistent_path/',
      ]);
      expect(result, isEmpty);
    });

    test('excludes specified files from checking', () {
      // This test verifies the exclude parameter works correctly
      // by excluding all dart files in reader that import from models/
      final List<String> result = _checkImports(
        'lib/compiler/reader',
        ['models/'], // reader imports from models
        exclude: ['source_reader.dart', 'character.dart'],
      );
      expect(result, isEmpty);
    });

    test('returns empty list when forbidden list is empty', () {
      final List<String> result = _checkImports('lib/compiler/reader', []);
      expect(result, isEmpty);
    });

    test('handles directory with subdirectories recursively', () {
      // library/ has many subdirectories (arithmetic, casting, etc.)
      // This test verifies recursive checking works
      final List<String> result = _checkImports(
        'lib/compiler/library',
        ['reader/'], // library should not import from reader
      );
      expect(result, isEmpty);
    });

    test('detects multiple violations in the same file', () {
      // lowering imports from both syntactic and semantic
      // If we didn't exclude runtime_facade.dart, we'd catch syntactic imports
      final List<String> result = _checkImports('lib/compiler/lowering', [
        'syntactic/',
        'semantic/',
      ]);
      // runtime_facade.dart imports from both, so we should find violations
      expect(result, isNotEmpty);
      // Verify we found violations from both forbidden paths
      final bool hasSyntacticViolation = result.any(
        (String violation) => violation.contains('syntactic/'),
      );
      final bool hasSemanticViolation = result.any(
        (String violation) => violation.contains('semantic/'),
      );
      expect(hasSyntacticViolation, isTrue);
      expect(hasSemanticViolation, isTrue);
    });

    test('reports correct file path and line number in violation', () {
      // Use lowering without exclusions to get predictable violations
      final List<String> result = _checkImports('lib/compiler/lowering', [
        'syntactic/',
      ]);
      expect(result, isNotEmpty);
      // Check that violation message contains file path with line number
      expect(result.first, contains('lib/compiler/lowering/'));
      expect(result.first, contains('.dart:'));
      expect(result.first, contains('imports forbidden path'));
    });

    test('handles files with no import statements', () {
      // models/analyzer.dart has no imports
      final List<String> result = _checkImports('lib/compiler/models', [
        'runtime/',
      ]);
      // Should complete without error and find no violations
      expect(result, isEmpty);
    });

    test('only checks lines starting with import keyword', () {
      // Ensure comments or strings containing forbidden paths are not flagged
      // The reader directory files don't contain 'runtime/' in comments
      // This test verifies the import-only filtering
      final List<String> result = _checkImports(
        'lib/compiler/reader',
        ['runtime/'],
      );
      expect(result, isEmpty);
    });
  });
}

List<String> _checkImports(
  String directoryPath,
  List<String> forbidden, {
  List<String> exclude = const [],
}) {
  final List<String> violations = [];
  final Directory directory = Directory(directoryPath);

  if (!directory.existsSync()) {
    return ['Directory does not exist: $directoryPath'];
  }

  for (final FileSystemEntity entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      // Check if this file should be excluded
      final String fileName = entity.path.split('/').last;
      if (exclude.contains(fileName)) {
        continue;
      }

      final String content = entity.readAsStringSync();
      final List<String> lines = content.split('\n');

      for (int i = 0; i < lines.length; i++) {
        final String line = lines[i].trim();

        // Skip non-import lines
        if (!line.startsWith('import ')) {
          continue;
        }

        // Check for forbidden imports
        for (final String forbiddenPath in forbidden) {
          if (line.contains(forbiddenPath)) {
            violations.add(
              '${entity.path}:${i + 1}: imports forbidden path "$forbiddenPath"\n'
              '  $line',
            );
          }
        }
      }
    }
  }

  return violations;
}
