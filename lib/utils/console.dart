import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/platform/console/platform_console_base.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';

class Console {
  static const String inputPrompt = '> ';
  static const String reset = '\x1b[0m';
  static const String red = '\x1b[31m';
  static const yellow = '\x1b[93m';

  final PlatformConsoleBase _platformConsole;

  Console([PlatformConsoleBase? platformConsole])
    : _platformConsole = platformConsole ?? PlatformInterface().console;

  void prompt(void Function(String) handler) {
    while (true) {
      promptOnce(handler);
    }
  }

  void promptOnce(void Function(String) handler) {
    try {
      _platformConsole.outWrite(inputPrompt);
      final String input = _platformConsole.readLine();

      if (input.isNotEmpty) {
        handler(input);
      }
    } catch (e) {
      error(e);
    }
  }

  void write(String message) => _platformConsole.outWrite(message);

  void print(String message) => _platformConsole.outWriteLn(message);

  void warning(GenericWarning warning) =>
      _platformConsole.errorWriteLn('$yellow$warning$reset');

  void error(Object error) => _platformConsole.errorWriteLn('$red$error$reset');
}
