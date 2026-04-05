import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class SetContains extends NativeFunctionTerm {
  const SetContains()
    : super(
        name: 'set.contains',
        parameters: const [
          Parameter.set('a'),
          Parameter.any('b'),
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

    if (a is SetTerm) {
      for (final Term element in a.value) {
        final BooleanTerm comparison = CompEq.execute(
          function: this,
          a: element.reduce(),
          b: b,
        );

        if (comparison.value) {
          return const BooleanTerm(true);
        }
      }

      return const BooleanTerm(false);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
