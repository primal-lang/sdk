import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class CompGe extends NativeFunctionTerm {
  const CompGe()
    : super(
        name: 'comp.ge',
        parameters: const [
          Parameter.ordered('a'),
          Parameter.ordered('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );

  static Term execute({
    required FunctionTerm function,
    required Term a,
    required Term b,
  }) {
    if ((a is NumberTerm) && (b is NumberTerm)) {
      return BooleanTerm(a.value >= b.value);
    } else if ((a is StringTerm) && (b is StringTerm)) {
      return BooleanTerm(a.value.compareTo(b.value) >= 0);
    } else if ((a is TimestampTerm) && (b is TimestampTerm)) {
      return BooleanTerm(a.value.compareTo(b.value) >= 0);
    } else if ((a is DurationTerm) && (b is DurationTerm)) {
      return BooleanTerm(a.value.compareTo(b.value) >= 0);
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

    return CompGe.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
