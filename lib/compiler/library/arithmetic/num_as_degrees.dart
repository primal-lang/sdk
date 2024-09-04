import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class NumAsDegrees extends NativeFunctionNode {
  NumAsDegrees()
      : super(
          name: 'num.asDegrees',
          parameters: [
            Parameter.number('a'),
          ],
        );

  @override
  Node body(List<Node> arguments) => NumAsDegreesNode(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class NumAsDegreesNode extends NativeFunctionNodeWithArguments {
  const NumAsDegreesNode({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();

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
