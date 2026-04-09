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

      expect(result.stderr.toString(), contains('Error'));
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

    group('flags', () {
      test('--help displays usage information', () async {
        final ProcessResult result = await runCli(['--help']);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('Usage:'));
        expect(result.stdout.toString(), contains('primal'));
        expect(result.stdout.toString(), contains('Options:'));
      });

      test('-h displays usage information', () async {
        final ProcessResult result = await runCli(['-h']);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('Usage:'));
      });

      test('--version displays version string', () async {
        final ProcessResult result = await runCli(['--version']);

        expect(result.exitCode, equals(0));
        expect(
          result.stdout.toString().trim(),
          matches(RegExp(r'^\d+\.\d+\.\d+$')),
        );
      });

      test('-v displays version string', () async {
        final ProcessResult result = await runCli(['-v']);

        expect(result.exitCode, equals(0));
        expect(
          result.stdout.toString().trim(),
          matches(RegExp(r'^\d+\.\d+\.\d+$')),
        );
      });

      test('--debug enables debug mode output', () async {
        final File tmpFile = writeProgram('debug.prm', 'main = 1 + 2');
        final ProcessResult result = await runCli(['--debug', tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('[debug]'));
        expect(result.stdout.toString(), contains('Compilation:'));
        expect(result.stdout.toString(), contains('Execution:'));
        expect(result.stdout.toString(), contains('ms'));
      });

      test('-d enables debug mode output', () async {
        final File tmpFile = writeProgram('debug_short.prm', 'main = 42');
        final ProcessResult result = await runCli(['-d', tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('[debug]'));
      });

      test('help flag takes precedence over file argument', () async {
        final File tmpFile = writeProgram('ignored.prm', 'main = 42');
        final ProcessResult result = await runCli(['--help', tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('Usage:'));
        expect(result.stdout.toString(), isNot(contains('42')));
      });

      test('version flag takes precedence over file argument', () async {
        final File tmpFile = writeProgram('ignored.prm', 'main = 42');
        final ProcessResult result = await runCli(['--version', tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(
          result.stdout.toString().trim(),
          matches(RegExp(r'^\d+\.\d+\.\d+$')),
        );
      });
    });

    group('arguments', () {
      test('passes multiple arguments to main function', () async {
        final File tmpFile = writeProgram(
          'multi_args.prm',
          'main(a, b, c) = str.concat(a, str.concat(b, c))',
        );
        final ProcessResult result = await runCli([
          tmpFile.path,
          'one',
          'two',
          'three',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('"onetwothree"'));
      });

      test('handles empty string argument', () async {
        final File tmpFile = writeProgram(
          'empty_arg.prm',
          'main(x) = str.length(x)',
        );
        final ProcessResult result = await runCli([tmpFile.path, '']);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('0'));
      });

      test('handles argument with special characters', () async {
        final File tmpFile = writeProgram(
          'special_arg.prm',
          'main(x) = x',
        );
        final ProcessResult result = await runCli([
          tmpFile.path,
          'hello world!',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('"hello world!"'));
      });

      test('main without parameters ignores arguments', () async {
        final File tmpFile = writeProgram(
          'no_params.prm',
          'main = 100',
        );
        final ProcessResult result = await runCli([
          tmpFile.path,
          'ignored_arg',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('100'));
      });
    });

    group('error handling', () {
      test('reports syntax error for malformed expression', () async {
        final File tmpFile = writeProgram(
          'syntax_error.prm',
          'main = (1 + )',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString(), contains('Error'));
      });

      test('reports error for missing closing parenthesis', () async {
        final File tmpFile = writeProgram(
          'paren_error.prm',
          'main = (1 + 2',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString(), contains('Error'));
      });

      test('reports runtime error for division by zero', () async {
        final File tmpFile = writeProgram(
          'div_zero.prm',
          'main = 1 / 0',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString(), isNotEmpty);
      });

      test('reports error for type mismatch', () async {
        final File tmpFile = writeProgram(
          'type_error.prm',
          'main = 1 + "hello"',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString().toLowerCase(), contains('error'));
      });

      test('reports error for wrong number of arguments', () async {
        final File tmpFile = writeProgram(
          'arity_error.prm',
          'f(x, y) = x + y\nmain = f(1)',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString(), contains('Error'));
      });

      test('debug flag shows stack trace on error', () async {
        final File tmpFile = writeProgram(
          'debug_error.prm',
          'main = undefined_function(1)',
        );
        final ProcessResult result = await runCli(['--debug', tmpFile.path]);

        expect(result.stderr.toString(), contains('Error'));
        expect(result.stdout.toString(), contains('[debug] Stack trace:'));
      });
    });

    group('program structure', () {
      test('executes program with multiple function definitions', () async {
        final File tmpFile = writeProgram(
          'multi_func.prm',
          '''
double(x) = x * 2
triple(x) = x * 3
main = double(triple(5))
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('30'));
      });

      test('handles recursive function calls', () async {
        final File tmpFile = writeProgram(
          'recursive.prm',
          '''
sum(n) = if (n <= 0) 0 else n + sum(n - 1)
main = sum(10)
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('55'));
      });

      test('executes program with comments', () async {
        final File tmpFile = writeProgram(
          'comments.prm',
          '''
/* This is a block comment */
// This is a line comment
main = 42 // inline comment
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('42'));
      });

      test('returns list result', () async {
        final File tmpFile = writeProgram(
          'list_result.prm',
          'main = [1, 2, 3]',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('[1, 2, 3]'));
      });

      test('returns boolean result', () async {
        final File tmpFile = writeProgram(
          'bool_result.prm',
          'main = 5 > 3',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('true'));
      });

      test('returns string result', () async {
        final File tmpFile = writeProgram(
          'string_result.prm',
          'main = "hello"',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('"hello"'));
      });

      test('returns float result', () async {
        final File tmpFile = writeProgram(
          'float_result.prm',
          'main = 3.14',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('3.14'));
      });
    });

    group('standard library', () {
      test('can use numeric functions', () async {
        final File tmpFile = writeProgram(
          'num_func.prm',
          'main = num.abs(-42)',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('42'));
      });

      test('can use string functions', () async {
        final File tmpFile = writeProgram(
          'string_func.prm',
          'main = str.uppercase("hello")',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('"HELLO"'));
      });

      test('can use list functions', () async {
        final File tmpFile = writeProgram(
          'list_func.prm',
          'main = list.length([1, 2, 3, 4, 5])',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('5'));
      });
    });
  });
}
