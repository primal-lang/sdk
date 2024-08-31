import 'dart:io';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ConsoleWriteLn extends NativeFunctionPrototype {
  ConsoleWriteLn()
      : super(
          name: 'console.writeLn',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();
    stdout.writeln(a.toString());
    stdout.flush();

    return a;
  }
}
