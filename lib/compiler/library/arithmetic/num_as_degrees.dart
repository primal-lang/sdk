import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class NumAsDegrees extends NativeFunctionPrototype {
  NumAsDegrees()
      : super(
          name: 'num.asDegrees',
          parameters: [
            Parameter.number('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();

    if (a is NumberNode) {
      return NumberNode(a.value * (180.0 / pi));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
