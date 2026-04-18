import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class DurationFromMinutes extends NativeFunctionTerm {
  const DurationFromMinutes()
    : super(
        name: 'duration.fromMinutes',
        parameters: const [
          Parameter.number('minutes'),
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
      final num minutes = a.value;
      if (minutes < 0) {
        throw NegativeDurationError(function: name);
      }
      final int microseconds = (minutes * 60 * 1000000).round();
      return DurationTerm(Duration(microseconds: microseconds));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
