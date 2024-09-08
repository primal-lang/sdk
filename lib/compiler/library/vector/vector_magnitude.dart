import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class VectorMagnitude extends NativeFunctionNode {
  VectorMagnitude()
      : super(
          name: 'vector.magnitude',
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

  static NumberNode execute({
    required FunctionNode function,
    required Node a,
  }) {
    if (a is VectorNode) {
      double magnitude = 0;
      final List list = a.native();

      for (final dynamic element in list) {
        magnitude += element * element;
      }

      return NumberNode(sqrt(magnitude));
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

    return VectorMagnitude.execute(
      function: this,
      a: a,
    );
  }
}
