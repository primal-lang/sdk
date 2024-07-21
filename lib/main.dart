import 'dart:io';
import 'package:dry/compiler/compiler.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/expression.dart';

void main(List<String> args) {
  final Compiler compiler = Compiler.fromFile(args[0]);
  final IntermediateCode intermediateCode = compiler.compile();

  if (intermediateCode.hasMain) {
    final String result = intermediateCode.executeMain();
    print(result);
  } else {
    stdout.write('> ');
    String? input = stdin.readLineSync();

    while (input != null) {
      try {
        final Expression expression = compiler.expression(input);
        print(intermediateCode.evaluate(expression));
      } catch (e) {
        print(e);
      }

      stdout.write('> ');
      input = stdin.readLineSync();
    }
  }
}
