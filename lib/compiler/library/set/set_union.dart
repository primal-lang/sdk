import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class SetUnion extends NativeFunctionTerm {
  const SetUnion()
    : super(
        name: 'set.union',
        parameters: const [
          Parameter.set('a'),
          Parameter.set('b'),
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
    if ((a is SetTerm) && (b is SetTerm)) {
      final Set<Term> set = {...a.value};

      for (final Term element in b.value) {
        if (!set.contains(element.native())) {
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

    return SetUnion.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
