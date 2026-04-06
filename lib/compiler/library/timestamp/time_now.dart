import 'package:primal/compiler/runtime/term.dart';

class TimeNow extends NativeFunctionTerm {
  const TimeNow()
    : super(
        name: 'time.now',
        parameters: const [],
      );

  @override
  Term term(List<Term> arguments) => TimestampTerm(DateTime.now());
}
