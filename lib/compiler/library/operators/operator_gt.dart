import 'package:primal/compiler/library/comparison/comp_gt.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class OperatorGt extends NativeFunctionTerm {
  const OperatorGt()
    : super(
        name: '>',
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

    return CompGt.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
