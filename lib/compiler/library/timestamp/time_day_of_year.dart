import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class TimeDayOfYear extends NativeFunctionTerm {
  const TimeDayOfYear()
    : super(
        name: 'time.dayOfYear',
        parameters: const [
          Parameter.timestamp('a'),
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

    if (a is TimestampTerm) {
      final DateTime date = a.value;
      final DateTime startOfYear = DateTime.utc(date.year, 1, 1);
      final int dayOfYear = date.difference(startOfYear).inDays + 1;

      return NumberTerm(dayOfYear);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
