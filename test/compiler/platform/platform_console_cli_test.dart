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
  });
}
