import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ToList extends NativeFunctionNode {
  ToList()
      : super(
          name: 'to.list',
          parameters: [
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
  Node evaluate() {
    final Node a = arguments[0].evaluate();

    if (a is SetNode) {
      return ListNode(a.value.toList());
    } else if (a is VectorNode) {
      return ListNode(a.value);
    } else if (a is StackNode) {
      return ListNode(a.value);
    } else if (a is QueueNode) {
      return ListNode(a.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
