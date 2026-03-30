@Tags(['compiler'])
@TestOn('vm')
library;

import 'package:primal/main/main_cli.dart';
import 'package:primal/utils/console.dart';
import 'package:test/test.dart';
import '../helpers/console_fakes.dart';

void main() {
  group('runCli()', () {
    test('prints main result without subprocess', () {
      final FakePlatformConsole platformConsole = FakePlatformConsole();
      final Console console = Console(platformConsole);

      runCli(
        ['program.prm'],
        console: console,
        readFile: (_) => 'main = 42',
      );

      expect(platformConsole.outLines, equals(['42']));
      expect(platformConsole.errorLines, isEmpty);
    });

    test('prints warnings before executing main', () {
      final FakePlatformConsole platformConsole = FakePlatformConsole();
      final Console console = Console(platformConsole);

      runCli(
        ['program.prm'],
        console: console,
        readFile: (_) => 'f(x, y) = x\nmain = f(1, 2)',
      );

      expect(platformConsole.outLines, equals(['1']));
      expect(platformConsole.errorLines.single, contains('Warning'));
    });

    test('falls back to prompt when loaded program has no main', () {
      final FakePlatformConsole platformConsole = FakePlatformConsole(
        inputs: ['double(3)'],
      );
      final ScriptedConsole console = ScriptedConsole(
        platformConsole,
        promptIterations: 1,
      );

      runCli(
        ['library.prm'],
        console: console,
        readFile: (_) => 'double(x) = x * 2',
      );

      expect(platformConsole.outWrites, equals(['> ']));
      expect(platformConsole.outLines, equals(['6']));
      expect(platformConsole.errorLines, isEmpty);
    });

    test('reports prompt evaluation errors through the console', () {
      final FakePlatformConsole platformConsole = FakePlatformConsole(
        inputs: ['= = ='],
      );
      final ScriptedConsole console = ScriptedConsole(
        platformConsole,
        promptIterations: 1,
      );

      runCli([], console: console);

      expect(platformConsole.outWrites, equals(['> ']));
      expect(platformConsole.outLines, isEmpty);
      expect(platformConsole.errorLines.single, contains('Compilation error'));
    });

    test('reports file read errors through the console', () {
      final FakePlatformConsole platformConsole = FakePlatformConsole();
      final Console console = Console(platformConsole);

      runCli(
        ['missing.prm'],
        console: console,
        readFile: (_) => throw StateError('missing file'),
      );

      expect(platformConsole.outLines, isEmpty);
      expect(
        platformConsole.errorLines.single,
        contains('Bad state: missing file'),
      );
    });
  });
}
