import 'dart:io';
import 'package:dry/compiler/warnings/generic_warning.dart';

class Console {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const yellow = '\x1B[33m';

  String prompt() {
    stdout.write('> ');
    final String? input = stdin.readLineSync();

    return input != null ? input.trim() : '';
  }

  void printMessage(String message) => stdout.writeln(message);

  void printWarning(Object warning) => stderr.writeln('$yellow$warning$reset');

  void printError(Object error) => stderr.writeln('$red$error$reset');

  void exception(Exception exception) {
    if (exception is GenericWarning) {
      printWarning(exception);
    } else {
      printError(exception);
    }
  }

  void generic(Object error) => printError(error);
}
