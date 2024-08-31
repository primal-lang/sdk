import 'package:primal/compiler/platform/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/platform_web.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';

class Console {
  static const String reset = '\x1b[0m';
  static const String red = '\x1b[31m';
  static const yellow = '\x1b[93m';

  void prompt(Function(String) handler) {
    while (true) {
      try {
        PlatformInterface().outWrite('> ');
        final String input = PlatformInterface().readLine();

        if (input.isNotEmpty) {
          handler(input);
        }
      } catch (e) {
        error(e);
      }
    }
  }

  void print(String message) => PlatformInterface().outWriteLn(message);

  void warning(GenericWarning warning) =>
      PlatformInterface().errorWriteLn('$yellow$warning$reset');

  void error(Object error) =>
      PlatformInterface().errorWriteLn('$red$error$reset');
}
