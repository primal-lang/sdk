@Tags(['compiler'])
@TestOn('vm')
library;

import 'package:primal/main/main_cli.dart';
import 'package:primal/utils/console.dart';
import 'package:test/test.dart';
import '../helpers/console_fakes.dart';

void main() {
  group('runCli()', () {
    group('REPL banner', () {
      test('prints banner on REPL start', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 0,
        );

        runCli([], console: console);

        // Banner: top border + 4 content lines + bottom border
        expect(platformConsole.outLines.length, equals(6));
        expect(platformConsole.outLines[0], startsWith('\u250c')); // ┌
        expect(platformConsole.outLines[5], startsWith('\u2514')); // └
      });

      test('banner contains version and commands', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 0,
        );

        runCli([], console: console);

        final String allLines = platformConsole.outLines.join('\n');
        expect(allLines, contains('v0.'));
        expect(allLines, contains(':help'));
        expect(allLines, contains(':load'));
        expect(allLines, contains(':quit'));
      });

      test('does not print banner when executing main', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['program.prm'],
          console: console,
          readFile: (_) => 'main = 42',
        );

        // Only the result should be printed, no banner
        expect(platformConsole.outLines, equals(['42']));
      });
    });

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
      // Banner (6 lines) + result
      expect(platformConsole.outLines.length, equals(7));
      expect(platformConsole.outLines.last, equals('6'));
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
      // Banner only (6 lines), no result due to error
      expect(platformConsole.outLines.length, equals(6));
      expect(platformConsole.errorLines.single, contains('Error'));
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
