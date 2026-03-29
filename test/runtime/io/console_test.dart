@Tags(['runtime', 'io'])
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:primal/compiler/runtime/runtime.dart';
import 'package:test/test.dart';
import '../../helpers/assertion_helpers.dart';
import '../../helpers/pipeline_helpers.dart';

void main() {
  group('Console', () {
    test('console.write outputs string', () {
      final Runtime runtime = getRuntime(
        'main = console.write("Enter in function")',
      );
      checkResult(runtime, '"Enter in function"');
    });

    test('console.writeLn outputs string with newline', () {
      final Runtime runtime = getRuntime(
        'main = console.writeLn("Enter in function")',
      );
      checkResult(runtime, '"Enter in function"');
    });

    test('console.write with number argument', () {
      final Runtime runtime = getRuntime('main = console.write(42)');
      checkResult(runtime, 42);
    });

    test('console.writeLn with boolean argument', () {
      final Runtime runtime = getRuntime('main = console.writeLn(true)');
      checkResult(runtime, true);
    });

    test('console.write with expression result', () {
      final Runtime runtime = getRuntime(
        'main = console.write(1 + 2)',
      );
      checkResult(runtime, 3);
    });
  });

  group('Console Read', () {
    Future<String> runWithStdin(String source, String input) async {
      final Directory tempDir = Directory.systemTemp.createTempSync(
        'primal_console_read_',
      );
      addTearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/console_read_runner.dart', source],
        environment: {
          'HOME': tempDir.path,
          'XDG_CONFIG_HOME': tempDir.path,
        },
      );

      final Future<String> stdoutFuture = process.stdout
          .transform(
            utf8.decoder,
          )
          .join();
      final Future<String> stderrFuture = process.stderr
          .transform(
            utf8.decoder,
          )
          .join();

      process.stdin.writeln(input);
      await process.stdin.close();

      final String stdout = await stdoutFuture;
      final String stderr = await stderrFuture;
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      return stdout.trim();
    }

    test('console.read reads string from stdin', () async {
      final String result = await runWithStdin(
        'main = console.read()',
        'hello',
      );
      expect(result, equals('"hello"'));
    });

    test('console.read reads empty line from stdin', () async {
      final String result = await runWithStdin(
        'main = console.read()',
        '',
      );
      expect(result, equals('""'));
    });

    test('console.read result can be used in expressions', () async {
      final String result = await runWithStdin(
        'main = str.length(console.read())',
        'hello',
      );
      expect(result, equals('5'));
    });
  });
}
