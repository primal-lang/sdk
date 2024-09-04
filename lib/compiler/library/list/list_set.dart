import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListSet extends NativeFunctionNode {
  ListSet()
      : super(
          name: 'list.set',
          parameters: [
            Parameter.list('a'),
            Parameter.number('b'),
            Parameter.any('c'),
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
    final Node a = arguments[0];
    final Node b = arguments[1].evaluate();
    final Node c = arguments[2];

    if ((a is ListNode) && (b is NumberNode)) {
      final List<Node> head = a.value.sublist(0, b.value.toInt());
      final List<Node> tail = a.value.sublist(b.value.toInt(), a.value.length);

      return ListNode([...head, c, ...tail]);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
