import 'dart:io';

class Compiler {
  final String source;

  const Compiler._(this.source);

  void compile() {
    print(source);
  }

  factory Compiler.fromFile(String filePath) {
    final File file = File(filePath);
    final String content = file.readAsStringSync();

    return Compiler._(content);
  }

  factory Compiler.fromContent(String content) => Compiler._(content);
}
