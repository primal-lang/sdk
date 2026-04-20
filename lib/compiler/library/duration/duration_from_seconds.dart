import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class DurationFromSeconds extends NativeFunctionTerm {
  const DurationFromSeconds()
    : super(
        name: 'duration.fromSeconds',
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
      final num seconds = a.value;
      if (seconds < 0) {
        throw NegativeDurationError(function: name);
      }
      final int microseconds = (seconds * 1000000).round();
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
