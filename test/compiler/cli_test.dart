@Tags(['compiler'])
@TestOn('vm')
library;

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import '../helpers/temp_helpers.dart';

void main() {
  group('CLI', () {
    late Directory tempDir;

    setUp(() {
      tempDir = createTempTestDirectory('primal_cli_test_');
    });

    File writeProgram(String name, String source) {
      final File file = File(path.join(tempDir.path, name));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(source);

      return file;
    }

    Future<ProcessResult> runCli(List<String> args) {
      return Process.run(
        Platform.resolvedExecutable,
        ['run', 'lib/main/main_cli.dart', ...args],
        environment: {
          'HOME': tempDir.path,
          'XDG_CONFIG_HOME': tempDir.path,
        },
      );
    }

    test('executes a file and returns result', () async {
      final ProcessResult result = await runCli([
        'test/resources/samples/factorial.prm',
      ]);

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString().trim(), isNotEmpty);
    });

    test('returns exit code 0 for valid program', () async {
      final File tmpFile = writeProgram('main.prm', 'main = 42');
      final ProcessResult result = await runCli([tmpFile.path]);

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString().trim(), equals('42'));
    });

    test('passes arguments to main function', () async {
      final File tmpFile = writeProgram('args.prm', 'main(x) = x');
      final ProcessResult result = await runCli([tmpFile.path, 'hello']);

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString().trim(), equals('"hello"'));
    });

    test('reports compilation error on stderr', () async {
      final File tmpFile = writeProgram(
        'compile_error.prm',
        'main = undefined_function(1)',
      );
      final ProcessResult result = await runCli([tmpFile.path]);

      expect(result.stderr.toString(), contains('Compilation error'));
    });

    test('reports warnings on stderr for unused parameters', () async {
      final File tmpFile = writeProgram(
        'warning.prm',
        'f(x, y) = x\nmain = f(1, 2)',
      );
      final ProcessResult result = await runCli([tmpFile.path]);

      expect(result.exitCode, equals(0));
      expect(result.stderr.toString(), contains('Warning'));
      expect(result.stdout.toString().trim(), equals('1'));
    });

    test('reports error for nonexistent file', () async {
      final String missingFile = path.join(tempDir.path, 'missing.prm');
      final ProcessResult result = await runCli([missingFile]);

      expect(result.stderr.toString(), isNotEmpty);
    });
  });
}
