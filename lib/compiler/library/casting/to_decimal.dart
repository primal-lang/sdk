import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class ToDecimal extends NativeFunctionTerm {
  const ToDecimal()
    : super(
        name: 'to.decimal',
        parameters: const [
          Parameter.any('a'),
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

    if (a is StringTerm) {
      try {
        return NumberTerm(double.parse(a.value));
      } on FormatException {
        throw ParseError(function: name, input: a.value, targetType: 'decimal');
      }
    } else if (a is NumberTerm) {
      return NumberTerm(a.value.toDouble());
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
