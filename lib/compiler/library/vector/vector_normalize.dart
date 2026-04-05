import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/vector/vector_magnitude.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class VectorNormalize extends NativeFunctionTerm {
  const VectorNormalize()
    : super(
        name: 'vector.normalize',
        parameters: const [
          Parameter.vector('a'),
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

    if (a is VectorTerm) {
      final List<num> values = a.native().cast<num>();

      if (values.isEmpty) {
        return a;
      }

      final double magnitude = VectorMagnitude.computeMagnitude(values);

      if (magnitude == 0) {
        throw DivisionByZeroError(function: name);
      }

      return VectorTerm(
        values.map((num element) => NumberTerm(element / magnitude)).toList(),
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
