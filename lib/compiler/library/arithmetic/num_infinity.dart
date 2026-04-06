import 'package:primal/compiler/runtime/term.dart';

class NumInfinity extends NativeFunctionTerm {
  const NumInfinity()
    : super(
        name: 'num.infinity',
        parameters: const [],
      );

  @override
  Term term(List<Term> arguments) => const NumberTerm(double.infinity);
}
