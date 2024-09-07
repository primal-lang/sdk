import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListSort extends NativeFunctionNode {
  ListSort()
      : super(
          name: 'list.sort',
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
    final Node b = arguments[1].evaluate();

    if ((a is ListNode) && (b is FunctionNode)) {
      final List<Node> result = List<Node>.from(a.value);

      result.sort((x, y) {
        final Node value = b.apply([x, y]);

        if (value is NumberNode) {
          return value.value as int;
        } else {
          return 0;
        }
      });

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
