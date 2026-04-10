@Tags(['unit'])
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

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
  });
}
