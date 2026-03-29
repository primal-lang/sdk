@Tags(['unit'])
@TestOn('vm')
library;

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
  });
}
