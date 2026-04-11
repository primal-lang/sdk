import 'package:primal/compiler/library/comparison/comp_le.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class OperatorLe extends NativeFunctionTerm {
  const OperatorLe()
    : super(
        name: '<=',
        parameters: const [
          Parameter.ordered('a'),
          Parameter.ordered('b'),
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

    return CompLe.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
