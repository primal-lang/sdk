import 'dart:io';
import 'package:dry/models/bytecode.dart';

class Compiler {
  final String source;

  const Compiler._(this.source);

  ByteCode compile() {
    return ByteCode();
  }

  factory Compiler.fromFile(String filePath) {
    final File file = File(filePath);
    final String content = file.readAsStringSync();

    return Compiler._(content);
  }
}
