import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class ListIndexOf extends NativeFunctionTerm {
  const ListIndexOf()
    : super(
        name: 'list.indexOf',
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
      for (int i = 0; i < a.value.length; i++) {
        final BooleanTerm comparison = CompEq.execute(
          function: this,
          a: a.value[i].reduce(),
          b: b,
        );

        if (comparison.value) {
          return NumberTerm(i);
        }
      }

      return const NumberTerm(-1);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
