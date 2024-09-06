import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListSwap extends NativeFunctionNode {
  ListSwap()
      : super(
          name: 'list.swap',
          parameters: [
            Parameter.list('a'),
            Parameter.number('b'),
            Parameter.number('c'),
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
    final Node c = arguments[2].evaluate();

    if ((a is ListNode) && (b is NumberNode) && (c is NumberNode)) {
      final List<Node> result = [];
      final Node valueAtB = a.value[b.value.toInt()];
      final Node valueAtC = a.value[c.value.toInt()];

      for (int i = 0; i < a.value.length; i++) {
        final Node element = a.value[i];

        if (i == b.value.toInt()) {
          result.add(valueAtC);
        } else if (i == c.value.toInt()) {
          result.add(valueAtB);
        } else {
          result.add(element);
        }
      }

      return ListNode(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
