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
    test('console_write outputs string', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write("Enter in function")',
      );

      expect(result.stdout.toString(), equals('Enter in function'));
      expect(result.stderr.toString().trim(), equals('"Enter in function"'));
    });

    test('console_writeLn outputs string with newline', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn("Enter in function")',
      );

      expect(result.stdout.toString(), equals('Enter in function\n'));
      expect(result.stderr.toString().trim(), equals('"Enter in function"'));
    });

    test('console_write with number argument', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write(42)',
      );

      expect(result.stdout.toString(), equals('42'));
      expect(result.stderr.toString().trim(), equals('42'));
    });

    test('console_writeLn with boolean argument', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn(true)',
      );

      expect(result.stdout.toString(), equals('true\n'));
      expect(result.stderr.toString().trim(), equals('true'));
    });

    test('console_write with expression result', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write(1 + 2)',
      );

      expect(result.stdout.toString(), equals('3'));
      expect(result.stderr.toString().trim(), equals('3'));
    });

    test('console_write with boolean false', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write(false)',
      );

      expect(result.stdout.toString(), equals('false'));
      expect(result.stderr.toString().trim(), equals('false'));
    });

    test('console_write with negative number', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write(-42)',
      );

      expect(result.stdout.toString(), equals('-42'));
      expect(result.stderr.toString().trim(), equals('-42'));
    });

    test('console_write with floating point number', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write(3.14)',
      );

      expect(result.stdout.toString(), equals('3.14'));
      expect(result.stderr.toString().trim(), equals('3.14'));
    });

    test('console_write with empty string', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write("")',
      );

      expect(result.stdout.toString(), equals(''));
      expect(result.stderr.toString().trim(), equals('""'));
    });

    test('console_write with list', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write([1, 2, 3])',
      );

      expect(result.stdout.toString(), equals('[1, 2, 3]'));
      expect(result.stderr.toString().trim(), equals('[1, 2, 3]'));
    });

    test('console_writeLn with number argument', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn(42)',
      );

      expect(result.stdout.toString(), equals('42\n'));
      expect(result.stderr.toString().trim(), equals('42'));
    });

    test('console_writeLn with boolean false', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn(false)',
      );

      expect(result.stdout.toString(), equals('false\n'));
      expect(result.stderr.toString().trim(), equals('false'));
    });

    test('console_writeLn with expression result', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn(2 * 3)',
      );

      expect(result.stdout.toString(), equals('6\n'));
      expect(result.stderr.toString().trim(), equals('6'));
    });

    test('console_writeLn with floating point number', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn(2.718)',
      );

      expect(result.stdout.toString(), equals('2.718\n'));
      expect(result.stderr.toString().trim(), equals('2.718'));
    });

    test('console_writeLn with empty string', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn("")',
      );

      expect(result.stdout.toString(), equals('\n'));
      expect(result.stderr.toString().trim(), equals('""'));
    });

    test('console_writeLn with list', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn([1, 2, 3])',
      );

      expect(result.stdout.toString(), equals('[1, 2, 3]\n'));
      expect(result.stderr.toString().trim(), equals('[1, 2, 3]'));
    });

    test('console_write with string containing spaces', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write("hello world")',
      );

      expect(result.stdout.toString(), equals('hello world'));
      expect(result.stderr.toString().trim(), equals('"hello world"'));
    });

    test('console_write returns its argument', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = num_add(console_write(5), 10)',
      );

      expect(result.stdout.toString(), equals('5'));
      expect(result.stderr.toString().trim(), equals('15'));
    });

    test('console_writeLn returns its argument', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = num_add(console_writeLn(5), 10)',
      );

      expect(result.stdout.toString(), equals('5\n'));
      expect(result.stderr.toString().trim(), equals('15'));
    });
  });

  group('Console Read', () {
    test('console_read reads string from stdin', () async {
      final String result = await runWithStdin(
        'main() = console_read()',
        'hello',
      );
      expect(result, equals('"hello"'));
    });

    test('console_read reads empty line from stdin', () async {
      final String result = await runWithStdin(
        'main() = console_read()',
        '',
      );
      expect(result, equals('""'));
    });

    test('console_read result can be used in expressions', () async {
      final String result = await runWithStdin(
        'main() = str_length(console_read())',
        'hello',
      );
      expect(result, equals('5'));
    });

    test('console_read reads string with spaces', () async {
      final String result = await runWithStdin(
        'main() = console_read()',
        'hello world',
      );
      expect(result, equals('"hello world"'));
    });

    test('console_read reads string with special characters', () async {
      final String result = await runWithStdin(
        'main() = console_read()',
        'hello!@#\$%',
      );
      expect(result, equals('"hello!@#\$%"'));
    });

    test('console_read reads numeric string', () async {
      final String result = await runWithStdin(
        'main() = console_read()',
        '12345',
      );
      expect(result, equals('"12345"'));
    });

    test('console_read can be used with string concatenation', () async {
      final String result = await runWithStdin(
        'main() = str_concat("prefix-", console_read())',
        'suffix',
      );
      expect(result, equals('"prefix-suffix"'));
    });
  });

  group('Console Write Edge Cases', () {
    test('console_write with zero', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write(0)',
      );

      expect(result.stdout.toString(), equals('0'));
      expect(result.stderr.toString().trim(), equals('0'));
    });

    test('console_write with very large integer', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write(9999999999999)',
      );

      expect(result.stdout.toString(), equals('9999999999999'));
      expect(result.stderr.toString().trim(), equals('9999999999999'));
    });

    test('console_write with very small decimal', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write(0.0000001)',
      );

      expect(result.stdout.toString(), equals('1e-7'));
      expect(result.stderr.toString().trim(), equals('1e-7'));
    });

    test('console_write with map', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write({"a": 1, "b": 2})',
      );

      expect(result.stdout.toString(), equals('{a: 1, b: 2}'));
      expect(result.stderr.toString().trim(), equals('{"a": 1, "b": 2}'));
    });

    test('console_write with empty list', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write([])',
      );

      expect(result.stdout.toString(), equals('[]'));
      expect(result.stderr.toString().trim(), equals('[]'));
    });

    test('console_write with empty map', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write({})',
      );

      expect(result.stdout.toString(), equals('{}'));
      expect(result.stderr.toString().trim(), equals('{}'));
    });

    test('console_write with nested list', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write([[1, 2], [3, 4]])',
      );

      expect(result.stdout.toString(), equals('[[1, 2], [3, 4]]'));
      expect(result.stderr.toString().trim(), equals('[[1, 2], [3, 4]]'));
    });

    test('console_write with single element list', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write([42])',
      );

      expect(result.stdout.toString(), equals('[42]'));
      expect(result.stderr.toString().trim(), equals('[42]'));
    });

    test('console_write with string containing tab', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: r'main() = console_write("hello\tworld")',
      );

      expect(result.stdout.toString(), equals('hello\tworld'));
      expect(result.stderr.toString().trim(), equals('"hello\tworld"'));
    });

    test('console_write with unicode characters', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write("hello \u4e16\u754c")',
      );

      expect(result.stdout.toString(), equals('hello \u4e16\u754c'));
      expect(result.stderr.toString().trim(), equals('"hello \u4e16\u754c"'));
    });

    test('console_write with mixed type list', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write([1, "two", true])',
      );

      expect(result.stdout.toString(), equals('[1, two, true]'));
      expect(result.stderr.toString().trim(), equals('[1, "two", true]'));
    });
  });

  group('Console WriteLn Edge Cases', () {
    test('console_writeLn with zero', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn(0)',
      );

      expect(result.stdout.toString(), equals('0\n'));
      expect(result.stderr.toString().trim(), equals('0'));
    });

    test('console_writeLn with map', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn({"x": 10, "y": 20})',
      );

      expect(result.stdout.toString(), equals('{x: 10, y: 20}\n'));
      expect(result.stderr.toString().trim(), equals('{"x": 10, "y": 20}'));
    });

    test('console_writeLn with empty list', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn([])',
      );

      expect(result.stdout.toString(), equals('[]\n'));
      expect(result.stderr.toString().trim(), equals('[]'));
    });

    test('console_writeLn with empty map', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn({})',
      );

      expect(result.stdout.toString(), equals('{}\n'));
      expect(result.stderr.toString().trim(), equals('{}'));
    });

    test('console_writeLn with nested list', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn([[1], [2], [3]])',
      );

      expect(result.stdout.toString(), equals('[[1], [2], [3]]\n'));
      expect(result.stderr.toString().trim(), equals('[[1], [2], [3]]'));
    });

    test('console_writeLn with negative decimal', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn(-3.14)',
      );

      expect(result.stdout.toString(), equals('-3.14\n'));
      expect(result.stderr.toString().trim(), equals('-3.14'));
    });

    test('console_writeLn with single character string', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_writeLn("x")',
      );

      expect(result.stdout.toString(), equals('x\n'));
      expect(result.stderr.toString().trim(), equals('"x"'));
    });
  });

  group('Console Return Value Usage', () {
    test('console_write return value used in list', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = [console_write(1), console_write(2)]',
      );

      expect(result.stdout.toString(), equals('12'));
      expect(result.stderr.toString().trim(), equals('[1, 2]'));
    });

    test('console_writeLn return value used in arithmetic', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = num_mul(console_writeLn(3), console_writeLn(4))',
      );

      expect(result.stdout.toString(), equals('3\n4\n'));
      expect(result.stderr.toString().trim(), equals('12'));
    });

    test('console_write chained in string operations', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = str_uppercase(console_write("hello"))',
      );

      expect(result.stdout.toString(), equals('hello'));
      expect(result.stderr.toString().trim(), equals('"HELLO"'));
    });

    test('console_write with conditional expression', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: 'main() = console_write(if (true) "yes" else "no")',
      );

      expect(result.stdout.toString(), equals('yes'));
      expect(result.stderr.toString().trim(), equals('"yes"'));
    });
  });

  group('Console Read Edge Cases', () {
    test('console_read trims leading and trailing spaces', () async {
      // Note: console.read() trims input in non-terminal mode
      final String result = await runWithStdin(
        'main() = console_read()',
        '   hello   ',
      );
      expect(result, equals('"hello"'));
    });

    test('console_read reads very long string', () async {
      final String longInput = 'a' * 1000;
      final String result = await runWithStdin(
        'main() = str_length(console_read())',
        longInput,
      );
      expect(result, equals('1000'));
    });

    test('console_read reads string with tab character', () async {
      final String result = await runWithStdin(
        'main() = console_read()',
        'hello\tworld',
      );
      expect(result, equals('"hello\tworld"'));
    });

    test('console_read reads unicode string', () async {
      final String result = await runWithStdin(
        'main() = console_read()',
        '\u4e16\u754c',
      );
      expect(result, equals('"\u4e16\u754c"'));
    });

    test(
      'console_read result used in equality comparison returns true',
      () async {
        final String result = await runWithStdin(
          'main() = comp_eq(console_read(), "test")',
          'test',
        );
        expect(result, equals('true'));
      },
    );

    test(
      'console_read result used in equality comparison returns false',
      () async {
        final String result = await runWithStdin(
          'main() = comp_eq(console_read(), "test")',
          'other',
        );
        expect(result, equals('false'));
      },
    );

    test('console_read trims whitespace-only input to empty string', () async {
      // Note: console.read() trims input in non-terminal mode
      final String result = await runWithStdin(
        'main() = console_read()',
        '   ',
      );
      expect(result, equals('""'));
    });
  });

  group('Console Multiple Calls', () {
    test('multiple console_write calls in sequence', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: '''
          helper(a, b, c) = [a, b, c]
          main() = helper(console_write("A"), console_write("B"), console_write("C"))
        ''',
      );

      expect(result.stdout.toString(), equals('ABC'));
      expect(result.stderr.toString().trim(), equals('["A", "B", "C"]'));
    });

    test('console_write and console_writeLn mixed', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: '''
          helper(a, b) = [a, b]
          main() = helper(console_write("first"), console_writeLn("second"))
        ''',
      );

      expect(result.stdout.toString(), equals('firstsecond\n'));
      expect(result.stderr.toString().trim(), equals('["first", "second"]'));
    });

    test('console_write with computed value from function', () async {
      final ProcessResult result = await runRuntimeProgram(
        source: '''
          square(x) = num_mul(x, x)
          main() = console_write(square(5))
        ''',
      );

      expect(result.stdout.toString(), equals('25'));
      expect(result.stderr.toString().trim(), equals('25'));
    });
  });
}
