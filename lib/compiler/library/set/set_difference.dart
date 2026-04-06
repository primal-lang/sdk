import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class SetDifference extends NativeFunctionTerm {
  const SetDifference()
    : super(
        name: 'set.difference',
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
    required SetTerm a,
    required SetTerm b,
  }) {
    final Set<dynamic> setB = b.native();
    final Set<Term> result = {};

    for (final Term element in a.value) {
      if (!setB.contains(element.native())) {
        result.add(element);
      }
    }

    return SetTerm(result);
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

    if ((a is SetTerm) && (b is SetTerm)) {
      return SetDifference.execute(
        function: this,
        a: a,
        b: b,
      );
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
