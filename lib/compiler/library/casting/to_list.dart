import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class ToList extends NativeFunctionTerm {
  const ToList()
    : super(
        name: 'to.list',
        parameters: const [
          Parameter.any('a'),
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

    if (a is SetTerm) {
      return ListTerm(a.value.toList());
    } else if (a is VectorTerm) {
      return ListTerm(a.value);
    } else if (a is StackTerm) {
      return ListTerm(a.value);
    } else if (a is QueueTerm) {
      return ListTerm(a.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
