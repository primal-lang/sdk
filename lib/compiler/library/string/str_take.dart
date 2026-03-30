import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class StrTake extends NativeFunctionNode {
  StrTake()
    : super(
        name: 'str.take',
        parameters: [
          Parameter.string('a'),
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

    if ((a is StringNode) && (b is NumberNode)) {
      final int count = b.value.toInt();
      if (count < 0) {
        throw NegativeIndexError(function: name, index: count);
      }
      if (count > a.value.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: count,
          length: a.value.length,
        );
      }
      return StringNode(a.value.substring(0, count));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
