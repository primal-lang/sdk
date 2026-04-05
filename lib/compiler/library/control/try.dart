import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class Try extends NativeFunctionNode {
  const Try()
    : super(
        name: 'try',
        parameters: const [
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
  Node reduce() {
    final Node a = arguments[0];
    final Node b = arguments[1];

    try {
      return a.reduce();
    } catch (_) {
      return b.reduce();
    }
  }
}
