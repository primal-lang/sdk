import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class DurationFrom extends NativeFunctionTerm {
  const DurationFrom()
    : super(
        name: 'duration.from',
        parameters: const [
          Parameter.number('a'),
          Parameter.number('b'),
          Parameter.number('c'),
          Parameter.number('d'),
          Parameter.number('e'),
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
    final Term b = arguments[1].reduce();
    final Term c = arguments[2].reduce();
    final Term d = arguments[3].reduce();
    final Term e = arguments[4].reduce();

    if (a is! NumberTerm ||
        b is! NumberTerm ||
        c is! NumberTerm ||
        d is! NumberTerm ||
        e is! NumberTerm) {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [
          a.type,
          b.type,
          c.type,
          d.type,
          e.type,
        ],
      );
    }

    final num days = a.value;
    final num hours = b.value;
    final num minutes = c.value;
    final num seconds = d.value;
    final num milliseconds = e.value;

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
