import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class DurationFrom extends NativeFunctionTerm {
  const DurationFrom()
    : super(
        name: 'duration.from',
        parameters: const [
          Parameter.number('days'),
          Parameter.number('hours'),
          Parameter.number('minutes'),
          Parameter.number('seconds'),
          Parameter.number('milliseconds'),
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
    final Term daysArg = arguments[0].reduce();
    final Term hoursArg = arguments[1].reduce();
    final Term minutesArg = arguments[2].reduce();
    final Term secondsArg = arguments[3].reduce();
    final Term millisecondsArg = arguments[4].reduce();

    if (daysArg is! NumberTerm ||
        hoursArg is! NumberTerm ||
        minutesArg is! NumberTerm ||
        secondsArg is! NumberTerm ||
        millisecondsArg is! NumberTerm) {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [
          daysArg.type,
          hoursArg.type,
          minutesArg.type,
          secondsArg.type,
          millisecondsArg.type,
        ],
      );
    }

    final num days = daysArg.value;
    final num hours = hoursArg.value;
    final num minutes = minutesArg.value;
    final num seconds = secondsArg.value;
    final num milliseconds = millisecondsArg.value;

    // Validate left-to-right; throw at first negative
    if (days < 0) {
      throw NegativeDurationError(
        function: name,
        component: 'days',
        value: days,
      );
    }
    if (hours < 0) {
      throw NegativeDurationError(
        function: name,
        component: 'hours',
        value: hours,
      );
    }
    if (minutes < 0) {
      throw NegativeDurationError(
        function: name,
        component: 'minutes',
        value: minutes,
      );
    }
    if (seconds < 0) {
      throw NegativeDurationError(
        function: name,
        component: 'seconds',
        value: seconds,
      );
    }
    if (milliseconds < 0) {
      throw NegativeDurationError(
        function: name,
        component: 'milliseconds',
        value: milliseconds,
      );
    }

    // Convert all to microseconds
    final int totalMicroseconds =
        (days * 24 * 60 * 60 * 1000000).round() +
        (hours * 60 * 60 * 1000000).round() +
        (minutes * 60 * 1000000).round() +
        (seconds * 1000000).round() +
        (milliseconds * 1000).round();

    return DurationTerm(Duration(microseconds: totalMicroseconds));
  }
}
