import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart' as eq;
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListRemove extends NativeFunctionNode {
  ListRemove()
      : super(
          name: 'list.remove',
          parameters: [
            Parameter.list('a'),
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
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    if (a is ListNode) {
      final eq.NodeWithArguments comparator = eq.NodeWithArguments(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
      final List<Node> result = [];

      for (final Node element in a.value) {
        final Node elementReduced = element.evaluate();
        final Node comparison = comparator.compare(elementReduced, b);

        if (comparison is BooleanNode && !comparison.value) {
          result.add(elementReduced);
        }
      }

      return ListNode(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
