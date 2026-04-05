import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class ListSublist extends NativeFunctionTerm {
  const ListSublist()
    : super(
        name: 'list.sublist',
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
      final int start = b.value.toInt();
      final int end = c.value.toInt();
      if (start < 0) {
        throw NegativeIndexError(function: name, index: start);
      }
      if (start > a.value.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: start,
          length: a.value.length,
        );
      }
      if (end < start) {
        throw IndexOutOfBoundsError(
          function: name,
          index: end,
          length: a.value.length,
        );
      }
      if (end > a.value.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: end,
          length: a.value.length,
        );
      }
      return ListTerm(a.value.sublist(start, end));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
