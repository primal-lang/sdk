import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class ToString extends NativeFunctionTerm {
  const ToString()
    : super(
        name: 'to.string',
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

    if (a is StringTerm) {
      return StringTerm(a.value);
    } else {
      return StringTerm(a.toString());
    }
  }
}
