import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class BoolAndStrict extends NativeFunctionTerm {
  const BoolAndStrict()
    : super(
        name: 'bool.andStrict',
        parameters: const [
          Parameter.boolean('a'),
          Parameter.boolean('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );

  static BooleanTerm execute({
    required FunctionTerm function,
    required List<Term> arguments,
  }) {
    // Strict evaluation: evaluate both operands unconditionally
    final Term a = arguments[0].reduce();
    final Term b = arguments[1].reduce();

    if (a is BooleanTerm && b is BooleanTerm) {
      return BooleanTerm(a.value && b.value);
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
  Term reduce() => BoolAndStrict.execute(
    function: this,
    arguments: arguments,
  );
}
