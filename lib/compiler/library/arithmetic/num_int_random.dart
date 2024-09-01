import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class NumIntegerRandom extends NativeFunctionPrototype {
  NumIntegerRandom()
      : super(
          name: 'num.integerRandom',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();
    final Node b = arguments.get('b').evaluate();

    if ((a is NumberNode) && (b is NumberNode)) {
      return NumberNode(
        a.value + Random().nextInt((b.value - a.value + 1).toInt()),
      );
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
