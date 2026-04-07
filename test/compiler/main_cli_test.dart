@Tags(['compiler'])
@TestOn('vm')
library;

import 'package:primal/main/main_cli.dart';
import 'package:primal/utils/console.dart';
import 'package:test/test.dart';
import '../helpers/console_fakes.dart';

void main() {
  group('runCli()', () {
    group('command-line flags', () {
      test('--help prints help text and exits', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['--help'], console: console);

        expect(platformConsole.outLines.length, equals(1));
        expect(platformConsole.outLines.single, contains('Usage: primal'));
        expect(platformConsole.outLines.single, contains('--help'));
        expect(platformConsole.outLines.single, contains('--version'));
        expect(platformConsole.outLines.single, contains('--debug'));
      });

      test('-h prints help text and exits', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['-h'], console: console);

        expect(platformConsole.outLines.length, equals(1));
        expect(platformConsole.outLines.single, contains('Usage: primal'));
      });

      test('--version prints version and exits', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['--version'], console: console);

        expect(platformConsole.outLines, equals(['0.4.3']));
      });

      test('-v prints version and exits', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['-v'], console: console);

        expect(platformConsole.outLines, equals(['0.4.3']));
      });

      test('--debug enables debug output for compilation and execution', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['--debug', 'program.prm'],
          console: console,
          readFile: (_) => 'main = 42',
        );

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('[debug] Compilation:'));
        expect(allOutput, contains('[debug] Executing: main()'));
        expect(allOutput, contains('[debug] Execution:'));
        expect(allOutput, contains('42'));
      });

      test('-d enables debug output', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['-d', 'program.prm'],
          console: console,
          readFile: (_) => 'main = 42',
        );

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('[debug]'));
      });

      test('--debug prints stack trace on error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['--debug', 'program.prm'],
          console: console,
          readFile: (_) => 'main = unknownFunction()',
        );

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('[debug] Stack trace:'));
      });
    });

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

    test('passes program arguments to main', () {
      final FakePlatformConsole platformConsole = FakePlatformConsole();
      final Console console = Console(platformConsole);

      runCli(
        ['program.prm', 'hello', 'world'],
        console: console,
        readFile: (_) => 'main(a, b) = [a, b]',
      );

      expect(platformConsole.outLines, equals(['["hello", "world"]']));
    });

    test('debug mode shows arguments passed to main', () {
      final FakePlatformConsole platformConsole = FakePlatformConsole();
      final Console console = Console(platformConsole);

      runCli(
        ['--debug', 'program.prm', 'arg1', 'arg2'],
        console: console,
        readFile: (_) => 'main(a, b) = [a, b]',
      );

      final String allOutput = platformConsole.outLines.join('\n');
      expect(allOutput, contains('[debug] Executing: main("arg1", "arg2")'));
    });

    group('REPL commands', () {
      test(':help prints REPL help text', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':help'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('REPL Commands:'));
        expect(allOutput, contains(':help'));
        expect(allOutput, contains(':quit'));
        expect(allOutput, contains(':load'));
        expect(allOutput, contains(':delete'));
        expect(allOutput, contains(':rename'));
      });

      test(':version prints version', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':version'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        // Banner (6 lines) + version
        expect(platformConsole.outLines.length, equals(7));
        expect(platformConsole.outLines.last, equals('0.4.3'));
      });

      test(':clear writes escape sequence', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':clear'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        // Should include clear screen escape sequence in writes
        expect(platformConsole.outWrites, contains('\x1b[2J\x1b[H'));
      });

      test(':debug on enables debug mode', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':debug on', '1 + 1'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli([], console: console);

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('Debug mode enabled.'));
        expect(allOutput, contains('[debug] Input: 1 + 1'));
        expect(allOutput, contains('[debug] Parsing:'));
        expect(allOutput, contains('[debug] Evaluation:'));
      });

      test(':debug off disables debug mode', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':debug on', ':debug off', '1 + 1'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli([], console: console);

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('Debug mode enabled.'));
        expect(allOutput, contains('Debug mode disabled.'));
        // After debug off, there should be no debug output for the expression
        final List<String> linesAfterDebugOff = platformConsole.outLines
            .skipWhile((line) => !line.contains('Debug mode disabled.'))
            .skip(1)
            .toList();
        expect(
          linesAfterDebugOff.where((line) => line.contains('[debug]')),
          isEmpty,
        );
      });

      test(':list shows no functions when empty', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':list'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.outLines.last,
          equals('No user-defined functions.'),
        );
      });

      test(':list shows user-defined functions', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['double(x) = x * 2', 'triple(x) = x * 3', ':list'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli([], console: console);

        final String lastOutput = platformConsole.outLines.last;
        expect(lastOutput, contains('double'));
        expect(lastOutput, contains('triple'));
      });

      test(':reset clears all user-defined functions', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['double(x) = x * 2', ':reset', ':list'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli([], console: console);

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('All user-defined functions cleared.'));
        expect(
          platformConsole.outLines.last,
          equals('No user-defined functions.'),
        );
      });

      test(':delete removes a function', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['double(x) = x * 2', ':delete double', ':list'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli([], console: console);

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains("Function 'double' deleted."));
        expect(
          platformConsole.outLines.last,
          equals('No user-defined functions.'),
        );
      });

      test(':delete without name shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':delete'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Usage: :delete <function_name>'),
        );
      });

      test(':delete with space but no name shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':delete '],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Usage: :delete <function_name>'),
        );
      });

      test(':rename renames a function', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['double(x) = x * 2', ':rename double twice', ':list'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli([], console: console);

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains("Function 'double' renamed to 'twice'."));
        expect(platformConsole.outLines.last, contains('twice'));
        expect(platformConsole.outLines.last, isNot(contains('double')));
      });

      test(':rename without arguments shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':rename'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Usage: :rename <old_name> <new_name>'),
        );
      });

      test(':rename with only one argument shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':rename oldname'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Usage: :rename <old_name> <new_name>'),
        );
      });

      test(':rename with too many arguments shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':rename a b c'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Usage: :rename <old_name> <new_name>'),
        );
      });

      test(':load without path shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':load'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Usage: :load <file_path>'),
        );
      });

      test(':load with space but no path shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':load '],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Usage: :load <file_path>'),
        );
      });

      test(':load loads functions from file', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':load lib.prm', 'double(5)'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'double(x) = x * 2\ntriple(x) = x * 3',
        );

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('Loaded 2 function(s) from lib.prm.'));
        expect(platformConsole.outLines.last, equals('10'));
      });

      test(':load shows warnings from loaded file', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':load lib.prm'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'unused(x, y) = x',
        );

        expect(platformConsole.errorLines.single, contains('Warning'));
      });

      test(':run without path shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':run'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Usage: :run <file_path>'),
        );
      });

      test(':run with space but no path shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':run '],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Usage: :run <file_path>'),
        );
      });

      test(':run loads and executes main', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':run program.prm'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'double(x) = x * 2\nmain = double(21)',
        );

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('Loaded 2 function(s) from program.prm.'));
        expect(platformConsole.outLines.last, equals('42'));
      });

      test(':run without main only loads functions', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':run lib.prm', 'double(5)'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'double(x) = x * 2',
        );

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('Loaded 1 function(s) from lib.prm.'));
        expect(platformConsole.outLines.last, equals('10'));
      });

      test(':run shows warnings from loaded file', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':run program.prm'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'unused(x, y) = x\nmain = 42',
        );

        expect(platformConsole.errorLines.single, contains('Warning'));
      });

      test('unknown command shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':unknown'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains(
            "Unknown command ':unknown'. Type :help for available commands.",
          ),
        );
      });
    });

    group('REPL function definitions', () {
      test('defines function without printing output', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['double(x) = x * 2'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        // Only banner lines, no output from function definition
        expect(platformConsole.outLines.length, equals(6));
      });

      test('defined function can be used in subsequent expressions', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['double(x) = x * 2', 'double(21)'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli([], console: console);

        // Banner (6 lines) + result
        expect(platformConsole.outLines.length, equals(7));
        expect(platformConsole.outLines.last, equals('42'));
      });
    });

    group('REPL debug mode', () {
      test('debug mode prints stack trace on REPL error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':debug on', 'unknownFunction()'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli([], console: console);

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('[debug] Stack trace:'));
      });

      test('REPL started with -d flag has debug mode enabled', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['1 + 1'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli(['-d'], console: console);

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('[debug] Input: 1 + 1'));
      });
    });

    group('edge cases', () {
      test('empty input is ignored', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['', '42'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli([], console: console);

        // Empty input should be skipped, only result from 42
        expect(platformConsole.outLines.last, equals('42'));
      });

      test('handles compilation errors gracefully', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['program.prm'],
          console: console,
          readFile: (_) => 'main = ((((',
        );

        expect(platformConsole.outLines, isEmpty);
        expect(platformConsole.errorLines, isNotEmpty);
      });
    });
  });
}
