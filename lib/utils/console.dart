import 'dart:io';

import 'package:dry/compiler/warnings/generic_warning.dart';

class Console {
  static const String reset = '\x1b[0m';
  static const String red = '\x1b[31m';
  static const yellow = '\x1b[93m';

  String prompt() {
    stdout.write('> ');
    final String? input = stdin.readLineSync();

    return input != null ? input.trim() : '';
  }

  void print(String message) => stdout.writeln(message);

  void warning(GenericWarning warning) =>
      stderr.writeln('$yellow$warning$reset');

  void error(Object error) {
    stderr.writeln('$red$error$reset');
  }
}
