import 'dart:math';
import 'package:primal/compiler/runtime/term.dart';

class NumDecimalRandom extends NativeFunctionTerm {
  const NumDecimalRandom()
    : super(
        name: 'num.decimalRandom',
        parameters: const [],
      );

  @override
  Term term(List<Term> arguments) => NumberTerm(Random().nextDouble());
}
