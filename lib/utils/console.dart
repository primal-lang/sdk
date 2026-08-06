import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/platform/console/platform_console_base.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';

class Console {
  static const String inputPrompt = '> ';
  static const String reset = '\x1b[0m';
  static const String red = '\x1b[31m';
  static const String green = '\x1b[32m';
  static const yellow = '\x1b[93m';

  final PlatformConsoleBase _platformConsole;

  Console([PlatformConsoleBase? platformConsole])
    : _platformConsole = platformConsole ?? PlatformInterface().console;

  /// Reads and handles input until there is none left.
  void prompt(void Function(String) handler) {
    while (promptOnce(handler)) {
      // Reading continues until the input ends.
    }
  }

  /// Reads and handles one line, returning whether there may be another.
  ///
  /// False means the input has ended: prompting again would print a prompt
  /// nobody can answer, and looping on it would never stop.
  ///
  /// A read that fails is not an ending and is deliberately not caught here. A
  /// stdin that cannot be read from is a run that failed rather than a session
  /// that finished, so the error travels out to whoever decides the exit code.
  ///
  /// A handler that threw is a different thing again: the line it was given was
  /// real, so the error is reported and reading carries on.
  bool promptOnce(void Function(String) handler) {
    _platformConsole.outWrite(inputPrompt);

    final String? input = _platformConsole.readLine();

    if (input == null) {
      return false;
    }

    try {
      if (input.isNotEmpty) {
        handler(input);
      }
    } catch (e) {
      error(e);
    }

    return true;
  }

  void write(String message) => _platformConsole.outWrite(message);

  void print(String message) => _platformConsole.outWriteLn(message);

  void warning(GenericWarning warning) =>
      _platformConsole.errorWriteLn('$yellow$warning$reset');

  void error(Object error) => _platformConsole.errorWriteLn('$red$error$reset');
}
