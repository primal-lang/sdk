import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class Try extends NativeFunctionNode {
  Try()
      : super(
          name: 'try',
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
    final Node a = arguments[0];
    final Node b = arguments[1];

    try {
      return a.evaluate();
    } catch (e) {
      return b;
    }
  }
}
