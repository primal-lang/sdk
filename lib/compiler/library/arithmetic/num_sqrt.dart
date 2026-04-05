import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class NumSqrt extends NativeFunctionNode {
  const NumSqrt()
    : super(
        name: 'num.sqrt',
        parameters: const [
          Parameter.number('a'),
        ],
      );

  @override
  Node node(List<Node> arguments) => NodeWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class NodeWithArguments extends NativeFunctionNodeWithArguments {
  const NodeWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();

    if (a is NumberNode) {
      if (a.value < 0) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'cannot compute square root of negative number ${a.value}',
        );
      }
      final num value = sqrt(a.value);
      final num result = (value == value.toInt()) ? value.toInt() : value;
      return NumberNode(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
