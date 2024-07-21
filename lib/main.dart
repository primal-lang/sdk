import 'dart:io';
import 'package:dry/compiler/compiler.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';

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
      //final Expression expression = Expression.parse(input);
      //intermediateCode.evaluate(expression);
      print('Your input: $input');
      stdout.write('> ');
      input = stdin.readLineSync();
    }
  }
}
