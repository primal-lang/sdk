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

        expect(platformConsole.outLines, equals([version]));
      });

      test('-v prints version and exits', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['-v'], console: console);

        expect(platformConsole.outLines, equals([version]));
      });

      test('--debug enables debug output for compilation and execution', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['--debug', 'program.prm'],
          console: console,
          readFile: (_) => 'main() = 42',
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
          readFile: (_) => 'main() = 42',
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
          readFile: (_) => 'main() = unknownFunction()',
        );

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('[debug] Stack trace:'));
      });

      test('--watch is shown in help text', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['--help'], console: console);

        expect(platformConsole.outLines.single, contains('--watch'));
        expect(platformConsole.outLines.single, contains('-w'));
      });

      test('--watch without file shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['--watch'], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Watch mode requires a file argument.'),
        );
      });

      test('-w without file shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['-w'], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Watch mode requires a file argument.'),
        );
      });

      test('--watch with file without main shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['--watch', 'library.prm'],
          console: console,
          readFile: (_) => 'double(x) = x * 2',
        );

        expect(
          platformConsole.errorLines.single,
          contains('Watch mode requires a file with a main function.'),
        );
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
          readFile: (_) => 'main() = 42',
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
        readFile: (_) => 'main() = 42',
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
        readFile: (_) => 'f(x, y) = x\nmain() = f(1, 2)',
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
        expect(platformConsole.outLines.last, equals(version));
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
          readFile: (_) => 'double(x) = x * 2\nmain() = double(21)',
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
          readFile: (_) => 'unused(x, y) = x\nmain() = 42',
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
          readFile: (_) => 'main() = ((((',
        );

        expect(platformConsole.outLines, isEmpty);
        expect(platformConsole.errorLines, isNotEmpty);
      });

      test('whitespace-only input is ignored', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['   ', '\t', '42'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli([], console: console);

        // Whitespace should be skipped, only result from 42
        expect(platformConsole.outLines.last, equals('42'));
      });
    });

    group('REPL delete command error cases', () {
      test(':delete on non-existent function shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':delete nonexistent'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Function "nonexistent" not found'),
        );
      });

      test(':delete on standard library function shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':delete if'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Cannot delete standard library function'),
        );
      });
    });

    group('REPL rename command error cases', () {
      test(':rename on non-existent function shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':rename nonexistent newname'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Function "nonexistent" not found'),
        );
      });

      test(':rename on standard library function shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':rename if myif'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Cannot rename standard library function'),
        );
      });

      test(':rename to existing function name shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['first(x) = x', 'second(x) = x * 2', ':rename first second'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Function "second" already exists'),
        );
      });

      test(':rename to standard library function name shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['myfunction(x) = x', ':rename myfunction if'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Function "if" already exists'),
        );
      });
    });

    group('REPL load command error cases', () {
      test(':load with file read error shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':load missing.prm'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => throw StateError('file not found'),
        );

        expect(
          platformConsole.errorLines.single,
          contains('Bad state: file not found'),
        );
      });

      test(':load with compilation error shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':load bad.prm'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'invalid syntax = = =',
        );

        expect(platformConsole.errorLines, isNotEmpty);
      });
    });

    group('REPL run command error cases', () {
      test(':run with file read error shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':run missing.prm'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => throw StateError('file not found'),
        );

        expect(
          platformConsole.errorLines.single,
          contains('Bad state: file not found'),
        );
      });

      test(':run with compilation error shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':run bad.prm'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'invalid syntax = = =',
        );

        expect(platformConsole.errorLines, isNotEmpty);
      });
    });

    group('REPL function redefinition', () {
      test('can redefine user-defined function', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['double(x) = x * 2', 'double(x) = x + x', 'double(5)'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli([], console: console);

        // Redefinition should succeed and use the new definition
        expect(platformConsole.outLines.last, equals('10'));
        expect(platformConsole.errorLines, isEmpty);
      });

      test('cannot redefine standard library function', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['num.abs(x) = x'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Cannot redefine standard library function'),
        );
      });

      test('function with duplicate parameters shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['bad(x, x) = x'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Duplicated parameter "x"'),
        );
      });
    });

    group('REPL debug mode with commands', () {
      test(':debug without argument shows unknown command error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':debug'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains("Unknown command ':debug'"),
        );
      });

      test(':debug with invalid argument shows unknown command error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':debug maybe'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains("Unknown command ':debug maybe'"),
        );
      });
    });

    group(':list command additional cases', () {
      test(':list shows functions in sorted order', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['zeta(x) = x', 'alpha(x) = x', 'mid(x) = x', ':list'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 4,
        );

        runCli([], console: console);

        final String lastOutput = platformConsole.outLines.last;
        // Functions should be sorted alphabetically
        final int alphaIndex = lastOutput.indexOf('alpha');
        final int midIndex = lastOutput.indexOf('mid');
        final int zetaIndex = lastOutput.indexOf('zeta');
        expect(alphaIndex, lessThan(midIndex));
        expect(midIndex, lessThan(zetaIndex));
      });
    });

    group('main function argument handling', () {
      test('main with no parameters ignores extra arguments', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['program.prm', 'arg1', 'arg2'],
          console: console,
          readFile: (_) => 'main() = 42',
        );

        expect(platformConsole.outLines, equals(['42']));
      });

      test('main arguments with special characters are passed through', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['program.prm', 'hello"world', 'back\\slash'],
          console: console,
          readFile: (_) => 'main(a, b) = [a, b]',
        );

        // Arguments should be properly escaped in the generated expression,
        // resulting in the original strings being passed through.
        // The output shows the list with strings containing the special chars.
        expect(platformConsole.outLines.single, contains('hello'));
        expect(platformConsole.outLines.single, contains('world'));
        expect(platformConsole.outLines.single, contains('back'));
        expect(platformConsole.outLines.single, contains('slash'));
      });
    });

    group('runtime error handling', () {
      test('runtime error in main shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['program.prm'],
          console: console,
          readFile: (_) => 'main() = 1 / 0',
        );

        expect(platformConsole.errorLines, isNotEmpty);
      });

      test('runtime error in REPL shows error and continues', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['1 / 0', '42'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli([], console: console);

        // Should have error from first expression
        expect(platformConsole.errorLines, isNotEmpty);
        // Should continue and evaluate second expression
        expect(platformConsole.outLines.last, equals('42'));
      });
    });

    group('REPL semantic errors', () {
      test('undefined function call in REPL shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['unknownFunction()'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Undefined function'),
        );
      });

      test('undefined identifier in REPL shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['undefinedVariable'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Undefined identifier'),
        );
      });

      test('wrong number of arguments shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['double(x) = x * 2', 'double(1, 2, 3)'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Invalid number of arguments'),
        );
      });
    });

    group('REPL function definition with undefined references', () {
      test('function with undefined function reference shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['bad(x) = unknownFunction(x)'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Undefined function'),
        );
      });

      test('function with undefined identifier reference shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['bad(x) = y'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Undefined identifier'),
        );
      });
    });

    group('recursive function definitions in REPL', () {
      test('recursive function can be defined and called', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [
            'fact(n) = if (n <= 1) 1 else n * fact(n - 1)',
            'fact(5)',
          ],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli([], console: console);

        // Banner (6 lines) + result from fact(5) = 7 total
        expect(platformConsole.outLines.length, equals(7));
        expect(platformConsole.outLines.last, equals('120'));
        expect(platformConsole.errorLines, isEmpty);
      });
    });

    group('flag combinations', () {
      test('--debug with library file (no main) enters REPL with debug', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['double(5)'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli(
          ['--debug', 'library.prm'],
          console: console,
          readFile: (_) => 'double(x) = x * 2',
        );

        final String allOutput = platformConsole.outLines.join('\n');
        // Should show compilation debug output
        expect(allOutput, contains('[debug] Compilation:'));
        // Should show REPL debug output for input
        expect(allOutput, contains('[debug] Input: double(5)'));
        // Result should be present
        expect(platformConsole.outLines.last, equals('10'));
      });

      test('--debug --version only prints version', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['--debug', '--version'], console: console);

        // --version takes precedence and exits immediately
        expect(platformConsole.outLines, equals([version]));
      });

      test('--version before --debug only prints version', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['--version', '--debug'], console: console);

        expect(platformConsole.outLines, equals([version]));
      });

      test('--help before --debug only prints help', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['--help', '--debug'], console: console);

        expect(platformConsole.outLines.length, equals(1));
        expect(platformConsole.outLines.single, contains('Usage: primal'));
      });
    });

    group('REPL :load edge cases', () {
      test(':load empty file loads 0 functions', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':load empty.prm'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => '',
        );

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('Loaded 0 function(s) from empty.prm.'));
      });

      test(':load replaces previously loaded functions', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [
            'first(x) = x',
            ':load file.prm',
            ':list',
          ],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'second(x) = x * 2',
        );

        // After :load, user-defined 'first' should be cleared and only 'second'
        // from the file should remain
        final String lastOutput = platformConsole.outLines.last;
        expect(lastOutput, contains('second'));
        expect(lastOutput, isNot(contains('first')));
      });
    });

    group('REPL :run edge cases', () {
      test(':run with main that has arguments executes without arguments', () {
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
          readFile: (_) => 'main(x) = "default"',
        );

        // main() is called without arguments, so x is unbound
        // This should either use default handling or show an error
        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('Loaded 1 function(s) from program.prm.'));
      });
    });

    group('program argument edge cases', () {
      test('main with empty string argument', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['program.prm', ''],
          console: console,
          readFile: (_) => 'main(a) = str.length(a)',
        );

        expect(platformConsole.outLines, equals(['0']));
      });

      test('main with arguments containing newlines', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['program.prm', 'line1\nline2'],
          console: console,
          readFile: (_) => 'main(a) = a',
        );

        expect(platformConsole.outLines.single, contains('line1'));
        expect(platformConsole.outLines.single, contains('line2'));
      });

      test('main with arguments containing tabs', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['program.prm', 'col1\tcol2'],
          console: console,
          readFile: (_) => 'main(a) = a',
        );

        expect(platformConsole.outLines.single, contains('col1'));
        expect(platformConsole.outLines.single, contains('col2'));
      });

      test('main with many arguments passes them all', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['program.prm', 'a', 'b', 'c', 'd', 'e'],
          console: console,
          readFile: (_) => 'main(a, b, c, d, e) = [a, b, c, d, e]',
        );

        expect(
          platformConsole.outLines.single,
          equals('["a", "b", "c", "d", "e"]'),
        );
      });
    });

    group('REPL prompt error handling', () {
      test('console read error during prompt shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        platformConsole.readError = StateError('read error');
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Bad state: read error'),
        );
      });
    });

    group('REPL multiple interactions', () {
      test('multiple function definitions build on each other', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [
            'double(x) = x * 2',
            'quadruple(x) = double(double(x))',
            'quadruple(5)',
          ],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli([], console: console);

        expect(platformConsole.outLines.last, equals('20'));
      });

      test('loaded functions can be used with REPL-defined functions', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [
            ':load lib.prm',
            'quadruple(x) = double(double(x))',
            'quadruple(3)',
          ],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'double(x) = x * 2',
        );

        expect(platformConsole.outLines.last, equals('12'));
      });
    });

    group('REPL command case sensitivity', () {
      test(':HELP (uppercase) is treated as unknown command', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':HELP'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains("Unknown command ':HELP'"),
        );
      });

      test(':Debug on (mixed case) is treated as unknown command', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':Debug on'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains("Unknown command ':Debug on'"),
        );
      });
    });

    group('REPL expressions with functions', () {
      test('expression using standard library function evaluates', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['num.abs(-42)'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(platformConsole.outLines.last, equals('42'));
      });

      test('complex expression with multiple operations evaluates', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['(1 + 2) * 3 - 4 / 2'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        // Division produces a float, so result is 7.0
        expect(platformConsole.outLines.last, equals('7.0'));
      });

      test('list operations in REPL evaluate correctly', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['[1, 2, 3]'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(platformConsole.outLines.last, equals('[1, 2, 3]'));
      });
    });

    group('debug mode detailed output', () {
      test('debug mode shows parsing and evaluation timing', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':debug on', '1 + 2 + 3'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli([], console: console);

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('[debug] Input: 1 + 2 + 3'));
        expect(allOutput, contains('[debug] Parsing:'));
        expect(allOutput, contains('[debug] Evaluation:'));
        expect(allOutput, contains('6'));
      });

      test('debug mode for function definition shows input', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':debug on', 'square(x) = x * x'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 2,
        );

        runCli([], console: console);

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('[debug] Input: square(x) = x * x'));
        // Function definition doesn't print parsing/evaluation debug
        // (no expression evaluation happens)
      });
    });

    group('execution with file and arguments', () {
      test('file with main that returns argument count', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['program.prm', 'arg1', 'arg2', 'arg3'],
          console: console,
          readFile: (_) => 'main(a, b, c) = 3',
        );

        expect(platformConsole.outLines, equals(['3']));
      });
    });

    group('watch mode validation', () {
      test('-w requires file argument', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(['-w'], console: console);

        expect(
          platformConsole.errorLines.single,
          contains('Watch mode requires a file argument.'),
        );
      });

      test('-w with library file (no main) shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        runCli(
          ['-w', 'library.prm'],
          console: console,
          readFile: (_) => 'double(x) = x * 2',
        );

        expect(
          platformConsole.errorLines.single,
          contains('Watch mode requires a file with a main function.'),
        );
      });
    });

    group('REPL with pre-loaded warnings', () {
      test('loaded file warnings shown before entering REPL', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['42'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli(
          ['library.prm'],
          console: console,
          readFile: (_) =>
              'unused(x, y) = x', // y is unused - generates warning
        );

        // Warning should be shown
        expect(platformConsole.errorLines.single, contains('Warning'));
        // REPL should still work
        expect(platformConsole.outLines.last, equals('42'));
      });
    });

    group('command prefix edge cases', () {
      test('colon in middle of expression is not a command', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: ['1:2'], // This is a syntax error, not a command
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        // Should show syntax error, not "unknown command"
        expect(platformConsole.errorLines, isNotEmpty);
        expect(
          platformConsole.errorLines.single,
          isNot(contains('Unknown command')),
        );
      });

      test('input starting with colon but not a valid command format', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 1,
        );

        runCli([], console: console);

        expect(
          platformConsole.errorLines.single,
          contains("Unknown command ':'"),
        );
      });
    });

    group('REPL :delete after :load', () {
      test('can delete function loaded from file', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':load lib.prm', ':delete double', ':list'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'double(x) = x * 2',
        );

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains("Function 'double' deleted."));
        expect(
          platformConsole.outLines.last,
          equals('No user-defined functions.'),
        );
      });
    });

    group('REPL :rename after :load', () {
      test('can rename function loaded from file', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':load lib.prm', ':rename double twice', 'twice(5)'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'double(x) = x * 2',
        );

        expect(platformConsole.outLines.last, equals('10'));
      });
    });

    group('REPL :reset clears loaded functions', () {
      test(':reset after :load clears all functions', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole(
          inputs: [':load lib.prm', ':reset', ':list'],
        );
        final ScriptedConsole console = ScriptedConsole(
          platformConsole,
          promptIterations: 3,
        );

        runCli(
          [],
          console: console,
          readFile: (_) => 'double(x) = x * 2\ntriple(x) = x * 3',
        );

        final String allOutput = platformConsole.outLines.join('\n');
        expect(allOutput, contains('All user-defined functions cleared.'));
        expect(
          platformConsole.outLines.last,
          equals('No user-defined functions.'),
        );
      });
    });

    group('main function parameter variations', () {
      test('main with fewer arguments than parameters shows error', () {
        final FakePlatformConsole platformConsole = FakePlatformConsole();
        final Console console = Console(platformConsole);

        // When main expects args but fewer are provided, there's an error
        runCli(
          ['program.prm', 'only_one'],
          console: console,
          readFile: (_) => 'main(a, b) = a',
        );

        // Should show error for mismatched argument count
        expect(platformConsole.errorLines, isNotEmpty);
      });
    });
  });
}
