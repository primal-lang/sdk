import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class IsInfinite extends NativeFunctionTerm {
  const IsInfinite()
    : super(
        name: 'is.infinite',
        parameters: const [
          Parameter.any('a'),
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
      return BooleanTerm(a.value.isInfinite);
    } else {
      return const BooleanTerm(false);
    }
  }
}
