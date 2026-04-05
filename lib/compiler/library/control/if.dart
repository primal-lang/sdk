import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class If extends NativeFunctionTerm {
  const If()
    : super(
        name: 'if',
        parameters: const [
          Parameter.boolean('a'),
          Parameter.any('b'),
          Parameter.any('c'),
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
    final Term b = arguments[1];
    final Term c = arguments[2];

    if (a is BooleanTerm) {
      if (a.value) {
        return b.reduce();
      } else {
        return c.reduce();
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
