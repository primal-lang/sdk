import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';
import 'package:primal/utils/console.dart';
import 'package:primal/utils/file_reader.dart';

const String version = '0.4.3';

const String helpText = '''
Usage: primal [options] [file] [arguments...]

Options:
  --help, -h       Show this help
  --version, -v    Print the version string
  --debug, -d      Enable debug mode (timing, trace, verbose errors)

Examples:
  primal                     Start the REPL
  primal program.pri         Run a program with a main function
  primal program.pri arg1    Run a program with arguments
  primal -d                  Start the REPL in debug mode
''';

void main(List<String> args) => runCli(args);

void runCli(
  List<String> args, {
  Console? console,
  Compiler compiler = const Compiler(),
  String Function(String filePath)? readFile,
}) {
  final Console currentConsole = console ?? Console();
  final String Function(String filePath) sourceReader =
      readFile ?? FileReader.read;

  // Parse flags
  bool debug = false;
  final List<String> remainingArgs = [];

  for (final String argument in args) {
    switch (argument) {
      case '--help' || '-h':
        currentConsole.print(helpText);
        return;
      case '--version' || '-v':
        currentConsole.print('Primal $version');
        return;
      case '--debug' || '-d':
        debug = true;
      default:
        remainingArgs.add(argument);
    }
  }

  try {
    final Stopwatch compileWatch = Stopwatch();

    if (debug) {
      compileWatch.start();
    }

    final IntermediateRepresentation intermediateRepresentation =
        remainingArgs.isNotEmpty
        ? compiler.compile(sourceReader(remainingArgs[0]))
        : IntermediateRepresentation.empty();

    if (debug && remainingArgs.isNotEmpty) {
      compileWatch.stop();
      currentConsole.print(
        '[debug] Compilation: ${compileWatch.elapsedMilliseconds}ms',
      );
    }

    for (final GenericWarning warning in intermediateRepresentation.warnings) {
      currentConsole.warning(warning);
    }

    final RuntimeFacade runtime = RuntimeFacade(
      intermediateRepresentation,
      compiler.expression,
    );

    if (runtime.hasMain) {
      _executeMain(
        runtime: runtime,
        args: remainingArgs,
        console: currentConsole,
        debug: debug,
      );
    } else {
      _runRepl(
        runtime: runtime,
        compiler: compiler,
        console: currentConsole,
        debug: debug,
      );
    }
  } catch (e, stackTrace) {
    currentConsole.error(e);
    if (debug) {
      currentConsole.print('[debug] Stack trace:\n$stackTrace');
    }
  }
}

void _executeMain({
  required RuntimeFacade runtime,
  required List<String> args,
  required Console console,
  required bool debug,
}) {
  final Stopwatch execWatch = Stopwatch();
  final List<String> programArgs = (args.length > 1) ? args.sublist(1) : [];

  if (debug) {
    console.print(
      '[debug] Executing: main(${programArgs.map((e) => '"$e"').join(', ')})',
    );
    execWatch.start();
  }

  final String result = runtime.executeMain(programArgs);

  if (debug) {
    execWatch.stop();
    console.print('[debug] Execution: ${execWatch.elapsedMilliseconds}ms');
  }

  console.print(result);
}

void _runRepl({
  required RuntimeFacade runtime,
  required Compiler compiler,
  required Console console,
  required bool debug,
}) {
  console.prompt((input) {
    try {
      if (debug) {
        console.print('[debug] Input: $input');
      }

      // Handle REPL commands
      if (input == ':version') {
        console.print(version);
        return;
      }

      // Try to parse as a function definition first
      final FunctionDefinition? functionDefinition = compiler
          .functionDefinition(input);

      if (functionDefinition != null) {
        // Define the function and continue (no output)
        runtime.defineFunction(functionDefinition);
        return;
      }

      // Otherwise, evaluate as an expression
      final Stopwatch parseWatch = Stopwatch();
      final Stopwatch evalWatch = Stopwatch();

      if (debug) {
        parseWatch.start();
      }

      final Expression expression = compiler.expression(input);

      if (debug) {
        parseWatch.stop();
        console.print('[debug] Parsing: ${parseWatch.elapsedMilliseconds}ms');
        evalWatch.start();
      }

      final String result = runtime.evaluate(expression);

      if (debug) {
        evalWatch.stop();
        console.print('[debug] Evaluation: ${evalWatch.elapsedMilliseconds}ms');
      }

      console.print(result);
    } catch (e, stackTrace) {
      console.error(e);
      if (debug) {
        console.print('[debug] Stack trace:\n$stackTrace');
      }
    }
  });
}
