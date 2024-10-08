import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class SetUnion extends NativeFunctionNode {
  SetUnion()
      : super(
          name: 'set.union',
          parameters: [
            Parameter.set('a'),
            Parameter.set('b'),
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
    if ((a is SetNode) && (b is SetNode)) {
      final Set<Node> set = {...a.value};

      for (final Node node in b.value) {
        if (!set.contains(node.native())) {
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

    return SetUnion.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
