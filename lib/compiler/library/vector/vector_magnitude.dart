import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class VectorMagnitude extends NativeFunctionTerm {
  const VectorMagnitude()
    : super(
        name: 'vector.magnitude',
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

  static NumberTerm execute({
    required FunctionTerm function,
    required Term a,
  }) {
    if (a is VectorTerm) {
      double magnitude = 0;
      final List list = a.native();

      for (final dynamic element in list) {
        magnitude += element * element;
      }

      return NumberTerm(sqrt(magnitude));
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type],
      );
    }
  }
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

    return VectorMagnitude.execute(
      function: this,
      a: a,
    );
  }
}
