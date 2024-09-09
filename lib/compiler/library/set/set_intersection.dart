import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class SetIntersection extends NativeFunctionNode {
  SetIntersection()
      : super(
          name: 'set.intersection',
          parameters: [
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
      final Set<dynamic> setA = a.native();
      final Set<Node> set = {};

      for (final Node node in b.value) {
        if (setA.contains(node.native())) {
          set.add(node);
        }
      }

      return SetNode(set);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
