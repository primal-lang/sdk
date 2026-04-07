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

    test('console.write with boolean false', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.write(false)',
      );

      expect(result.stdout.toString(), equals('false'));
      expect(result.stderr.toString().trim(), equals('false'));
    });

    test('console.write with negative number', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.write(-42)',
      );

      expect(result.stdout.toString(), equals('-42'));
      expect(result.stderr.toString().trim(), equals('-42'));
    });

    test('console.write with floating point number', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.write(3.14)',
      );

      expect(result.stdout.toString(), equals('3.14'));
      expect(result.stderr.toString().trim(), equals('3.14'));
    });

    test('console.write with empty string', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.write("")',
      );

      expect(result.stdout.toString(), equals(''));
      expect(result.stderr.toString().trim(), equals('""'));
    });

    test('console.write with list', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.write([1, 2, 3])',
      );

      expect(result.stdout.toString(), equals('[1, 2, 3]'));
      expect(result.stderr.toString().trim(), equals('[1, 2, 3]'));
    });

    test('console.writeLn with number argument', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.writeLn(42)',
      );

      expect(result.stdout.toString(), equals('42\n'));
      expect(result.stderr.toString().trim(), equals('42'));
    });

    test('console.writeLn with boolean false', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.writeLn(false)',
      );

      expect(result.stdout.toString(), equals('false\n'));
      expect(result.stderr.toString().trim(), equals('false'));
    });

    test('console.writeLn with expression result', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.writeLn(2 * 3)',
      );

      expect(result.stdout.toString(), equals('6\n'));
      expect(result.stderr.toString().trim(), equals('6'));
    });

    test('console.writeLn with floating point number', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.writeLn(2.718)',
      );

      expect(result.stdout.toString(), equals('2.718\n'));
      expect(result.stderr.toString().trim(), equals('2.718'));
    });

    test('console.writeLn with empty string', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.writeLn("")',
      );

      expect(result.stdout.toString(), equals('\n'));
      expect(result.stderr.toString().trim(), equals('""'));
    });

    test('console.writeLn with list', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.writeLn([1, 2, 3])',
      );

      expect(result.stdout.toString(), equals('[1, 2, 3]\n'));
      expect(result.stderr.toString().trim(), equals('[1, 2, 3]'));
    });

    test('console.write with string containing spaces', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = console.write("hello world")',
      );

      expect(result.stdout.toString(), equals('hello world'));
      expect(result.stderr.toString().trim(), equals('"hello world"'));
    });

    test('console.write returns its argument', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = num.add(console.write(5), 10)',
      );

      expect(result.stdout.toString(), equals('5'));
      expect(result.stderr.toString().trim(), equals('15'));
    });

    test('console.writeLn returns its argument', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main = num.add(console.writeLn(5), 10)',
      );

      expect(result.stdout.toString(), equals('5\n'));
      expect(result.stderr.toString().trim(), equals('15'));
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

    test('console.read reads string with spaces', () async {
      final String result = await runWithStdin(
        'main = console.read()',
        'hello world',
      );
      expect(result, equals('"hello world"'));
    });

    test('console.read reads string with special characters', () async {
      final String result = await runWithStdin(
        'main = console.read()',
        'hello!@#\$%',
      );
      expect(result, equals('"hello!@#\$%"'));
    });

    test('console.read reads numeric string', () async {
      final String result = await runWithStdin(
        'main = console.read()',
        '12345',
      );
      expect(result, equals('"12345"'));
    });

    test('console.read can be used with string concatenation', () async {
      final String result = await runWithStdin(
        'main = str.concat("prefix-", console.read())',
        'suffix',
      );
      expect(result, equals('"prefix-suffix"'));
    });
  });
}
