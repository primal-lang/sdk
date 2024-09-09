import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class VectorSub extends NativeFunctionNode {
  VectorSub()
      : super(
          name: 'vector.sub',
          parameters: [
            Parameter.vector('a'),
            Parameter.vector('b'),
          ],
        );

  @override
  Node node(List<Node> arguments) => NodeWithArguments(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );

  static VectorNode execute({
    required FunctionNode function,
    required Node a,
    required Node b,
  }) {
    if ((a is VectorNode) && (b is VectorNode)) {
      if (a.value.length != b.value.length) {
        throw IterablesWithDifferentLengthError(
          iterable1: a.native(),
          iterable2: b.native(),
        );
      }

      final List<Node> value = [];

      for (int i = 0; i < a.value.length; i++) {
        value.add(NumberNode(a.value[i].native() - b.value[i].native()));
      }

      return VectorNode(value);
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type],
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

    return VectorSub.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
