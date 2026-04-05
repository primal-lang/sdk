import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

final Random _random = Random();

class NumIntegerRandom extends NativeFunctionNode {
  const NumIntegerRandom()
    : super(
        name: 'num.integerRandom',
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
  Node reduce() {
    final Node a = arguments[0].reduce();
    final Node b = arguments[1].reduce();

    if ((a is NumberNode) && (b is NumberNode)) {
      final int min = a.value.toInt();
      final int max = b.value.toInt();
      if (max < min) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'max ($max) must be >= min ($min)',
        );
      }
      final int range = max - min + 1;
      if (range <= 0) {
        throw InvalidNumericOperationError(
          function: name,
          reason: 'range overflow',
        );
      }
      return NumberNode(min + _random.nextInt(range));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
