@Tags(['unit'])
@TestOn('vm')
library;

import 'package:primal/compiler/warnings/generic_warning.dart';
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

  group('Console static constants', () {
    test('inputPrompt is "> "', () {
      expect(Console.inputPrompt, equals('> '));
    });

    test('reset is ANSI reset escape code', () {
      expect(Console.reset, equals('\x1b[0m'));
    });

    test('red is ANSI red escape code', () {
      expect(Console.red, equals('\x1b[31m'));
    });

    test('yellow is ANSI yellow escape code', () {
      expect(Console.yellow, equals('\x1b[93m'));
    });
  });

  group('Console.write()', () {
    test('writes message to stdout without newline', () {
      console.write('hello');

      expect(platformConsole.outWrites, equals(['hello']));
      expect(platformConsole.outLines, isEmpty);
    });

    test('writes empty string to stdout', () {
      console.write('');

      expect(platformConsole.outWrites, equals(['']));
    });

    test('writes multiple messages to stdout', () {
      console.write('first');
      console.write('second');
      console.write('third');

      expect(platformConsole.outWrites, equals(['first', 'second', 'third']));
    });

    test('writes message with special characters', () {
      console.write('hello\tworld');

      expect(platformConsole.outWrites, equals(['hello\tworld']));
    });

    test('writes message with unicode characters', () {
      console.write('hello \u2603 world');

      expect(platformConsole.outWrites, equals(['hello \u2603 world']));
    });

    test('writes message with embedded newlines', () {
      console.write('line1\nline2');

      expect(platformConsole.outWrites, equals(['line1\nline2']));
    });
  });

  group('Console.print()', () {
    test('writes message to stdout', () {
      console.print('hello');

      expect(platformConsole.outLines, equals(['hello']));
    });

    test('writes empty string to stdout', () {
      console.print('');

      expect(platformConsole.outLines, equals(['']));
    });

    test('writes multiple messages to stdout', () {
      console.print('first');
      console.print('second');
      console.print('third');

      expect(platformConsole.outLines, equals(['first', 'second', 'third']));
    });

    test('writes message with special characters', () {
      console.print('hello\tworld');

      expect(platformConsole.outLines, equals(['hello\tworld']));
    });

    test('writes message with unicode characters', () {
      console.print('hello \u2603 world');

      expect(platformConsole.outLines, equals(['hello \u2603 world']));
    });

    test('writes message with embedded newlines', () {
      console.print('line1\nline2');

      expect(platformConsole.outLines, equals(['line1\nline2']));
    });
  });

  group('Console.warning()', () {
    test('writes formatted warning to stderr', () {
      const SemanticWarning warning = SemanticWarning('test warning');
      console.warning(warning);

      expect(
        platformConsole.errorLines,
        equals(['${Console.yellow}$warning${Console.reset}']),
      );
    });

    test('writes GenericWarning to stderr', () {
      const GenericWarning warning = GenericWarning('generic warning message');
      console.warning(warning);

      expect(
        platformConsole.errorLines,
        equals(['${Console.yellow}$warning${Console.reset}']),
      );
    });

    test('writes UnusedParameterWarning to stderr', () {
      const UnusedParameterWarning warning = UnusedParameterWarning(
        function: 'testFunction',
        parameter: 'unusedParam',
      );
      console.warning(warning);

      expect(
        platformConsole.errorLines,
        equals(['${Console.yellow}$warning${Console.reset}']),
      );
      expect(
        platformConsole.errorLines.single,
        contains('Unused parameter "unusedParam" in function "testFunction"'),
      );
    });

    test('writes multiple warnings to stderr', () {
      const SemanticWarning warning1 = SemanticWarning('first warning');
      const SemanticWarning warning2 = SemanticWarning('second warning');
      console.warning(warning1);
      console.warning(warning2);

      expect(platformConsole.errorLines, hasLength(2));
      expect(
        platformConsole.errorLines[0],
        equals('${Console.yellow}$warning1${Console.reset}'),
      );
      expect(
        platformConsole.errorLines[1],
        equals('${Console.yellow}$warning2${Console.reset}'),
      );
    });

    test('writes warning with special characters to stderr', () {
      const SemanticWarning warning = SemanticWarning('warning with\ttab');
      console.warning(warning);

      expect(
        platformConsole.errorLines.single,
        contains('warning with\ttab'),
      );
    });
  });

  group('Console.error()', () {
    test('writes formatted error to stderr', () {
      console.error(Exception('test'));

      expect(
        platformConsole.errorLines,
        equals(['${Console.red}Exception: test${Console.reset}']),
      );
    });

    test('writes StateError to stderr', () {
      console.error(StateError('bad state'));

      expect(
        platformConsole.errorLines,
        equals(['${Console.red}Bad state: bad state${Console.reset}']),
      );
    });

    test('writes ArgumentError to stderr', () {
      console.error(ArgumentError('invalid argument'));

      expect(
        platformConsole.errorLines,
        equals([
          '${Console.red}Invalid argument(s): invalid argument${Console.reset}',
        ]),
      );
    });

    test('writes FormatException to stderr', () {
      console.error(const FormatException('invalid format'));

      expect(
        platformConsole.errorLines,
        equals([
          '${Console.red}FormatException: invalid format${Console.reset}',
        ]),
      );
    });

    test('writes String error to stderr', () {
      console.error('string error message');

      expect(
        platformConsole.errorLines,
        equals(['${Console.red}string error message${Console.reset}']),
      );
    });

    test('writes integer error to stderr', () {
      console.error(42);

      expect(
        platformConsole.errorLines,
        equals(['${Console.red}42${Console.reset}']),
      );
    });

    test('writes multiple errors to stderr', () {
      console.error(Exception('first'));
      console.error(Exception('second'));

      expect(platformConsole.errorLines, hasLength(2));
      expect(
        platformConsole.errorLines[0],
        equals('${Console.red}Exception: first${Console.reset}'),
      );
      expect(
        platformConsole.errorLines[1],
        equals('${Console.red}Exception: second${Console.reset}'),
      );
    });

    test('writes error with special characters to stderr', () {
      console.error(Exception('error with\nnewline'));

      expect(
        platformConsole.errorLines.single,
        contains('error with\nnewline'),
      );
    });

    test('writes error with unicode characters to stderr', () {
      console.error(Exception('error \u2603 snowman'));

      expect(
        platformConsole.errorLines.single,
        contains('error \u2603 snowman'),
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

    test('forwards whitespace-only input to handler', () {
      platformConsole = FakePlatformConsole(inputs: ['   ']);
      console = Console(platformConsole);
      final List<String> inputs = <String>[];

      console.promptOnce(inputs.add);

      expect(inputs, equals(['   ']));
    });

    test('forwards input with leading whitespace to handler', () {
      platformConsole = FakePlatformConsole(inputs: ['  hello']);
      console = Console(platformConsole);
      final List<String> inputs = <String>[];

      console.promptOnce(inputs.add);

      expect(inputs, equals(['  hello']));
    });

    test('forwards input with trailing whitespace to handler', () {
      platformConsole = FakePlatformConsole(inputs: ['hello  ']);
      console = Console(platformConsole);
      final List<String> inputs = <String>[];

      console.promptOnce(inputs.add);

      expect(inputs, equals(['hello  ']));
    });

    test('forwards input with special characters to handler', () {
      platformConsole = FakePlatformConsole(inputs: ['hello\tworld']);
      console = Console(platformConsole);
      final List<String> inputs = <String>[];

      console.promptOnce(inputs.add);

      expect(inputs, equals(['hello\tworld']));
    });

    test('forwards input with unicode characters to handler', () {
      platformConsole = FakePlatformConsole(inputs: ['hello \u2603']);
      console = Console(platformConsole);
      final List<String> inputs = <String>[];

      console.promptOnce(inputs.add);

      expect(inputs, equals(['hello \u2603']));
    });

    test('processes multiple consecutive calls', () {
      platformConsole = FakePlatformConsole(
        inputs: ['first', 'second', 'third'],
      );
      console = Console(platformConsole);
      final List<String> inputs = <String>[];

      console.promptOnce(inputs.add);
      console.promptOnce(inputs.add);
      console.promptOnce(inputs.add);

      expect(platformConsole.outWrites, equals(['> ', '> ', '> ']));
      expect(inputs, equals(['first', 'second', 'third']));
    });

    test('handles mixed empty and non-empty inputs', () {
      platformConsole = FakePlatformConsole(inputs: ['first', '', 'third']);
      console = Console(platformConsole);
      final List<String> inputs = <String>[];

      console.promptOnce(inputs.add);
      console.promptOnce(inputs.add);
      console.promptOnce(inputs.add);

      expect(inputs, equals(['first', 'third']));
    });

    test('reports ArgumentError via console.error', () {
      platformConsole = FakePlatformConsole(inputs: ['hello']);
      console = Console(platformConsole);

      console.promptOnce((_) => throw ArgumentError('invalid'));

      expect(
        platformConsole.errorLines.single,
        contains('Invalid argument(s): invalid'),
      );
    });

    test('reports FormatException via console.error', () {
      platformConsole = FakePlatformConsole(inputs: ['hello']);
      console = Console(platformConsole);

      console.promptOnce((_) => throw const FormatException('bad format'));

      expect(
        platformConsole.errorLines.single,
        contains('FormatException: bad format'),
      );
    });

    test('continues after handler error with multiple calls', () {
      platformConsole = FakePlatformConsole(inputs: ['first', 'second']);
      console = Console(platformConsole);
      final List<String> inputs = <String>[];
      int callCount = 0;

      console.promptOnce((String input) {
        callCount++;
        if (callCount == 1) {
          throw StateError('first call error');
        }
        inputs.add(input);
      });
      console.promptOnce(inputs.add);

      expect(platformConsole.errorLines, hasLength(1));
      expect(inputs, equals(['second']));
    });

    test('handles input exhaustion gracefully', () {
      platformConsole = FakePlatformConsole(inputs: ['only']);
      console = Console(platformConsole);
      final List<String> inputs = <String>[];

      console.promptOnce(inputs.add);
      console.promptOnce(inputs.add); // No more inputs, returns empty string

      expect(inputs, equals(['only']));
    });
  });

  group('Console.prompt()', () {
    test('calls promptOnce repeatedly', () {
      platformConsole = FakePlatformConsole(inputs: ['a', 'b', 'c']);
      final ScriptedConsole scriptedConsole = ScriptedConsole(
        platformConsole,
        promptIterations: 3,
      );
      final List<String> inputs = <String>[];

      scriptedConsole.prompt(inputs.add);

      expect(platformConsole.outWrites, equals(['> ', '> ', '> ']));
      expect(inputs, equals(['a', 'b', 'c']));
    });

    test('processes single iteration', () {
      platformConsole = FakePlatformConsole(inputs: ['single']);
      final ScriptedConsole scriptedConsole = ScriptedConsole(
        platformConsole,
        promptIterations: 1,
      );
      final List<String> inputs = <String>[];

      scriptedConsole.prompt(inputs.add);

      expect(platformConsole.outWrites, equals(['> ']));
      expect(inputs, equals(['single']));
    });

    test('processes zero iterations', () {
      platformConsole = FakePlatformConsole(inputs: ['unused']);
      final ScriptedConsole scriptedConsole = ScriptedConsole(
        platformConsole,
        promptIterations: 0,
      );
      final List<String> inputs = <String>[];

      scriptedConsole.prompt(inputs.add);

      expect(platformConsole.outWrites, isEmpty);
      expect(inputs, isEmpty);
    });

    test('handles mixed empty and non-empty inputs', () {
      platformConsole = FakePlatformConsole(inputs: ['a', '', 'b', '', 'c']);
      final ScriptedConsole scriptedConsole = ScriptedConsole(
        platformConsole,
        promptIterations: 5,
      );
      final List<String> inputs = <String>[];

      scriptedConsole.prompt(inputs.add);

      expect(platformConsole.outWrites, hasLength(5));
      expect(inputs, equals(['a', 'b', 'c']));
    });

    test('continues after handler errors', () {
      platformConsole = FakePlatformConsole(inputs: ['a', 'b', 'c']);
      final ScriptedConsole scriptedConsole = ScriptedConsole(
        platformConsole,
        promptIterations: 3,
      );
      final List<String> inputs = <String>[];
      int callCount = 0;

      scriptedConsole.prompt((String input) {
        callCount++;
        if (callCount == 2) {
          throw StateError('error on second call');
        }
        inputs.add(input);
      });

      expect(platformConsole.errorLines, hasLength(1));
      expect(inputs, equals(['a', 'c']));
    });
  });

  group('Console combined operations', () {
    test('write and print do not interfere with each other', () {
      console.write('write1');
      console.print('print1');
      console.write('write2');
      console.print('print2');

      expect(platformConsole.outWrites, equals(['write1', 'write2']));
      expect(platformConsole.outLines, equals(['print1', 'print2']));
    });

    test('warning and error do not interfere with each other', () {
      const SemanticWarning warning = SemanticWarning('a warning');
      console.warning(warning);
      console.error(Exception('an error'));
      console.warning(warning);

      expect(platformConsole.errorLines, hasLength(3));
      expect(platformConsole.errorLines[0], startsWith(Console.yellow));
      expect(platformConsole.errorLines[1], startsWith(Console.red));
      expect(platformConsole.errorLines[2], startsWith(Console.yellow));
    });

    test('stdout and stderr operations are independent', () {
      console.print('stdout message');
      console.error(Exception('stderr message'));
      console.write('another stdout');
      console.warning(const SemanticWarning('another stderr'));

      expect(platformConsole.outLines, equals(['stdout message']));
      expect(platformConsole.outWrites, equals(['another stdout']));
      expect(platformConsole.errorLines, hasLength(2));
    });

    test('promptOnce followed by print', () {
      platformConsole = FakePlatformConsole(inputs: ['input']);
      console = Console(platformConsole);
      final List<String> inputs = <String>[];

      console.promptOnce(inputs.add);
      console.print('output');

      expect(platformConsole.outWrites, equals(['> ']));
      expect(platformConsole.outLines, equals(['output']));
      expect(inputs, equals(['input']));
    });

    test('promptOnce with handler that calls print', () {
      platformConsole = FakePlatformConsole(inputs: ['hello']);
      console = Console(platformConsole);

      console.promptOnce((String input) {
        console.print('Received: $input');
      });

      expect(platformConsole.outWrites, equals(['> ']));
      expect(platformConsole.outLines, equals(['Received: hello']));
    });

    test('promptOnce with handler that calls error', () {
      platformConsole = FakePlatformConsole(inputs: ['test']);
      console = Console(platformConsole);

      console.promptOnce((String input) {
        console.error(Exception('error for $input'));
      });

      expect(
        platformConsole.errorLines.single,
        contains('error for test'),
      );
    });
  });
}
