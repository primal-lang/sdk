@Tags(['unit'])
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:primal/compiler/platform/console/platform_console_base.dart';
import 'package:primal/compiler/platform/console/platform_console_cli.dart';
import 'package:test/test.dart';

void main() {
  group('PlatformConsoleCli', () {
    Future<ProcessResult> runConsoleWrite(String mode, [String content = '']) {
      return Process.run(Platform.resolvedExecutable, [
        'run',
        'test/helpers/platform_console_write_runner.dart',
        mode,
        content,
      ]);
    }

    test('outWrite writes to stdout', () async {
      final ProcessResult result = await runConsoleWrite('outWrite', 'test');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('test'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('outWriteLn writes line to stdout', () async {
      final ProcessResult result = await runConsoleWrite('outWriteLn', 'test');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('test\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite writes to stderr', () async {
      final ProcessResult result = await runConsoleWrite('errorWrite', 'test');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('test'));
    });

    test('errorWriteLn writes line to stderr', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'test',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('test\n'));
    });

    test('outWrite handles empty string', () async {
      final ProcessResult result = await runConsoleWrite('outWrite', '');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles special characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'unicode: \u00e9\u00f1',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('unicode: \u00e9\u00f1\n'));
    });

    test('readLine reads from stdin', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('test input');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('test input'));
    });

    test('outWriteLn handles empty string', () async {
      final ProcessResult result = await runConsoleWrite('outWriteLn', '');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles empty string', () async {
      final ProcessResult result = await runConsoleWrite('errorWrite', '');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), isEmpty);
    });

    test('outWrite handles special characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'unicode: \u00e9\u00f1',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('unicode: \u00e9\u00f1'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('outWriteLn handles special characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'unicode: \u00e9\u00f1',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('unicode: \u00e9\u00f1\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles special characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'unicode: \u00e9\u00f1',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('unicode: \u00e9\u00f1'));
    });

    test('outWrite handles multi-line content', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'line1\nline2\nline3',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('line1\nline2\nline3'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('outWriteLn handles multi-line content', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'line1\nline2\nline3',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('line1\nline2\nline3\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles multi-line content', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'line1\nline2\nline3',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('line1\nline2\nline3'));
    });

    test('errorWriteLn handles multi-line content', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'line1\nline2\nline3',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('line1\nline2\nline3\n'));
    });

    test('readLine handles empty input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), isEmpty);
    });

    test('readLine reads only first line from multi-line input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('first line');
      process.stdin.writeln('second line');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('first line'));
    });

    test('readLine handles special characters', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('unicode: \u00e9\u00f1');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('unicode: \u00e9\u00f1'));
    });

    test('readLine handles whitespace-only input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('   ');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), isEmpty);
    });

    test('errorWriteLn handles empty string', () async {
      final ProcessResult result = await runConsoleWrite('errorWriteLn', '');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\n'));
    });

    test('outWrite handles whitespace-only content', () async {
      final ProcessResult result = await runConsoleWrite('outWrite', '   ');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('   '));
      expect(result.stderr.toString(), isEmpty);
    });

    test('outWriteLn handles whitespace-only content', () async {
      final ProcessResult result = await runConsoleWrite('outWriteLn', '   ');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('   \n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles whitespace-only content', () async {
      final ProcessResult result = await runConsoleWrite('errorWrite', '   ');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('   '));
    });

    test('errorWriteLn handles whitespace-only content', () async {
      final ProcessResult result = await runConsoleWrite('errorWriteLn', '   ');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('   \n'));
    });

    test('outWrite handles tab characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'col1\tcol2\tcol3',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('col1\tcol2\tcol3'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('outWriteLn handles tab characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'col1\tcol2\tcol3',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('col1\tcol2\tcol3\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles tab characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'col1\tcol2\tcol3',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('col1\tcol2\tcol3'));
    });

    test('errorWriteLn handles tab characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'col1\tcol2\tcol3',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('col1\tcol2\tcol3\n'));
    });

    test('outWrite handles numeric content', () async {
      final ProcessResult result = await runConsoleWrite('outWrite', '12345');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('12345'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles numeric content', () async {
      final ProcessResult result = await runConsoleWrite('errorWrite', '12345');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('12345'));
    });

    test('outWrite handles single character', () async {
      final ProcessResult result = await runConsoleWrite('outWrite', 'x');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('x'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('outWriteLn handles single character', () async {
      final ProcessResult result = await runConsoleWrite('outWriteLn', 'x');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('x\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles single character', () async {
      final ProcessResult result = await runConsoleWrite('errorWrite', 'x');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('x'));
    });

    test('errorWriteLn handles single character', () async {
      final ProcessResult result = await runConsoleWrite('errorWriteLn', 'x');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('x\n'));
    });

    test(
      'readLine handles input with leading and trailing whitespace',
      () async {
        final Process process = await Process.start(
          Platform.resolvedExecutable,
          ['run', 'test/helpers/platform_console_read_runner.dart'],
        );

        process.stdin.writeln('  hello world  ');
        await process.stdin.close();

        final String stdout = await process.stdout
            .transform(utf8.decoder)
            .join();
        final String stderr = await process.stderr
            .transform(utf8.decoder)
            .join();
        final int exitCode = await process.exitCode;

        if (exitCode != 0) {
          fail('Process exited with code $exitCode: $stderr');
        }

        expect(stdout.trim(), equals('hello world'));
      },
    );

    test('readLine handles single character input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('x');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('x'));
    });

    test('readLine handles numeric input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('12345');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('12345'));
    });

    test('readLine handles tab characters in input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('col1\tcol2');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('col1\tcol2'));
    });

    test('outWrite handles mixed content with numbers and symbols', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'Price: \$123.45 (50% off!)',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('Price: \$123.45 (50% off!)'));
      expect(result.stderr.toString(), isEmpty);
    });

    test(
      'errorWriteLn handles mixed content with numbers and symbols',
      () async {
        final ProcessResult result = await runConsoleWrite(
          'errorWriteLn',
          'Error #42: Failed at 100%',
        );

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), isEmpty);
        expect(result.stderr.toString(), equals('Error #42: Failed at 100%\n'));
      },
    );

    test('outWrite handles content with only newlines', () async {
      final ProcessResult result = await runConsoleWrite('outWrite', '\n\n\n');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\n\n\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles content with only newlines', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        '\n\n\n',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\n\n\n'));
    });

    test('outWrite handles content with carriage return', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'line1\r\nline2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('line1\r\nline2'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles content with carriage return', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'line1\r\nline2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('line1\r\nline2'));
    });

    test('outWriteLn handles numeric content', () async {
      final ProcessResult result = await runConsoleWrite('outWriteLn', '12345');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('12345\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles numeric content', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        '12345',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('12345\n'));
    });

    test('outWrite handles backslash characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        r'path\to\file',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals(r'path\to\file'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('outWriteLn handles backslash characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        r'path\to\file',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('path\\to\\file\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles backslash characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        r'path\to\file',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals(r'path\to\file'));
    });

    test('errorWriteLn handles backslash characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        r'path\to\file',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('path\\to\\file\n'));
    });

    test('outWrite handles single quotes', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        "it's a test",
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals("it's a test"));
      expect(result.stderr.toString(), isEmpty);
    });

    test('outWrite handles double quotes', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'say "hello"',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('say "hello"'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles single quotes', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        "it's an error",
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals("it's an error"));
    });

    test('errorWrite handles double quotes', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'error: "bad"',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('error: "bad"'));
    });

    test('outWrite handles JSON-like content', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        '{"key": "value", "array": [1, 2, 3]}',
      );

      expect(result.exitCode, equals(0));
      expect(
        result.stdout.toString(),
        equals('{"key": "value", "array": [1, 2, 3]}'),
      );
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles JSON-like content', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        '{"error": "message"}',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('{"error": "message"}'));
    });

    test('outWrite handles emoji characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'hello \u{1F600} world',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('hello \u{1F600} world'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles emoji characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'error \u{1F6A8}',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('error \u{1F6A8}'));
    });

    test('outWrite handles CJK characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        '\u4E2D\u6587\u6D4B\u8BD5',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\u4E2D\u6587\u6D4B\u8BD5'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles CJK characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        '\u65E5\u672C\u8A9E',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\u65E5\u672C\u8A9E'));
    });

    test('outWrite handles Arabic RTL characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        '\u0645\u0631\u062D\u0628\u0627',
      );

      expect(result.exitCode, equals(0));
      expect(
        result.stdout.toString(),
        equals('\u0645\u0631\u062D\u0628\u0627'),
      );
      expect(result.stderr.toString(), isEmpty);
    });

    test('outWrite handles combining characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'e\u0301',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('e\u0301'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('outWrite handles ANSI escape codes', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        '\x1b[31mred text\x1b[0m',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\x1b[31mred text\x1b[0m'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles ANSI escape codes', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        '\x1b[33myellow\x1b[0m',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\x1b[33myellow\x1b[0m'));
    });

    test('outWrite handles very long string', () async {
      final String longContent = 'a' * 10000;
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        longContent,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals(longContent));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles very long string', () async {
      final String longContent = 'e' * 10000;
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        longContent,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals(longContent));
    });

    test('outWriteLn handles very long string', () async {
      final String longContent = 'b' * 10000;
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        longContent,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('$longContent\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles very long string', () async {
      final String longContent = 'f' * 10000;
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        longContent,
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('$longContent\n'));
    });

    test('outWriteLn handles carriage return', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'line1\r\nline2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('line1\r\nline2\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles carriage return', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'line1\r\nline2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('line1\r\nline2\n'));
    });

    test('readLine handles emoji input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('hello \u{1F600}');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('hello \u{1F600}'));
    });

    test('readLine handles CJK input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('\u4E2D\u6587');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('\u4E2D\u6587'));
    });

    test('readLine handles backslash input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln(r'path\to\file');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals(r'path\to\file'));
    });

    test('readLine handles quotes input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('say "hello"');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('say "hello"'));
    });

    test('readLine handles JSON-like input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('{"key": "value"}');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('{"key": "value"}'));
    });

    test('readLine handles very long input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      final String longInput = 'a' * 5000;
      process.stdin.writeln(longInput);
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals(longInput));
    });

    test('readLine handles carriage return in input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.write('line with cr\r\n');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('line with cr'));
    });

    test('outWrite handles content with only tabs', () async {
      final ProcessResult result = await runConsoleWrite('outWrite', '\t\t\t');

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\t\t\t'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles content with only tabs', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        '\t\t\t',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\t\t\t'));
    });

    test('extends PlatformConsoleBase', () {
      final PlatformConsoleCli console = PlatformConsoleCli();

      expect(console, isA<PlatformConsoleBase>());
    });

    test('can instantiate PlatformConsoleCli', () {
      final PlatformConsoleCli instance = PlatformConsoleCli();

      expect(instance, isNotNull);
    });

    test('multiple instances are independent', () {
      final PlatformConsoleCli instance1 = PlatformConsoleCli();
      final PlatformConsoleCli instance2 = PlatformConsoleCli();

      expect(identical(instance1, instance2), isFalse);
    });

    test('outWrite handles mixed newlines and tabs', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        '\t\n\t\n\t',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\t\n\t\n\t'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles mixed newlines and tabs', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        '\t\n\t\n\t',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\t\n\t\n\t'));
    });

    test('outWrite handles content ending with newline', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'text\n',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('text\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles content ending with newline', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'text\n',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('text\n'));
    });

    test('outWriteLn handles content ending with newline', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'text\n',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('text\n\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles content ending with newline', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'text\n',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('text\n\n'));
    });

    test('outWrite handles mathematical symbols', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        '\u03C0 \u2248 3.14159',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\u03C0 \u2248 3.14159'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles mathematical symbols', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        '\u221E infinity',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\u221E infinity'));
    });

    test('outWrite handles bell character', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'text\x07bell',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('text\x07bell'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles bell character', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'text\x07bell',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('text\x07bell'));
    });

    test('outWrite handles form feed', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'page1\x0cpage2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('page1\x0cpage2'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles form feed', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'page1\x0cpage2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('page1\x0cpage2'));
    });

    test('outWrite handles vertical tab', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'row1\x0brow2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('row1\x0brow2'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles vertical tab', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'row1\x0brow2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('row1\x0brow2'));
    });

    test('outWrite handles zero-width space', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'word\u200Bword',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('word\u200Bword'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles zero-width space', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'word\u200Bword',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('word\u200Bword'));
    });

    test('outWrite handles zero-width joiner', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'emoji\u200Djoiner',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('emoji\u200Djoiner'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles zero-width joiner', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'emoji\u200Djoiner',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('emoji\u200Djoiner'));
    });

    test('outWrite handles mixed LTR and RTL text', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        'Hello \u0645\u0631\u062D\u0628\u0627 World',
      );

      expect(result.exitCode, equals(0));
      expect(
        result.stdout.toString(),
        equals('Hello \u0645\u0631\u062D\u0628\u0627 World'),
      );
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles mixed LTR and RTL text', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        'Error: \u05E9\u05D2\u05D9\u05D0\u05D4',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(
        result.stderr.toString(),
        equals('Error: \u05E9\u05D2\u05D9\u05D0\u05D4'),
      );
    });

    test('outWrite handles surrogate pairs', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        '\u{1F4A9}\u{1F680}\u{1F389}',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\u{1F4A9}\u{1F680}\u{1F389}'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles surrogate pairs', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        '\u{1F4A5}\u{1F525}',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\u{1F4A5}\u{1F525}'));
    });

    test('outWrite handles currency symbols', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        '\u20AC100 \u00A3200 \u00A5300',
      );

      expect(result.exitCode, equals(0));
      expect(
        result.stdout.toString(),
        equals('\u20AC100 \u00A3200 \u00A5300'),
      );
      expect(result.stderr.toString(), isEmpty);
    });

    test('readLine handles zero-width space input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('word\u200Bword');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('word\u200Bword'));
    });

    test('readLine handles surrogate pairs input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('\u{1F4A9}\u{1F680}');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('\u{1F4A9}\u{1F680}'));
    });

    test('readLine handles mixed LTR and RTL input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('Hello \u0645\u0631\u062D\u0628\u0627');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('Hello \u0645\u0631\u062D\u0628\u0627'));
    });

    test('readLine handles combining characters input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('e\u0301');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('e\u0301'));
    });

    test('readLine handles mathematical symbols input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('\u03C0 \u2248 3.14');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('\u03C0 \u2248 3.14'));
    });

    test('readLine handles currency symbols input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      process.stdin.writeln('\u20AC100 \u00A3200');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('\u20AC100 \u00A3200'));
    });

    test('write runner fails with unsupported mode', () async {
      final ProcessResult result = await runConsoleWrite('invalidMode', 'test');

      expect(result.exitCode, isNot(equals(0)));
    });

    test('outWrite handles only control characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWrite',
        '\x07\x0b\x0c',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\x07\x0b\x0c'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWrite handles only control characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWrite',
        '\x07\x0b\x0c',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\x07\x0b\x0c'));
    });

    test('outWriteLn handles zero-width space', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'word\u200Bword',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('word\u200Bword\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles zero-width space', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'word\u200Bword',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('word\u200Bword\n'));
    });

    test('outWriteLn handles surrogate pairs', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        '\u{1F4A9}\u{1F680}',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\u{1F4A9}\u{1F680}\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles surrogate pairs', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        '\u{1F4A9}\u{1F680}',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\u{1F4A9}\u{1F680}\n'));
    });

    test('outWriteLn handles mixed LTR and RTL text', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'Hello \u0645\u0631\u062D\u0628\u0627',
      );

      expect(result.exitCode, equals(0));
      expect(
        result.stdout.toString(),
        equals('Hello \u0645\u0631\u062D\u0628\u0627\n'),
      );
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles mixed LTR and RTL text', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'Error: \u05E9\u05D2\u05D9\u05D0\u05D4',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(
        result.stderr.toString(),
        equals('Error: \u05E9\u05D2\u05D9\u05D0\u05D4\n'),
      );
    });

    test('outWriteLn handles combining characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'e\u0301',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('e\u0301\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles combining characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'e\u0301',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('e\u0301\n'));
    });

    test('outWriteLn handles bell character', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'text\x07bell',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('text\x07bell\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles bell character', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'text\x07bell',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('text\x07bell\n'));
    });

    test('outWriteLn handles form feed', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'page1\x0cpage2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('page1\x0cpage2\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles form feed', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'page1\x0cpage2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('page1\x0cpage2\n'));
    });

    test('outWriteLn handles vertical tab', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'row1\x0brow2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('row1\x0brow2\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles vertical tab', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'row1\x0brow2',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('row1\x0brow2\n'));
    });

    test('outWriteLn handles zero-width joiner', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'emoji\u200Djoiner',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('emoji\u200Djoiner\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles zero-width joiner', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'emoji\u200Djoiner',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('emoji\u200Djoiner\n'));
    });

    test('outWriteLn handles ANSI escape codes', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        '\x1b[31mred text\x1b[0m',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\x1b[31mred text\x1b[0m\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles ANSI escape codes', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        '\x1b[33myellow\x1b[0m',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\x1b[33myellow\x1b[0m\n'));
    });

    test(
      'outWrite handles content with all printable ASCII characters',
      () async {
        final StringBuffer printableAscii = StringBuffer();
        for (int index = 32; index < 127; index++) {
          printableAscii.writeCharCode(index);
        }
        final String content = printableAscii.toString();
        final ProcessResult result = await runConsoleWrite('outWrite', content);

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), equals(content));
        expect(result.stderr.toString(), isEmpty);
      },
    );

    test(
      'errorWrite handles content with all printable ASCII characters',
      () async {
        final StringBuffer printableAscii = StringBuffer();
        for (int index = 32; index < 127; index++) {
          printableAscii.writeCharCode(index);
        }
        final String content = printableAscii.toString();
        final ProcessResult result = await runConsoleWrite(
          'errorWrite',
          content,
        );

        expect(result.exitCode, equals(0));
        expect(result.stdout.toString(), isEmpty);
        expect(result.stderr.toString(), equals(content));
      },
    );

    test('readLine handles all printable ASCII input', () async {
      final Process process = await Process.start(
        Platform.resolvedExecutable,
        ['run', 'test/helpers/platform_console_read_runner.dart'],
      );

      // Subset of printable ASCII to avoid special shell interpretation
      process.stdin.writeln('ABC xyz 123');
      await process.stdin.close();

      final String stdout = await process.stdout.transform(utf8.decoder).join();
      final String stderr = await process.stderr.transform(utf8.decoder).join();
      final int exitCode = await process.exitCode;

      if (exitCode != 0) {
        fail('Process exited with code $exitCode: $stderr');
      }

      expect(stdout.trim(), equals('ABC xyz 123'));
    });

    test('outWriteLn handles CJK characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        '\u4E2D\u6587\u6D4B\u8BD5',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\u4E2D\u6587\u6D4B\u8BD5\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles CJK characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        '\u65E5\u672C\u8A9E',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\u65E5\u672C\u8A9E\n'));
    });

    test('outWriteLn handles emoji characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        'hello \u{1F600} world',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('hello \u{1F600} world\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles emoji characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        'error \u{1F6A8}',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('error \u{1F6A8}\n'));
    });

    test('outWriteLn handles Arabic RTL characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        '\u0645\u0631\u062D\u0628\u0627',
      );

      expect(result.exitCode, equals(0));
      expect(
        result.stdout.toString(),
        equals('\u0645\u0631\u062D\u0628\u0627\n'),
      );
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles Arabic RTL characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        '\u0645\u0631\u062D\u0628\u0627',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(
        result.stderr.toString(),
        equals('\u0645\u0631\u062D\u0628\u0627\n'),
      );
    });

    test('outWriteLn handles mathematical symbols', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        '\u03C0 \u2248 3.14159',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\u03C0 \u2248 3.14159\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles mathematical symbols', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        '\u221E infinity',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\u221E infinity\n'));
    });

    test('outWriteLn handles currency symbols', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        '\u20AC100 \u00A3200 \u00A5300',
      );

      expect(result.exitCode, equals(0));
      expect(
        result.stdout.toString(),
        equals('\u20AC100 \u00A3200 \u00A5300\n'),
      );
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles currency symbols', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        '\u20AC100 \u00A3200',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\u20AC100 \u00A3200\n'));
    });

    test('outWriteLn handles only control characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'outWriteLn',
        '\x07\x0b\x0c',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), equals('\x07\x0b\x0c\n'));
      expect(result.stderr.toString(), isEmpty);
    });

    test('errorWriteLn handles only control characters', () async {
      final ProcessResult result = await runConsoleWrite(
        'errorWriteLn',
        '\x07\x0b\x0c',
      );

      expect(result.exitCode, equals(0));
      expect(result.stdout.toString(), isEmpty);
      expect(result.stderr.toString(), equals('\x07\x0b\x0c\n'));
    });
  });
}
