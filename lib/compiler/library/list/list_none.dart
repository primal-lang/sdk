import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/term.dart';

class ListNone extends NativeFunctionTerm {
  const ListNone()
    : super(
        name: 'list.none',
        parameters: const [
          Parameter.list('a'),
          Parameter.function('b'),
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

    if ((a is ListTerm) && (b is FunctionTerm)) {
      for (final Term element in a.value) {
        final Term value = b.apply([element]);

        if (value is! BooleanTerm) {
          throw InvalidArgumentTypesError(
            function: name,
            expected: [const BooleanType()],
            actual: [value.type],
          );
        }

        if (value.value) {
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
