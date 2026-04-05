import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class MapContainsKey extends NativeFunctionNode {
  const MapContainsKey()
    : super(
        name: 'map.containsKey',
        parameters: const [
          Parameter.map('a'),
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
  Node reduce() {
    final Node a = arguments[0].reduce();
    final Node b = arguments[1].reduce();

    if ((a is MapNode) && (b is LiteralNode)) {
      final Map<dynamic, Node> map = a.asMapWithKeys();

      return BooleanNode(map.containsKey(b.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
