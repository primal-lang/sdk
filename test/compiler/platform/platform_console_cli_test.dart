@Tags(['unit'])
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:primal/compiler/platform/console/platform_console_cli.dart';
import 'package:test/test.dart';

void main() {
  late PlatformConsoleCli console;

  setUp(() {
    console = PlatformConsoleCli();
  });

  group('PlatformConsoleCli', () {
    test('outWrite writes to stdout', () {
      // Smoke test: just verify it doesn't throw
      expect(() => console.outWrite('test'), returnsNormally);
    });

    test('outWriteLn writes line to stdout', () {
      expect(() => console.outWriteLn('test'), returnsNormally);
    });

    test('errorWrite writes to stderr', () {
      expect(() => console.errorWrite('test'), returnsNormally);
    });

    test('errorWriteLn writes line to stderr', () {
      expect(() => console.errorWriteLn('test'), returnsNormally);
    });

    test('outWrite handles empty string', () {
      expect(() => console.outWrite(''), returnsNormally);
    });

    test('errorWriteLn handles special characters', () {
      expect(
        () => console.errorWriteLn('unicode: \u00e9\u00f1'),
        returnsNormally,
      );
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
  });
}
