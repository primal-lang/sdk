import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class DurationFormat extends NativeFunctionTerm {
  const DurationFormat()
    : super(
        name: 'duration.format',
        parameters: const [
          Parameter.duration('duration'),
          Parameter.string('pattern'),
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

    if ((a is DurationTerm) && (b is StringTerm)) {
      final Duration duration = a.value;
      final String pattern = b.value;

      // Extract component values
      final int days = duration.inDays;
      final int hours = duration.inHours.remainder(24);
      final int minutes = duration.inMinutes.remainder(60);
      final int seconds = duration.inSeconds.remainder(60);
      final int milliseconds = duration.inMilliseconds.remainder(1000);

      // Replace patterns (order matters - longer patterns first)
      String result = pattern;

      // Days
      result = result.replaceAll('dd', days.toString().padLeft(2, '0'));
      result = result.replaceAll('d', days.toString());

      // Hours
      result = result.replaceAll('HH', hours.toString().padLeft(2, '0'));
      result = result.replaceAll('H', hours.toString());

      // Minutes
      result = result.replaceAll('mm', minutes.toString().padLeft(2, '0'));
      result = result.replaceAll('m', minutes.toString());

      // Seconds
      result = result.replaceAll('ss', seconds.toString().padLeft(2, '0'));
      result = result.replaceAll('s', seconds.toString());

      // Milliseconds
      result = result.replaceAll(
        'SSS',
        milliseconds.toString().padLeft(3, '0'),
      );
      result = result.replaceAll('S', milliseconds.toString());

      return StringTerm(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
