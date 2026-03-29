@Tags(['compiler'])
@TestOn('vm')
library;

import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('CLI', () {
    test('executes a file and returns result', () async {
      final result = await Process.run('dart', [
        'run',
        'lib/main/main_cli.dart',
        'example/factorial.prm',
      ]);

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString().trim(), isNotEmpty);
    });

    test('returns exit code 0 for valid program', () async {
      final tmpFile = File('.test_cli_tmp.prm');
      tmpFile.writeAsStringSync('main = 42');

      try {
        final result = await Process.run('dart', [
          'run',
          'lib/main/main_cli.dart',
          tmpFile.path,
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('42'));
      } finally {
        tmpFile.deleteSync();
      }
    });

    test('passes arguments to main function', () async {
      final tmpFile = File('.test_cli_args.prm');
      tmpFile.writeAsStringSync('main(x) = x');

      try {
        final result = await Process.run('dart', [
          'run',
          'lib/main/main_cli.dart',
          tmpFile.path,
          'hello',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('"hello"'));
      } finally {
        tmpFile.deleteSync();
      }
    });

    test('reports compilation error on stderr', () async {
      final tmpFile = File('.test_cli_err.prm');
      tmpFile.writeAsStringSync('main = undefined_function(1)');

      try {
        final result = await Process.run('dart', [
          'run',
          'lib/main/main_cli.dart',
          tmpFile.path,
        ]);

        expect(result.stderr.toString(), contains('Compilation error'));
      } finally {
        tmpFile.deleteSync();
      }
    });

    test('reports warnings on stderr for unused parameters', () async {
      final tmpFile = File('.test_cli_warn.prm');
      tmpFile.writeAsStringSync('f(x, y) = x\nmain = f(1, 2)');

      try {
        final result = await Process.run('dart', [
          'run',
          'lib/main/main_cli.dart',
          tmpFile.path,
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stderr.toString(), contains('Warning'));
        expect(result.stdout.toString().trim(), equals('1'));
      } finally {
        tmpFile.deleteSync();
      }
    });

    test('reports error for nonexistent file', () async {
      final result = await Process.run('dart', [
        'run',
        'lib/main/main_cli.dart',
        'nonexistent_file.prm',
      ]);

      expect(result.stderr.toString(), isNotEmpty);
    });
  });
}
