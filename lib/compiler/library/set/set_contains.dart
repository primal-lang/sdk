import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class SetContains extends NativeFunctionNode {
  SetContains()
      : super(
          name: 'set.contains',
          parameters: [
            Parameter.set('a'),
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

    if (a is SetNode) {
      for (final Node node in a.value) {
        final BooleanNode comparison = CompEq.execute(
          function: this,
          a: node.evaluate(),
          b: b,
        );

        if (comparison.value) {
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
