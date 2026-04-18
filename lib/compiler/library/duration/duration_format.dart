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

      // Replace patterns using regex to avoid matching within words
      // Order matters - longer patterns first
      String result = pattern;

      // Days - use regex to match 'dd' or 'd' not surrounded by letters
      result = result.replaceAllMapped(
        RegExp(r'(?<![a-zA-Z])dd(?![a-zA-Z])'),
        (match) => days.toString().padLeft(2, '0'),
      );
      result = result.replaceAllMapped(
        RegExp(r'(?<![a-zA-Z])d(?![a-zA-Z])'),
        (match) => days.toString(),
      );

      // Hours
      result = result.replaceAllMapped(
        RegExp(r'(?<![a-zA-Z])HH(?![a-zA-Z])'),
        (match) => hours.toString().padLeft(2, '0'),
      );
      result = result.replaceAllMapped(
        RegExp(r'(?<![a-zA-Z])H(?![a-zA-Z])'),
        (match) => hours.toString(),
      );

      // Minutes
      result = result.replaceAllMapped(
        RegExp(r'(?<![a-zA-Z])mm(?![a-zA-Z])'),
        (match) => minutes.toString().padLeft(2, '0'),
      );
      result = result.replaceAllMapped(
        RegExp(r'(?<![a-zA-Z])m(?![a-zA-Z])'),
        (match) => minutes.toString(),
      );

      // Seconds
      result = result.replaceAllMapped(
        RegExp(r'(?<![a-zA-Z])ss(?![a-zA-Z])'),
        (match) => seconds.toString().padLeft(2, '0'),
      );
      result = result.replaceAllMapped(
        RegExp(r'(?<![a-zA-Z])s(?![a-zA-Z])'),
        (match) => seconds.toString(),
      );

      // Milliseconds
      result = result.replaceAllMapped(
        RegExp(r'(?<![a-zA-Z])SSS(?![a-zA-Z])'),
        (match) => milliseconds.toString().padLeft(3, '0'),
      );
      result = result.replaceAllMapped(
        RegExp(r'(?<![a-zA-Z])S(?![a-zA-Z])'),
        (match) => milliseconds.toString(),
      );

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
