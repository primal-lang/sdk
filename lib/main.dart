import 'dart:io';
import 'package:dry/compiler/compiler.dart';
import 'package:dry/models/bytecode.dart';
import 'package:dry/models/expression.dart';

void main(List<String> args) {
  final Compiler compiler = Compiler.fromFile(args[0]);
  final ByteCode bytecode = compiler.compile();

  if (bytecode.hasMain) {
    bytecode.executeMain();
  } else {
    String? input = stdin.readLineSync();

    while (input != null) {
      print('Evaluating: $input');
      final Expression expression = Expression.parse(input);
      bytecode.evaluate(expression);
      input = stdin.readLineSync();
    }
  }
}
