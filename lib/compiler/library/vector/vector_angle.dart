import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/vector/vector_magnitude.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class VectorAngle extends NativeFunctionTerm {
  const VectorAngle()
    : super(
        name: 'vector.angle',
        parameters: const [
          Parameter.vector('a'),
          Parameter.vector('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class TermWithArguments extends NativeFunctionTermWithArguments {
  const TermWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();
    final Term b = arguments[1].reduce();

    if ((a is VectorTerm) && (b is VectorTerm)) {
      final List<num> valuesA = a.native().cast<num>();
      final List<num> valuesB = b.native().cast<num>();

      if (valuesA.length != valuesB.length) {
        throw IterablesWithDifferentLengthError(
          iterable1: valuesA,
          iterable2: valuesB,
        );
      }

      if (valuesA.isEmpty || valuesB.isEmpty) {
        throw const RuntimeError('Cannot calculate angle of empty vectors');
      }

      num dotProduct = 0;

      for (int index = 0; index < valuesA.length; index++) {
        dotProduct += valuesA[index] * valuesB[index];
      }

      final double magnitudeA = VectorMagnitude.computeMagnitude(valuesA);
      final double magnitudeB = VectorMagnitude.computeMagnitude(valuesB);

      if (magnitudeA == 0 || magnitudeB == 0) {
        throw DivisionByZeroError(function: name);
      }

      final num cosine = dotProduct / (magnitudeA * magnitudeB);
      final num clampedCosine = cosine.clamp(-1.0, 1.0);

      return NumberTerm(acos(clampedCosine));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
