import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class SetRemove extends NativeFunctionNode {
  SetRemove()
      : super(
          name: 'set.remove',
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

  static SetNode execute({
    required FunctionNode function,
    required Node a,
    required Node b,
  }) {
    if (a is SetNode) {
      final Set<Node> set = {};

      for (final Node node in a.value) {
        final BooleanNode comparison = CompEq.execute(
          function: function,
          a: node.evaluate(),
          b: b,
        );

        if (!comparison.value) {
          set.add(node);
        }
      }

      return SetNode(set);
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
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

    return SetRemove.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
