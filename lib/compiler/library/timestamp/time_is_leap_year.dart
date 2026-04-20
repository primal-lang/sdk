import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class TimeIsLeapYear extends NativeFunctionTerm {
  const TimeIsLeapYear()
    : super(
        name: 'time.isLeapYear',
        parameters: const [
          Parameter.number('a'),
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

    if (a is NumberTerm) {
      final int year = a.value.toInt();
      final bool isLeapYear =
          (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

      return BooleanTerm(isLeapYear);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
