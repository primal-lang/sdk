@Tags(['runtime', 'io'])
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

Future<ProcessResult> runRuntimeProgram({
  required String source,
  String? input,
}) async {
  final Directory tempDir = Directory.systemTemp.createTempSync(
    'primal_console_test_',
  );
  addTearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  final Process process = await Process.start(
    Platform.resolvedExecutable,
    ['run', 'test/helpers/runtime_console_write_runner.dart', source],
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

  if (input != null) {
    process.stdin.writeln(input);
  }
  await process.stdin.close();

  final String stdout = await stdoutFuture;
  final String stderr = await stderrFuture;
  final int exitCode = await process.exitCode;

  if (exitCode != 0) {
    fail('Process exited with code $exitCode: $stderr');
  }

  return ProcessResult(process.pid, exitCode, stdout, stderr);
}

Future<String> runWithStdin(String source, String input) async {
  final ProcessResult result = await runRuntimeProgram(
    source: source,
    input: input,
  );

  expect(result.stderr.toString(), isNotEmpty);

  return result.stderr.toString().trim();
}

void main() {
  group('Console', () {
    test('console.write outputs string', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.write("Enter in function")',
      );

      expect(result.stdout.toString(), equals('Enter in function'));
      expect(result.stderr.toString().trim(), equals('"Enter in function"'));
    });

    test('console.writeLn outputs string with newline', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.writeLn("Enter in function")',
      );

      expect(result.stdout.toString(), equals('Enter in function\n'));
      expect(result.stderr.toString().trim(), equals('"Enter in function"'));
    });

    test('console.write with number argument', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.write(42)',
      );

      expect(result.stdout.toString(), equals('42'));
      expect(result.stderr.toString().trim(), equals('42'));
    });

    test('console.writeLn with boolean argument', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.writeLn(true)',
      );

      expect(result.stdout.toString(), equals('true\n'));
      expect(result.stderr.toString().trim(), equals('true'));
    });

    test('console.write with expression result', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.write(1 + 2)',
      );

      expect(result.stdout.toString(), equals('3'));
      expect(result.stderr.toString().trim(), equals('3'));
    });
  });

  group('Console Read', () {
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
