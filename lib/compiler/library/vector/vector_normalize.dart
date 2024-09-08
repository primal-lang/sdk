import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/vector/vector_magnitude.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class VectorNormalize extends NativeFunctionNode {
  VectorNormalize()
      : super(
          name: 'vector.normalize',
          parameters: [
            Parameter.vector('a'),
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

    if (a is VectorNode) {
      final NumberNode magnitude = VectorMagnitude.execute(
        function: this,
        a: a,
      );
      final List list = a.native();

      return VectorNode(list
          .map((element) => NumberNode(element / magnitude.value))
          .toList());
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
