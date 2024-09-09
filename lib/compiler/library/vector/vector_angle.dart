import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/vector/vector_magnitude.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class VectorAngle extends NativeFunctionNode {
  VectorAngle()
      : super(
          name: 'vector.angle',
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

    if ((a is VectorNode) && (b is VectorNode)) {
      if (a.value.length != b.value.length) {
        throw IterablesWithDifferentLengthError(
          iterable1: a.native(),
          iterable2: b.native(),
        );
      }

      if ((a.value.isEmpty) || (b.value.isEmpty)) {
        throw const RuntimeError('Cannot calculate angle of empty vectors');
      }

      final List listA = a.native();
      final List listB = b.native();
      num dotProduct = 0;

      for (int i = 0; i < a.value.length; i++) {
        dotProduct += listA[i] * listB[i];
      }

      final num magnitudeA = VectorMagnitude.execute(
        function: this,
        a: a,
      ).native();

      final num magnitudeB = VectorMagnitude.execute(
        function: this,
        a: b,
      ).native();

      final num cosine = dotProduct / (magnitudeA * magnitudeB);

      return NumberNode(acos(cosine));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
