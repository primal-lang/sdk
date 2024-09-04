import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart' as eq;
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListContains extends NativeFunctionNode {
  ListContains()
      : super(
          name: 'list.contains',
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

      for (final Node element in a.value) {
        final Node comparison = comparator.compare(element.evaluate(), b);

        if (comparison is BooleanNode && comparison.value) {
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
