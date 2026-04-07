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
