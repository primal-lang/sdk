import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListRemoveAt extends NativeFunctionNode {
  const ListRemoveAt()
    : super(
        name: 'list.removeAt',
        parameters: const [
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
  Node reduce() {
    final Node a = arguments[0].reduce();
    final Node b = arguments[1].reduce();

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
      return ListNode(
        a.value.sublist(0, index) + a.value.sublist(index + 1),
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
