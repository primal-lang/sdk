import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class VectorScale extends NativeFunctionTerm {
  const VectorScale()
    : super(
        name: 'vector.scale',
        parameters: const [
          Parameter.vector('a'),
          Parameter.number('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );

  static VectorTerm execute({
    required FunctionTerm function,
    required Term a,
    required Term b,
  }) {
    if ((a is VectorTerm) && (b is NumberTerm)) {
      final num scalar = b.native();
      final List<Term> scaledValues = [];

      for (final Term element in a.value) {
        scaledValues.add(NumberTerm(element.native() * scalar));
      }

      return VectorTerm(scaledValues);
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type, b.type],
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
    final Term b = arguments[1].reduce();

    return VectorScale.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
