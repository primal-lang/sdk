import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class VectorAdd extends NativeFunctionTerm {
  const VectorAdd()
    : super(
        name: 'vector.add',
        parameters: const [
          Parameter.vector('a'),
          Parameter.vector('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => TermWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );

  static VectorTerm execute({
    required FunctionTerm function,
    required Term a,
    required Term b,
  }) {
    if ((a is VectorTerm) && (b is VectorTerm)) {
      if (a.value.length != b.value.length) {
        throw IterablesWithDifferentLengthError(
          iterable1: a.native(),
          iterable2: b.native(),
        );
      }

      final List<Term> value = [];

      for (int i = 0; i < a.value.length; i++) {
        value.add(NumberTerm(a.value[i].native() + b.value[i].native()));
      }

      return VectorTerm(value);
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

    return VectorAdd.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
