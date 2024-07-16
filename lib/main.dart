import 'dart:io';
import 'package:dry/compiler/compiler.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';

void main(List<String> args) {
  final Compiler compiler = Compiler.fromFile(args[0]);
  final IntermediateCode intermediateCode = compiler.compile();

  if (intermediateCode.hasMain) {
    intermediateCode.executeMain();
  } else {
    String? input = stdin.readLineSync();

    while (input != null) {
      print('Evaluating: $input');
      //final Expression expression = Expression.parse(input);
      //intermediateCode.evaluate(expression);
      input = stdin.readLineSync();
    }
  }
}
