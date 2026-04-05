import 'dart:math' show min;
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class ListTake extends NativeFunctionTerm {
  const ListTake()
    : super(
        name: 'list.take',
        parameters: const [
          Parameter.list('a'),
          Parameter.number('b'),
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

    if ((a is ListTerm) && (b is NumberTerm)) {
      final int count = b.value.toInt();
      if (count < 0) {
        throw NegativeIndexError(function: name, index: count);
      }
      final int clampedCount = min(count, a.value.length);
      return ListTerm(a.value.sublist(0, clampedCount));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
