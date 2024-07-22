import 'dart:io';

class Console {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';

  String prompt() {
    stdout.write('> ');
    final String? input = stdin.readLineSync();

    return input != null ? input.trim() : '';
  }

  void print(String message) => stdout.writeln(message);

  void error(Object message) => stderr.writeln('${red}Error: $message$reset');
}
