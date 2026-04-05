import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class SetDifference extends NativeFunctionNode {
  const SetDifference()
    : super(
        name: 'set.difference',
        parameters: const [
          Parameter.set('a'),
          Parameter.set('b'),
        ],
      );

  @override
  Node node(List<Node> arguments) => NodeWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );

  static SetNode execute({
    required FunctionNode function,
    required SetNode a,
    required SetNode b,
  }) {
    final Set<dynamic> setB = b.native();
    final Set<Node> result = {};

    for (final Node node in a.value) {
      if (!setB.contains(node.native())) {
        result.add(node);
      }
    }

    return SetNode(result);
  }
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

    if ((a is SetNode) && (b is SetNode)) {
      return SetDifference.execute(
        function: this,
        a: a,
        b: b,
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
