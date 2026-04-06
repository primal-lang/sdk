import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class TimeFromIso extends NativeFunctionTerm {
  const TimeFromIso()
    : super(
        name: 'time.fromIso',
        parameters: const [
          Parameter.string('a'),
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
        return TimestampTerm(DateTime.parse(a.value));
      } on FormatException {
        throw ParseError(
          function: name,
          input: a.value,
          targetType: 'timestamp',
        );
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
