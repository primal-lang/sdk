import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/term.dart';

class ListSort extends NativeFunctionTerm {
  const ListSort()
    : super(
        name: 'list.sort',
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
      final List<Term> result = List<Term>.from(a.value);

      result.sort((x, y) {
        final Term value = b.apply([x, y]);

        if (value is NumberTerm) {
          return value.value.toInt();
        } else {
          throw InvalidArgumentTypesError(
            function: name,
            expected: [const NumberType()],
            actual: [value.type],
          );
        }
      });

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
