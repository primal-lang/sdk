import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class NumAsRadians extends NativeFunctionNode {
  NumAsRadians()
      : super(
          name: 'num.asRadians',
          parameters: [
            Parameter.number('a'),
          ],
        );

  @override
  Node node(List<Node> arguments) => NumAsRadiansNode(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class NumAsRadiansNode extends NativeFunctionNodeWithArguments {
  const NumAsRadiansNode({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();

    if (a is NumberNode) {
      return NumberNode(a.value * (pi / 180));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
