import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/vector/vector_magnitude.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class VectorNormalize extends NativeFunctionNode {
  const VectorNormalize()
    : super(
        name: 'vector.normalize',
        parameters: const [
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
  Node reduce() {
    final Node a = arguments[0].reduce();

    if (a is VectorNode) {
      final List<num> list = a.native().cast<num>();

      if (list.isEmpty) {
        return a;
      }

      final NumberNode magnitude = VectorMagnitude.execute(
        function: this,
        a: a,
      );

      if (magnitude.value == 0) {
        throw DivisionByZeroError(function: name);
      }

      return VectorNode(
        list
            .map((num element) => NumberNode(element / magnitude.value))
            .toList(),
      );
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
