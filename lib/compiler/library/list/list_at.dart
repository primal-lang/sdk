import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListAt extends NativeFunctionNode {
  ListAt()
    : super(
        name: 'list.at',
        parameters: [
          Parameter.list('a'),
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

    if ((a is ListNode) && (b is NumberNode)) {
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
      return a.value[index];
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
