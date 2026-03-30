import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class StrAt extends NativeFunctionNode {
  StrAt()
    : super(
        name: 'str.at',
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
      final int index = b.value.toInt();
      if (index < 0) {
        throw NegativeIndexError(function: name, index: index);
      }
      if (index >= a.value.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: index,
          length: a.value.length,
        );
      }
      return StringNode(a.value[index]);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
