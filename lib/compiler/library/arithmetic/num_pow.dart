import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class NumPow extends NativeFunctionNode {
  const NumPow()
    : super(
        name: 'num.pow',
        parameters: const [
          Parameter.number('a'),
          Parameter.number('b'),
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
    final Node b = arguments[1].evaluate();

    if ((a is NumberNode) && (b is NumberNode)) {
      if (a.value < 0 && b.value != b.value.truncate()) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'cannot raise negative number to fractional power',
        );
      }
      final num result = pow(a.value, b.value);
      if (result.isNaN || result.isInfinite) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'result is not a finite number',
        );
      }
      return NumberNode(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
