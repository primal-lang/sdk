import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class ListSwap extends NativeFunctionTerm {
  const ListSwap()
    : super(
        name: 'list.swap',
        parameters: const [
          Parameter.list('a'),
          Parameter.number('b'),
          Parameter.number('c'),
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
    final Term c = arguments[2].reduce();

    if ((a is ListTerm) && (b is NumberTerm) && (c is NumberTerm)) {
      final int indexB = b.value.toInt();
      final int indexC = c.value.toInt();
      if (indexB < 0) {
        throw NegativeIndexError(function: name, index: indexB);
      }
      if (indexC < 0) {
        throw NegativeIndexError(function: name, index: indexC);
      }
      if (indexB >= a.value.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: indexB,
          length: a.value.length,
        );
      }
      if (indexC >= a.value.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: indexC,
          length: a.value.length,
        );
      }
      final List<Term> result = [];
      final Term valueAtB = a.value[indexB];
      final Term valueAtC = a.value[indexC];

      for (int i = 0; i < a.value.length; i++) {
        final Term element = a.value[i];

        if (i == indexB) {
          result.add(valueAtC);
        } else if (i == indexC) {
          result.add(valueAtB);
        } else {
          result.add(element);
        }
      }

      return ListTerm(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
