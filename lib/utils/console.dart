import 'dart:io';

class Console {
  String? prompt() {
    stdout.write('> ');

    return stdin.readLineSync();
  }

  void print(String message) => stdout.writeln(message);

  void error(Object message) => stderr.writeln('Error: $message');
}
