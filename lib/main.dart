import 'dart:io';

import 'package:dry/compiler/compiler.dart';
import 'package:dry/compiler/semantic/intermediate_code.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/utils/console.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dry <file.dry>');
    exit(exitCode);
  }

  final Console console = Console();

  try {
    final Compiler compiler = Compiler.fromFile(args[0]);
    final IntermediateCode intermediateCode = compiler.compile();

    if (intermediateCode.hasMain) {
      final String result = intermediateCode.executeMain();
      console.printMessage(result);
    } else {
      while (true) {
        try {
          final String input = console.prompt();

          if (input.isNotEmpty) {
            final Expression expression = compiler.expression(input);
            console.printMessage(intermediateCode.evaluate(expression));
          }
        } on Exception catch (e) {
          console.exception(e);
        } catch (e) {
          console.generic(e);
        }
      }
    }
  } on Exception catch (e) {
    console.exception(e);
  } catch (e) {
    console.generic(e);
  }
}
