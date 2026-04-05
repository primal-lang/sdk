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

    test('semantic core does not import from runtime', () {
      // These files bridge semantic → runtime and legitimately import runtime:
      // - lowerer.dart: converts SemanticNode → Term
      // - runtime_input_builder.dart: builds RuntimeInput from IntermediateRepresentation
      // - runtime_facade.dart: orchestrates runtime execution
      final List<String> violations = _checkImports(
        'lib/compiler/semantic',
        ['runtime/'],
        exclude: [
          'lowerer.dart',
          'runtime_input_builder.dart',
          'runtime_facade.dart',
        ],
      );
      expect(violations, isEmpty, reason: violations.join('\n'));
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
