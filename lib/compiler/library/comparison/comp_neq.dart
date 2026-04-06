import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class CompNeq extends NativeFunctionTerm {
  const CompNeq()
    : super(
        name: 'comp.neq',
        parameters: const [
          Parameter.any('a'),
          Parameter.any('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );

  static Term execute({
    required FunctionTerm function,
    required Term a,
    required Term b,
  }) {
    final BooleanTerm comparison = CompEq.execute(
      function: function,
      a: a,
      b: b,
    );

    return BooleanTerm(!comparison.value);
  }
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
