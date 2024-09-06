import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListMap extends NativeFunctionNode {
  ListMap()
      : super(
          name: 'list.map',
          parameters: [
            Parameter.list('a'),
            Parameter.function('b'),
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

    if ((a is FreeVariableNode) && (b is ListNode)) {
      final FunctionNode function = a.functionNode();
      final List<Node> result = [];

      for (final Node element in b.value) {
        final Node value = function.apply([element]);
        result.add(value);
      }

      return ListNode(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
