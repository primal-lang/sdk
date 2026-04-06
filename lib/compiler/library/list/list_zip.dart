import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class ListZip extends NativeFunctionTerm {
  const ListZip()
    : super(
        name: 'list.zip',
        parameters: const [
          Parameter.list('a'),
          Parameter.list('b'),
          Parameter.function('c'),
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

    if ((a is ListTerm) && (b is ListTerm) && (c is FunctionTerm)) {
      final List<Term> result = [];
      final int maxLength = max(a.value.length, b.value.length);

      for (int i = 0; i < maxLength; i++) {
        final Term? elementA = i < a.value.length ? a.value[i] : null;
        final Term? elementB = i < b.value.length ? b.value[i] : null;

        if (elementA != null && elementB != null) {
          final Term value = c.apply([elementA, elementB]);
          result.add(value);
        } else if (elementA != null) {
          result.add(elementA);
        } else if (elementB != null) {
          result.add(elementB);
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
