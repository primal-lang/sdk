import 'package:dry/compiler/compiler.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/utils/console.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dry <file.dry>');
    return;
  }

  final Compiler compiler = Compiler.fromFile(args[0]);
  final IntermediateCode intermediateCode = compiler.compile();
  final Console console = Console();

  if (intermediateCode.hasMain) {
    final String result = intermediateCode.executeMain();
    console.print(result);
  } else {
    while (true) {
      try {
        final String input = console.prompt();

        if (input.isNotEmpty) {
          final Expression expression = compiler.expression(input);
          console.print(intermediateCode.evaluate(expression));
        }
      } catch (e) {
        console.error(e);
      }
    }
  }
}
