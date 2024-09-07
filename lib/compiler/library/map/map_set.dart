import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class MapSet extends NativeFunctionNode {
  MapSet()
      : super(
          name: 'map.set',
          parameters: [
            Parameter.map('a'),
            Parameter.any('b'),
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
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();
    final Node c = arguments[2];

    if ((a is MapNode) && (b is LiteralNode)) {
      final Map<dynamic, Node> map = a.evaluateKeys();
      map[b.value] = c;

      final Map<Node, Node> newMap = {};
      map.forEach((key, value) {
        newMap[LiteralNode.from(key)] = value;
      });

      return MapNode(newMap);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
