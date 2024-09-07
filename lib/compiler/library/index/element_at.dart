import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ElementAt extends NativeFunctionNode {
  ElementAt()
      : super(
          name: 'element.at',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
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
      return a.value[b.value.toInt()];
    } else if ((a is MapNode) && (b is LiteralNode)) {
      final Map<dynamic, Node> map = a.asMapWithKeys();
      final Node? node = map[b.value];

      if (node != null) {
        return node;
      } else {
        throw ElementNotFoundError(b.value.toString());
      }
    } else if ((a is StringNode) && (b is NumberNode)) {
      return StringNode(a.value[b.value.toInt()]);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
