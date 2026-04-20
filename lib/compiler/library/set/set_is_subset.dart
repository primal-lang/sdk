import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class SetIsSubset extends NativeFunctionTerm {
  const SetIsSubset()
    : super(
        name: 'set.isSubset',
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
      final Set<dynamic> setB = b.native();

      for (final Term element in a.value) {
        if (!setB.contains(element.native())) {
          return const BooleanTerm(false);
        }
      }

      return const BooleanTerm(true);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
