import 'package:primal/compiler/library/comparison/comp_neq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class OperatorNeq extends NativeFunctionTerm {
  const OperatorNeq()
    : super(
        name: '!=',
        parameters: const [
          Parameter.equatable('a'),
          Parameter.equatable('b'),
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

    return CompNeq.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
