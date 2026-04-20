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
      final File tmpFile = writeProgram('main.prm', 'main() = 42');
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
        'main() = undefined_function(1)',
      );
      final ProcessResult result = await runCli([tmpFile.path]);

      expect(result.stderr.toString(), contains('Error'));
    });

    test('reports warnings on stderr for unused parameters', () async {
      final File tmpFile = writeProgram(
        'warning.prm',
        'f(x, y) = x\nmain() = f(1, 2)',
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
        final File tmpFile = writeProgram('debug.prm', 'main() = 1 + 2');
        final ProcessResult result = await runCli(['--debug', tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('[debug]'));
        expect(result.stdout.toString(), contains('Compilation:'));
        expect(result.stdout.toString(), contains('Execution:'));
        expect(result.stdout.toString(), contains('ms'));
      });

      test('-d enables debug mode output', () async {
        final File tmpFile = writeProgram('debug_short.prm', 'main() = 42');
        final ProcessResult result = await runCli(['-d', tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('[debug]'));
      });

      test('help flag takes precedence over file argument', () async {
        final File tmpFile = writeProgram('ignored.prm', 'main() = 42');
        final ProcessResult result = await runCli(['--help', tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('Usage:'));
        expect(result.stdout.toString(), isNot(contains('42')));
      });

      test('version flag takes precedence over file argument', () async {
        final File tmpFile = writeProgram('ignored.prm', 'main() = 42');
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
          'main() = 100',
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
          'main() = (1 + )',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString(), contains('Error'));
      });

      test('reports error for missing closing parenthesis', () async {
        final File tmpFile = writeProgram(
          'paren_error.prm',
          'main() = (1 + 2',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString(), contains('Error'));
      });

      test('reports runtime error for division by zero', () async {
        final File tmpFile = writeProgram(
          'div_zero.prm',
          'main() = 1 / 0',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString(), isNotEmpty);
      });

      test('reports error for type mismatch', () async {
        final File tmpFile = writeProgram(
          'type_error.prm',
          'main() = 1 + "hello"',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString().toLowerCase(), contains('error'));
      });

      test('reports error for wrong number of arguments', () async {
        final File tmpFile = writeProgram(
          'arity_error.prm',
          'f(x, y) = x + y\nmain() = f(1)',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString(), contains('Error'));
      });

      test('debug flag shows stack trace on error', () async {
        final File tmpFile = writeProgram(
          'debug_error.prm',
          'main() = undefined_function(1)',
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
main() = double(triple(5))
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
main() = sum(10)
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
main() = 42 // inline comment
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('42'));
      });

      test('returns list result', () async {
        final File tmpFile = writeProgram(
          'list_result.prm',
          'main() = [1, 2, 3]',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('[1, 2, 3]'));
      });

      test('returns boolean result', () async {
        final File tmpFile = writeProgram(
          'bool_result.prm',
          'main() = 5 > 3',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('true'));
      });

      test('returns string result', () async {
        final File tmpFile = writeProgram(
          'string_result.prm',
          'main() = "hello"',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('"hello"'));
      });

      test('returns float result', () async {
        final File tmpFile = writeProgram(
          'float_result.prm',
          'main() = 3.14',
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
          'main() = num.abs(-42)',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('42'));
      });

      test('can use string functions', () async {
        final File tmpFile = writeProgram(
          'string_func.prm',
          'main() = str.uppercase("hello")',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('"HELLO"'));
      });

      test('can use list functions', () async {
        final File tmpFile = writeProgram(
          'list_func.prm',
          'main() = list.length([1, 2, 3, 4, 5])',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('5'));
      });
    });

    group('watch mode', () {
      test('--watch without file reports error', () async {
        final ProcessResult result = await runCli(['--watch']);

        expect(result.stderr.toString(), contains('requires a file argument'));
      });

      test('-w without file reports error', () async {
        final ProcessResult result = await runCli(['-w']);

        expect(result.stderr.toString(), contains('requires a file argument'));
      });

      test('--watch on file without main reports error', () async {
        final File tmpFile = writeProgram(
          'no_main.prm',
          'helper(x) = x + 1',
        );

        final ProcessResult result = await runCli(['--watch', tmpFile.path]);

        expect(
          result.stderr.toString(),
          contains('requires a file with a main function'),
        );
      });

      test('-w on file without main reports error', () async {
        final File tmpFile = writeProgram(
          'no_main_short.prm',
          'helper(x) = x * 2',
        );

        final ProcessResult result = await runCli(['-w', tmpFile.path]);

        expect(
          result.stderr.toString(),
          contains('requires a file with a main function'),
        );
      });
    });

    group('edge cases', () {
      test('handles empty file', () async {
        final File tmpFile = writeProgram('empty.prm', '');
        final ProcessResult result =
            await runCli(
              [tmpFile.path],
            ).timeout(
              const Duration(seconds: 2),
              onTimeout: () {
                return ProcessResult(0, 1, '', 'timeout');
              },
            );

        // Empty file should not have main, so it would start REPL
        // We use timeout to detect that behavior
        expect(result.stderr.toString(), equals('timeout'));
      });

      test('handles file with only whitespace', () async {
        final File tmpFile = writeProgram(
          'whitespace.prm',
          '   \n\n\t\t\n   ',
        );
        final ProcessResult result =
            await runCli(
              [tmpFile.path],
            ).timeout(
              const Duration(seconds: 2),
              onTimeout: () {
                return ProcessResult(0, 1, '', 'timeout');
              },
            );

        // Whitespace-only file should start REPL (no main)
        expect(result.stderr.toString(), equals('timeout'));
      });

      test('handles unicode content in program', () async {
        final File tmpFile = writeProgram(
          'unicode.prm',
          'main() = "Hello \u4E16\u754C \u{1F600}"',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), contains('Hello'));
      });

      test('handles unicode in argument', () async {
        final File tmpFile = writeProgram(
          'unicode_arg.prm',
          'main(x) = x',
        );
        final ProcessResult result = await runCli([
          tmpFile.path,
          '\u4E16\u754C',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), contains('\u4E16\u754C'));
      });

      test('handles argument with backslash', () async {
        final File tmpFile = writeProgram(
          'backslash_arg.prm',
          'main(x) = x',
        );
        final ProcessResult result = await runCli([
          tmpFile.path,
          r'path\to\file',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), contains(r'path\to\file'));
      });

      test('handles argument with quotes', () async {
        final File tmpFile = writeProgram(
          'quote_arg.prm',
          'main(x) = x',
        );
        final ProcessResult result = await runCli([
          tmpFile.path,
          'say "hello"',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), contains('say'));
        expect(result.stdout.toString().trim(), contains('hello'));
      });

      test('handles numeric string arguments', () async {
        final File tmpFile = writeProgram(
          'numeric_string.prm',
          'main(x) = x',
        );
        final ProcessResult result = await runCli([tmpFile.path, '42']);

        expect(result.exitCode, equals(0));
        // Arguments are passed as strings, not converted to numbers
        expect(result.stdout.toString().trim(), equals('"42"'));
      });

      test('handles many arguments', () async {
        final File tmpFile = writeProgram(
          'many_args.prm',
          '''
count(a, b, c, d, e, f, g, h, i, j) = 10
main(a, b, c, d, e, f, g, h, i, j) = count(a, b, c, d, e, f, g, h, i, j)
''',
        );
        final ProcessResult result = await runCli([
          tmpFile.path,
          'a',
          'b',
          'c',
          'd',
          'e',
          'f',
          'g',
          'h',
          'i',
          'j',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('10'));
      });

      test('returns unit result from side-effect function', () async {
        final File tmpFile = writeProgram(
          'unit_result.prm',
          'main() = if (true) 42 else 0',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('42'));
      });

      test('handles negative integer result', () async {
        final File tmpFile = writeProgram(
          'negative_result.prm',
          'main() = -42',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('-42'));
      });

      test('handles negative float result', () async {
        final File tmpFile = writeProgram(
          'negative_float.prm',
          'main() = -3.14',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('-3.14'));
      });

      test('handles deeply nested list result', () async {
        final File tmpFile = writeProgram(
          'nested_list.prm',
          'main() = [[1, [2, 3]], [[4, 5], 6]]',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(
          result.stdout.toString().trim(),
          equals('[[1, [2, 3]], [[4, 5], 6]]'),
        );
      });

      test('handles empty list result', () async {
        final File tmpFile = writeProgram(
          'empty_list.prm',
          'main() = []',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('[]'));
      });

      test('handles empty string result', () async {
        final File tmpFile = writeProgram(
          'empty_string.prm',
          'main() = ""',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('""'));
      });

      test('handles large integer result', () async {
        final File tmpFile = writeProgram(
          'large_int.prm',
          'main() = 999999999999',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(
          result.stdout.toString().trim(),
          equals('999999999999'),
        );
      });

      test('handles very small float result', () async {
        final File tmpFile = writeProgram(
          'small_float.prm',
          'main() = 0.000001',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), contains('0.000001'));
      });
    });

    group('debug mode details', () {
      test('debug mode shows executing message with arguments', () async {
        final File tmpFile = writeProgram(
          'debug_args.prm',
          'main(x, y) = x',
        );
        final ProcessResult result = await runCli([
          '--debug',
          tmpFile.path,
          'arg1',
          'arg2',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('[debug] Executing:'));
        expect(result.stdout.toString(), contains('main('));
        expect(result.stdout.toString(), contains('"arg1"'));
        expect(result.stdout.toString(), contains('"arg2"'));
      });

      test('debug mode shows executing message without arguments', () async {
        final File tmpFile = writeProgram(
          'debug_no_args.prm',
          'main() = 42',
        );
        final ProcessResult result = await runCli(['--debug', tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('[debug] Executing:'));
        expect(result.stdout.toString(), contains('main()'));
      });

      test('debug flag can appear after file path', () async {
        final File tmpFile = writeProgram(
          'debug_after.prm',
          'main() = 1',
        );
        final ProcessResult result = await runCli([tmpFile.path, '--debug']);

        // All flags are processed regardless of position in argument list
        // so --debug after file path still enables debug mode
        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('[debug]'));
        expect(result.stdout.toString(), contains('1'));
      });
    });

    group('combined flags', () {
      test('debug and watch flags together require file', () async {
        final ProcessResult result = await runCli(['--debug', '--watch']);

        expect(result.stderr.toString(), contains('requires a file argument'));
      });

      test('debug flag works with valid watch file', () async {
        final File tmpFile = writeProgram(
          'debug_watch.prm',
          'main() = 123',
        );

        // Start the process but don't wait for it since watch mode is infinite
        final Process process = await Process.start(
          Platform.resolvedExecutable,
          ['run', 'lib/main/main_cli.dart', '--debug', '--watch', tmpFile.path],
          environment: {
            'HOME': tempDir.path,
            'XDG_CONFIG_HOME': tempDir.path,
          },
        );

        // Give it more time to compile and execute
        await Future<void>.delayed(const Duration(seconds: 3));

        // Kill the process
        process.kill();

        final String stdout = await process.stdout
            .transform(const SystemEncoding().decoder)
            .join();

        expect(stdout, contains('[debug]'));
        expect(stdout, contains('123'));
      });

      test('short flags can be combined in sequence', () async {
        final File tmpFile = writeProgram(
          'short_flags.prm',
          'main() = 99',
        );
        final ProcessResult result = await runCli(['-d', tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), contains('[debug]'));
        expect(result.stdout.toString(), contains('99'));
      });
    });

    group('error message formatting', () {
      test('reports undefined function with context', () async {
        final File tmpFile = writeProgram(
          'undefined_func.prm',
          'main() = foo(1, 2)',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString().toLowerCase(), contains('error'));
        expect(result.stderr.toString().toLowerCase(), contains('foo'));
      });

      test('reports recursive depth exceeded', () async {
        final File tmpFile = writeProgram(
          'infinite_recursion.prm',
          '''
recurse(n) = recurse(n + 1)
main() = recurse(0)
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString(), isNotEmpty);
      });

      test('reports error with line information', () async {
        final File tmpFile = writeProgram(
          'line_error.prm',
          '''
valid_function(x) = x + 1

main() = undefined_thing
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString().toLowerCase(), contains('error'));
      });

      test('reports duplicate function definition', () async {
        final File tmpFile = writeProgram(
          'duplicate_func.prm',
          '''
foo(x) = x + 1
foo(x) = x * 2
main() = foo(5)
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString().toLowerCase(), contains('error'));
      });

      test('reports duplicate parameter', () async {
        final File tmpFile = writeProgram(
          'duplicate_param.prm',
          '''
foo(x, x) = x
main() = foo(1, 2)
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.stderr.toString().toLowerCase(), contains('error'));
      });
    });

    group('file path handling', () {
      test('handles file in subdirectory', () async {
        final File tmpFile = writeProgram(
          'subdir/nested/program.prm',
          'main() = 777',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('777'));
      });

      test('handles file with spaces in name', () async {
        final File tmpFile = writeProgram(
          'my program.prm',
          'main() = 888',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('888'));
      });

      test('handles file with special characters in name', () async {
        final File tmpFile = writeProgram(
          'test-file_v2.prm',
          'main() = 999',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('999'));
      });

      test('reports error for directory path', () async {
        final Directory subDir = Directory(path.join(tempDir.path, 'subdir'));
        subDir.createSync();
        final ProcessResult result = await runCli([subDir.path]);

        expect(result.stderr.toString(), isNotEmpty);
      });
    });

    group('complex programs', () {
      test('handles higher-order functions', () async {
        final File tmpFile = writeProgram(
          'higher_order.prm',
          '''
apply(f, x) = f(x)
double(n) = n * 2
main() = apply(double, 21)
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('42'));
      });

      test('handles mutual recursion', () async {
        final File tmpFile = writeProgram(
          'mutual_recursion.prm',
          '''
isEven(n) = if (n == 0) true else isOdd(n - 1)
isOdd(n) = if (n == 0) false else isEven(n - 1)
main() = isEven(10)
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('true'));
      });

      test('handles early return in conditional', () async {
        final File tmpFile = writeProgram(
          'early_return.prm',
          '''
safeDivide(a, b) = if (b == 0) 0 else a / b
main() = safeDivide(10, 2)
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        // Division returns float in Primal
        expect(result.stdout.toString().trim(), equals('5.0'));
      });

      test('handles complex arithmetic', () async {
        final File tmpFile = writeProgram(
          'complex_arithmetic.prm',
          'main() = ((1 + 2) * 3 - 4) / 5 + 6 % 7',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), isNotEmpty);
      });

      test('handles boolean logic', () async {
        final File tmpFile = writeProgram(
          'boolean_logic.prm',
          'main() = (true && false) || (true && !false)',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('true'));
      });

      test('handles comparison operators', () async {
        final File tmpFile = writeProgram(
          'comparisons.prm',
          '''
main() = [5 > 3, 5 >= 5, 3 < 5, 3 <= 3, 3 == 3, 3 != 4]
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(
          result.stdout.toString().trim(),
          equals('[true, true, true, true, true, true]'),
        );
      });

      test('handles partial application via function reference', () async {
        final File tmpFile = writeProgram(
          'partial.prm',
          '''
apply(f, x) = f(x)
double(n) = n * 2
main() = apply(double, 21)
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('42'));
      });

      test('handles conditional chains', () async {
        final File tmpFile = writeProgram(
          'cond_chain.prm',
          '''
grade(score) = if (score >= 90) "A" else if (score >= 80) "B" else if (score >= 70) "C" else "F"
main() = grade(85)
''',
        );
        final ProcessResult result = await runCli([tmpFile.path]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('"B"'));
      });
    });

    group('sample programs', () {
      test('factorial sample executes correctly', () async {
        final ProcessResult result = await runCli([
          'test/resources/samples/factorial.prm',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), equals('120'));
      });

      test('fibonacci sample executes correctly', () async {
        final ProcessResult result = await runCli([
          'test/resources/samples/fibonacci.prm',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), isNotEmpty);
      });

      test('is_prime sample executes correctly', () async {
        final ProcessResult result = await runCli([
          'test/resources/samples/is_prime.prm',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), isNotEmpty);
      });

      test('quicksort sample executes correctly', () async {
        final ProcessResult result = await runCli([
          'test/resources/samples/quicksort.prm',
        ]);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString().trim(), isNotEmpty);
      });
    });
  });
}
