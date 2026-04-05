import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ToDecimal extends NativeFunctionNode {
  const ToDecimal()
    : super(
        name: 'to.decimal',
        parameters: const [
          Parameter.any('a'),
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

    if (a is StringNode) {
      try {
        return NumberNode(double.parse(a.value));
      } on FormatException {
        throw ParseError(function: name, input: a.value, targetType: 'decimal');
      }
    } else if (a is NumberNode) {
      return NumberNode(a.value.toDouble());
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
