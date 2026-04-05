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
