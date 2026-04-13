import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class ListFlatten extends NativeFunctionTerm {
  const ListFlatten()
    : super(
        name: 'list.flatten',
        parameters: const [Parameter.list('a')],
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

    if (a is ListTerm) {
      final List<Term> result = [];

      for (final Term element in a.value) {
        final Term reduced = element.reduce();

        if (reduced is ListTerm) {
          result.addAll(reduced.value);
        } else {
          result.add(reduced);
        }
      }

      return ListTerm(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
