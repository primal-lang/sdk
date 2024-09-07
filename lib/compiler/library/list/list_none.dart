import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListNone extends NativeFunctionNode {
  ListNone()
      : super(
          name: 'list.none',
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
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1];

    if ((a is ListNode) && (b is FreeVariableNode)) {
      final FunctionNode function = b.evaluate();

      for (final Node element in a.value) {
        final Node value = function.apply([element]);

        if (value is BooleanNode && value.value) {
          return const BooleanNode(false);
        }
      }

      return const BooleanNode(true);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
