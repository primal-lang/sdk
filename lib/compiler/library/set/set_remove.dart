import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class SetRemove extends NativeFunctionTerm {
  const SetRemove()
    : super(
        name: 'set.remove',
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

  static SetTerm execute({
    required FunctionTerm function,
    required Term a,
    required Term b,
  }) {
    if (a is SetTerm) {
      final Set<Term> set = {};

      for (final Term element in a.value) {
        final BooleanTerm comparison = CompEq.execute(
          function: function,
          a: element.reduce(),
          b: b,
        );

        if (!comparison.value) {
          set.add(element);
        }
      }

      return SetTerm(set);
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type, b.type],
      );
    }
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

    return SetRemove.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
