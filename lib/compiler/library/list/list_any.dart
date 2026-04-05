import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListAny extends NativeFunctionNode {
  const ListAny()
    : super(
        name: 'list.any',
        parameters: const [
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
    final Node b = arguments[1].evaluate();

    if ((a is ListNode) && (b is FunctionNode)) {
      for (final Node element in a.value) {
        final Node value = b.apply([element]);

        if (value is! BooleanNode) {
          throw InvalidArgumentTypesError(
            function: name,
            expected: [const BooleanType()],
            actual: [value.type],
          );
        }

        if (value.value) {
          return const BooleanNode(true);
        }
      }

      return const BooleanNode(false);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
