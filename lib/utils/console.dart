import 'dart:io';

class Console {
  String prompt() {
    stdout.write('> ');
    final String? input = stdin.readLineSync();

    return input != null ? input.trim() : '';
  }

  void print(String message) => stdout.writeln(message);

  void error(Object message) => stderr.writeln('Error: $message');
}
