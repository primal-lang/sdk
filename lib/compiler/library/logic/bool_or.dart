import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class BoolOr extends NativeFunctionTerm {
  const BoolOr()
    : super(
        name: 'bool.or',
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
    final Term a = arguments[0].reduce();

    if (a is BooleanTerm) {
      if (a.value) {
        return const BooleanTerm(true);
      } else {
        final Term b = arguments[1].reduce();

        if (b is BooleanTerm) {
          return b;
        } else {
          throw InvalidArgumentTypesError(
            function: function.name,
            expected: function.parameterTypes,
            actual: [a.type, b.type],
          );
        }
      }
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
  Term reduce() => BoolOr.execute(
    function: this,
    arguments: arguments,
  );
}
