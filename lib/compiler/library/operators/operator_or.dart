import 'package:primal/compiler/library/logic/bool_or_strict.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class OperatorOr extends NativeFunctionTerm {
  const OperatorOr()
    : super(
        name: '|',
        parameters: const [
          Parameter.boolean('a'),
          Parameter.boolean('b'),
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
  Term reduce() => BoolOrStrict.execute(
    function: this,
    arguments: arguments,
  );
}
