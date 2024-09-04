import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart' as eq;
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class ListIndexOf extends NativeFunctionNode {
  ListIndexOf()
      : super(
          name: 'list.indexOf',
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

      for (int i = 0; i < a.value.length; i++) {
        final Node comparison = comparator.compare(a.value[i].evaluate(), b);

        if (comparison is BooleanNode && comparison.value) {
          return NumberNode(i);
        }
      }

      return const NumberNode(-1);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
