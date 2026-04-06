import 'dart:io';

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

const String replHelpText = '''
REPL Commands:
  :help                Show this help
  :version             Show version info
  :clear               Clear the screen
  :quit, :q, :exit     Exit the REPL
  :debug on/off        Toggle debug mode
  :list                Show all user-defined functions
  :delete <name>       Remove a user-defined function
  :rename <old> <new>  Rename a user-defined function
  :load <file>         Load definitions from a file (resets session)
  :run <file>          Load definitions and run main if available
  :reset               Clear all user-defined functions
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
        sourceReader: sourceReader,
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
  required String Function(String) sourceReader,
}) {
  bool debugMode = debug;

  console.prompt((input) {
    try {
      if (debugMode) {
        console.print('[debug] Input: $input');
      }

      // Handle Ctrl+L (form feed) to clear screen
      if (input == '\x0c') {
        console.print('\x1b[2J\x1b[H');
        return;
      }

      // Handle REPL commands
      if (_handleReplCommand(
        input: input,
        runtime: runtime,
        compiler: compiler,
        console: console,
        debugMode: debugMode,
        setDebugMode: (bool value) => debugMode = value,
        sourceReader: sourceReader,
      )) {
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

      if (debugMode) {
        parseWatch.start();
      }

      final Expression expression = compiler.expression(input);

      if (debugMode) {
        parseWatch.stop();
        console.print('[debug] Parsing: ${parseWatch.elapsedMilliseconds}ms');
        evalWatch.start();
      }

      final String result = runtime.evaluate(expression);

      if (debugMode) {
        evalWatch.stop();
        console.print('[debug] Evaluation: ${evalWatch.elapsedMilliseconds}ms');
      }

      console.print(result);
    } catch (e, stackTrace) {
      console.error(e);
      if (debugMode) {
        console.print('[debug] Stack trace:\n$stackTrace');
      }
    }
  });
}

/// Handles REPL commands (inputs starting with ':').
///
/// Returns true if the input was handled as a command, false otherwise.
bool _handleReplCommand({
  required String input,
  required RuntimeFacade runtime,
  required Compiler compiler,
  required Console console,
  required bool debugMode,
  required void Function(bool) setDebugMode,
  required String Function(String) sourceReader,
}) {
  if (!input.startsWith(':')) {
    return false;
  }

  // Commands with arguments
  if (input == ':delete' || input.startsWith(':delete ')) {
    final String name = input.length > ':delete '.length
        ? input.substring(':delete '.length).trim()
        : '';
    if (name.isEmpty) {
      console.error('Usage: :delete <function_name>');
    } else {
      runtime.deleteFunction(name);
      console.print("Function '$name' deleted.");
    }
    return true;
  }

  if (input == ':rename' || input.startsWith(':rename ')) {
    final String arguments = input.length > ':rename '.length
        ? input.substring(':rename '.length).trim()
        : '';
    final List<String> parts = arguments.split(RegExp(r'\s+'));
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      console.error('Usage: :rename <old_name> <new_name>');
    } else {
      runtime.renameFunction(parts[0], parts[1]);
      console.print("Function '${parts[0]}' renamed to '${parts[1]}'.");
    }
    return true;
  }

  if (input == ':load' || input.startsWith(':load ')) {
    final String filePath = input.length > ':load '.length
        ? input.substring(':load '.length).trim()
        : '';
    if (filePath.isEmpty) {
      console.error('Usage: :load <file_path>');
    } else {
      final String source = sourceReader(filePath);
      final IntermediateRepresentation representation = compiler.compile(
        source,
      );
      for (final GenericWarning warning in representation.warnings) {
        console.warning(warning);
      }
      final int count = runtime.loadFromIntermediateRepresentation(
        representation,
      );
      console.print('Loaded $count function(s) from $filePath.');
    }
    return true;
  }

  if (input == ':run' || input.startsWith(':run ')) {
    final String filePath = input.length > ':run '.length
        ? input.substring(':run '.length).trim()
        : '';
    if (filePath.isEmpty) {
      console.error('Usage: :run <file_path>');
    } else {
      final String source = sourceReader(filePath);
      final IntermediateRepresentation representation = compiler.compile(
        source,
      );
      for (final GenericWarning warning in representation.warnings) {
        console.warning(warning);
      }
      final int count = runtime.loadFromIntermediateRepresentation(
        representation,
      );
      console.print('Loaded $count function(s) from $filePath.');
      if (runtime.hasMain) {
        final String result = runtime.executeMain();
        console.print(result);
      }
    }
    return true;
  }

  // Commands without arguments
  switch (input) {
    case ':version':
      console.print(version);
    case ':help':
      console.print(replHelpText);
    case ':quit' || ':q' || ':exit':
      exit(0);
    case ':clear':
      console.print('\x1b[2J\x1b[H');
    case ':debug on':
      setDebugMode(true);
      console.print('Debug mode enabled.');
    case ':debug off':
      setDebugMode(false);
      console.print('Debug mode disabled.');
    case ':list':
      final List<String> signatures = runtime.userDefinedFunctionSignatures;
      if (signatures.isEmpty) {
        console.print('No user-defined functions.');
      } else {
        console.print(signatures.join('\n'));
      }
    case ':reset':
      runtime.reset();
      console.print('All user-defined functions cleared.');
    default:
      console.error(
        "Unknown command '$input'. Type :help for available commands.",
      );
  }
  return true;
}
