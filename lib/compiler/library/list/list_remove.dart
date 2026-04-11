import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class ListRemove extends NativeFunctionTerm {
  const ListRemove()
    : super(
        name: 'list.remove',
        parameters: const [
          Parameter.list('a'),
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

    if (a is ListTerm) {
      final List<Term> result = [];

      for (final Term element in a.value) {
        final Term elementReduced = element.reduce();
        final BooleanTerm comparison = CompEq.execute(
          function: this,
          a: elementReduced,
          b: b,
        );

        if (!comparison.value) {
          result.add(elementReduced);
        }
      }

      return ListTerm(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
