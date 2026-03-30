@Tags(['unit'])
@TestOn('vm')
library;

import 'package:primal/compiler/warnings/semantic_warning.dart';
import 'package:primal/utils/console.dart';
import 'package:test/test.dart';
import '../helpers/console_fakes.dart';

void main() {
  late FakePlatformConsole platformConsole;
  late Console console;

  setUp(() {
    platformConsole = FakePlatformConsole();
    console = Console(platformConsole);
  });

  group('Console', () {
    test('print writes message to stdout', () {
      console.print('hello');

      expect(platformConsole.outLines, equals(['hello']));
    });

    test('warning writes formatted warning to stderr', () {
      const warning = SemanticWarning('test warning');
      console.warning(warning);

      expect(
        platformConsole.errorLines,
        equals(['${Console.yellow}$warning${Console.reset}']),
      );
    });

    test('error writes formatted error to stderr', () {
      console.error(Exception('test'));

      expect(
        platformConsole.errorLines,
        equals(['${Console.red}Exception: test${Console.reset}']),
      );
    });
  });

  group('Console.promptOnce()', () {
    test('writes prompt and forwards non-empty input to handler', () {
      platformConsole = FakePlatformConsole(inputs: ['hello']);
      console = Console(platformConsole);
      final List<String> inputs = <String>[];

      console.promptOnce(inputs.add);

      expect(platformConsole.outWrites, equals(['> ']));
      expect(inputs, equals(['hello']));
    });

    test('writes prompt and ignores empty input', () {
      platformConsole = FakePlatformConsole(inputs: ['']);
      console = Console(platformConsole);
      bool called = false;

      console.promptOnce((_) => called = true);

      expect(platformConsole.outWrites, equals(['> ']));
      expect(called, isFalse);
    });

    test('reports handler errors via console.error', () {
      platformConsole = FakePlatformConsole(inputs: ['hello']);
      console = Console(platformConsole);

      console.promptOnce((_) => throw StateError('boom'));

      expect(platformConsole.outWrites, equals(['> ']));
      expect(platformConsole.errorLines.single, contains('Bad state: boom'));
    });

    test('reports read errors via console.error', () {
      platformConsole = FakePlatformConsole()..readError = StateError('stop');
      console = Console(platformConsole);

      console.promptOnce((_) {});

      expect(platformConsole.outWrites, equals(['> ']));
      expect(platformConsole.errorLines.single, contains('Bad state: stop'));
    });
  });
}
