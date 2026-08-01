import 'dart:async';
import 'dart:io';

import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lowering/runtime_facade.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/compiler/semantic/intermediate_representation.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/syntactic/function_definition.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';
import 'package:primal/utils/console.dart';
import 'package:primal/utils/file_reader.dart';
import 'package:primal/utils/self_install.dart';

const String version = '0.5.3';

/// Reserved prefix for user test functions discovered by `--test`.
///
/// The standard library must never register a function under this prefix:
/// doing so would turn every existing user test into a duplicated-function
/// compile error.
const String testPrefix = 'test_';

/// Width of the widest `--test` result status (`ERROR`), used to align names.
const int _statusWidth = 5;

const String helpText = '''
Usage: primal [options] [file] [arguments...]

Options:
  --help, -h       Show this help
  --version, -v    Print the version string
  --debug, -d      Enable debug mode (timing, trace, verbose errors)
  --watch, -w      Watch file for changes and re-run on modification
  --test, -t       Run the "test_" functions in a file
  --update         Install the latest release over this one
  --uninstall      Remove Primal and its PATH entry

Examples:
  primal                     Start the REPL
  primal program.prm         Run a program with a main function
  primal program.prm arg1    Run a program with arguments
  primal -d                  Start the REPL in debug mode
  primal -w program.prm      Watch and re-run on changes
  primal -t program.prm      Run the tests in a file
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

/// Answered ahead of [runCli]: updating and uninstalling replace or delete the
/// running executable itself, which is the installer's job rather than anything
/// the compiler can do to the program it was handed.
Future<void> main(List<String> args) async {
  exitCode = isSelfInstallRequest(args)
      ? await runSelfInstall(args)
      : runCli(args);
}

/// Runs the CLI and returns the process exit code.
///
/// `exit()` is never called from here: the function is unit-tested in-process,
/// so terminating the VM would take the test runner down with it. Callers are
/// responsible for assigning the returned code to [exitCode].
///
/// - `0` — the run succeeded.
/// - `1` — the program under test failed to compile or threw at runtime.
/// - `2` — the invocation was wrong, so the run did not measure what it claimed
///   to (usage errors, and every failure of a `--test` run to reach the tests).
int runCli(
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
  bool watch = false;
  bool test = false;
  final List<String> remainingArgs = [];

  for (final String argument in args) {
    switch (argument) {
      case '--help' || '-h':
        currentConsole.print(helpText);
        return 0;
      case '--version' || '-v':
        currentConsole.print(version);
        return 0;
      case '--debug' || '-d':
        debug = true;
      case '--watch' || '-w':
        watch = true;
      case '--test' || '-t':
        test = true;
      default:
        remainingArgs.add(argument);
    }
  }

  if (test) {
    if (watch) {
      currentConsole.error('Error: --test cannot be combined with --watch.');
      return 2;
    }

    if (remainingArgs.length != 1) {
      currentConsole.error('Error: --test requires exactly one file argument.');
      return 2;
    }

    return _runTests(
      filePath: remainingArgs[0],
      compiler: compiler,
      console: currentConsole,
      debug: debug,
      sourceReader: sourceReader,
    );
  }

  if (watch && remainingArgs.isEmpty) {
    currentConsole.error('Watch mode requires a file argument.');
    return 2;
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

      if (watch) {
        _watchFile(
          filePath: remainingArgs[0],
          args: remainingArgs,
          compiler: compiler,
          console: currentConsole,
          debug: debug,
          sourceReader: sourceReader,
        );
      }
    } else {
      if (watch) {
        currentConsole.error(
          'Watch mode requires a file with a main function.',
        );
        return 2;
      }
      _runRepl(
        runtime: runtime,
        compiler: compiler,
        console: currentConsole,
        debug: debug,
        sourceReader: sourceReader,
      );
    }

    // Watch mode returns while the process is still alive: the file
    // subscription is what keeps it up, and SIGINT exits with 0. The REPL is
    // unreachable here in production because Console.prompt loops forever.
    return 0;
  } catch (e, stackTrace) {
    currentConsole.error(e);
    if (debug) {
      currentConsole.print('[debug] Stack trace:\n$stackTrace');
    }

    return 1;
  }
}

/// Compiles and runs the `test_` functions of a single file.
///
/// The file is compiled once and every discovered test is evaluated against the
/// same runtime, in source-declaration order.
int _runTests({
  required String filePath,
  required Compiler compiler,
  required Console console,
  required bool debug,
  required String Function(String) sourceReader,
}) {
  // The runner owns its error boundary rather than relying on runCli's
  // catch-all: a file that cannot be read or built means the run did not
  // measure what it claimed to, which is 2 and not 1.
  final RuntimeFacade? runtime = _buildForTests(
    filePath: filePath,
    compiler: compiler,
    console: console,
    debug: debug,
    sourceReader: sourceReader,
  );

  if (runtime == null) {
    return 2;
  }

  final List<SemanticFunction> discovered = runtime
      .intermediateRepresentation
      .customFunctions
      .values
      .where(
        (SemanticFunction function) => function.name.startsWith(testPrefix),
      )
      .toList();

  if (discovered.isEmpty) {
    console.error(
      'Error: no zero-argument functions with the "$testPrefix" prefix '
      'found in $filePath',
    );
    return 2;
  }

  int passed = 0;
  int failed = 0;
  int errored = 0;
  int skipped = 0;

  for (final SemanticFunction function in discovered) {
    // Reported rather than silently skipped: a test that accidentally gained a
    // parameter must not disappear from the run.
    if (function.parameters.isNotEmpty) {
      skipped++;
      console.error(
        'Error: skipped "${function.name}" — test functions must take no '
        'parameters',
      );
      continue;
    }

    final Stopwatch executionWatch = Stopwatch();

    if (debug) {
      executionWatch.start();
    }

    try {
      // Built the way RuntimeFacade.mainExpression already builds its call.
      final Expression expression = compiler.expression('${function.name}()');

      // evaluateToTerm, not evaluate: classification must read the term rather
      // than formatted output, and this is also what resets recursion depth.
      final Term result = runtime.evaluateToTerm(expression);
      executionWatch.stop();

      if ((result is BooleanTerm) && result.value) {
        passed++;
        console.print(
          _testLine(
            status: 'PASS',
            color: Console.green,
            name: function.name,
            debug: debug,
            executionWatch: executionWatch,
          ),
        );
      } else {
        errored++;
        console.print(
          _testLine(
            status: 'ERROR',
            color: Console.red,
            name: function.name,
            debug: debug,
            executionWatch: executionWatch,
          ),
        );
        console.print(
          _detailLine(
            'test "${function.name}" did not return true '
            '(returned ${Runtime.render(result)})',
          ),
        );
      }
    } on AssertionFailedError catch (error) {
      executionWatch.stop();
      failed++;
      console.print(
        _testLine(
          status: 'FAIL',
          color: Console.red,
          name: function.name,
          debug: debug,
          executionWatch: executionWatch,
        ),
      );
      console.print(_detailLine(error.toString()));
    } on RuntimeError catch (error) {
      executionWatch.stop();
      errored++;
      console.print(
        _testLine(
          status: 'ERROR',
          color: Console.red,
          name: function.name,
          debug: debug,
          executionWatch: executionWatch,
        ),
      );
      console.print(_detailLine(error.toString()));
    } catch (throwable, stackTrace) {
      // A non-RuntimeError means the runtime can no longer be trusted, so no
      // further tests run. The partial report is still printed: discarding it
      // would hide which tests had already passed.
      executionWatch.stop();
      _printTestSummary(
        console,
        passed: passed,
        failed: failed,
        errored: errored,
        skipped: skipped,
      );
      console.error('Error: aborted at "${function.name}": $throwable');

      if (debug) {
        console.print('[debug] Stack trace:\n$stackTrace');
      }

      return 2;
    }
  }

  _printTestSummary(
    console,
    passed: passed,
    failed: failed,
    errored: errored,
    skipped: skipped,
  );

  if (skipped > 0) {
    return 2;
  }

  if ((failed > 0) || (errored > 0)) {
    return 1;
  }

  return 0;
}

/// Reads and compiles [filePath], returning null when the file cannot be built.
RuntimeFacade? _buildForTests({
  required String filePath,
  required Compiler compiler,
  required Console console,
  required bool debug,
  required String Function(String) sourceReader,
}) {
  try {
    final Stopwatch compileWatch = Stopwatch();

    if (debug) {
      compileWatch.start();
    }

    final IntermediateRepresentation intermediateRepresentation = compiler
        .compile(sourceReader(filePath));

    if (debug) {
      compileWatch.stop();
      console.print(
        '[debug] Compilation: ${compileWatch.elapsedMilliseconds}ms',
      );
    }

    for (final GenericWarning warning in intermediateRepresentation.warnings) {
      console.warning(warning);
    }

    return RuntimeFacade(intermediateRepresentation, compiler.expression);
  } catch (e, stackTrace) {
    console.error(e);

    if (debug) {
      console.print('[debug] Stack trace:\n$stackTrace');
    }

    return null;
  }
}

String _testLine({
  required String status,
  required String color,
  required String name,
  required bool debug,
  required Stopwatch executionWatch,
}) {
  // Padded to the width of the longest status so names line up. The padding
  // sits outside the colour codes: padRight would otherwise count the escape
  // sequences as visible characters and misalign the column.
  final String padding = ' ' * (_statusWidth - status.length);
  final String line = '$color$status${Console.reset}$padding $name';

  return debug ? '$line [${executionWatch.elapsedMilliseconds}ms]' : line;
}

String _detailLine(String message) => '      $message';

void _printTestSummary(
  Console console, {
  required int passed,
  required int failed,
  required int errored,
  required int skipped,
}) {
  final int total = passed + failed + errored + skipped;

  // Only reachable when a run aborts on its very first test: there is no
  // partial report to summarise, and "0 tests: 0 passed" would read green.
  if (total == 0) {
    return;
  }

  final List<String> categories = [
    if (passed > 0) '$passed passed',
    if (failed > 0) '$failed failed',
    if (errored > 0) '$errored error',
    if (skipped > 0) '$skipped skipped',
  ];

  console.print('');
  console.print(
    '$total test${total == 1 ? '' : 's'}: ${categories.join(', ')}',
  );
}

void _printBanner(Console console) {
  // Get terminal width, fallback to 60 if not available
  final int terminalWidth = stdout.hasTerminal ? stdout.terminalColumns : 60;
  final int boxWidth = terminalWidth - 2 < 30 ? 30 : terminalWidth - 2;

  final String directory = _shortenHomePath(Directory.current.path);

  // Truncate directory if too long to fit in box
  // Line format: "v$version • $directory" must fit in boxWidth - 1
  // Prefix is: "v" (1) + version + " • " (3) = version.length + 4
  final int maxDirectoryLength = boxWidth - version.length - 5;
  final String truncatedDirectory = directory.length > maxDirectoryLength
      ? '...${directory.substring(directory.length - (maxDirectoryLength - 3))}'
      : directory;
  final String horizontal = '\u2500' * boxWidth;
  final String topBorder = '\u250c$horizontal\u2510';
  final String bottomBorder = '\u2514$horizontal\u2518';
  const String vertical = '\u2502';

  // Block letter "PRIMAL" logo - each block character is 1 display cell wide
  final List<String> lines = [
    '\u2588\u2580\u2588 \u2588\u2580\u2588 \u2588 \u2588\u2580\u2584\u2580\u2588 \u2588\u2580\u2588 \u2588',
    '\u2588\u2580\u2580 \u2588\u2580\u2584 \u2588 \u2588 \u2580 \u2588 \u2588\u2580\u2588 \u2588\u2584\u2584',
    'v$version \u2022 $truncatedDirectory',
    ':help \u2022 :load <file> \u2022 :quit',
  ];

  console.print(topBorder);
  for (final String line in lines) {
    // padRight works correctly since all characters are 1 display cell wide
    console.print('$vertical ${line.padRight(boxWidth - 1)}$vertical');
  }
  console.print(bottomBorder);
}

String _shortenHomePath(String path) {
  // Only shorten on Unix-like systems (where HOME is typically set)
  final String? home = Platform.environment['HOME'];
  if (home != null && path.startsWith(home)) {
    return '~${path.substring(home.length)}';
  }
  return path;
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

void _watchFile({
  required String filePath,
  required List<String> args,
  required Compiler compiler,
  required Console console,
  required bool debug,
  required String Function(String) sourceReader,
}) {
  final File file = File(filePath);
  final Stream<FileSystemEvent> watcher = file.watch(
    events: FileSystemEvent.modify,
  );

  Timer? debounceTimer;

  watcher.listen((_) {
    // Debounce: cancel any pending reload and schedule a new one.
    // This handles editors that trigger multiple events per save.
    debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 100), () {
      console.write('\x1b[2J\x1b[H');
      //console.print('File changed, reloading...\n');

      try {
        final Stopwatch compileWatch = Stopwatch();
        if (debug) {
          compileWatch.start();
        }

        final IntermediateRepresentation intermediateRepresentation = compiler
            .compile(sourceReader(filePath));

        if (debug) {
          compileWatch.stop();
          console.print(
            '[debug] Compilation: ${compileWatch.elapsedMilliseconds}ms',
          );
        }

        for (final GenericWarning warning
            in intermediateRepresentation.warnings) {
          console.warning(warning);
        }

        final RuntimeFacade runtime = RuntimeFacade(
          intermediateRepresentation,
          compiler.expression,
        );

        if (runtime.hasMain) {
          _executeMain(
            runtime: runtime,
            args: args,
            console: console,
            debug: debug,
          );
        } else {
          console.error('main function no longer found in $filePath');
        }
      } catch (e, stackTrace) {
        console.error(e);
        if (debug) {
          console.print('[debug] Stack trace:\n$stackTrace');
        }
      }
    });
  });

  // The stream subscription keeps the process alive.
  // Handle Ctrl+C gracefully.
  ProcessSignal.sigint.watch().first.then((_) => exit(0));
}

void _runRepl({
  required RuntimeFacade runtime,
  required Compiler compiler,
  required Console console,
  required bool debug,
  required String Function(String) sourceReader,
}) {
  bool debugMode = debug;

  _printBanner(console);

  console.prompt((input) {
    try {
      if (debugMode) {
        console.print('[debug] Input: $input');
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
      console.write('\x1b[2J\x1b[H');
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
