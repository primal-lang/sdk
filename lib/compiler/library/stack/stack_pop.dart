import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class StackPop extends NativeFunctionTerm {
  const StackPop()
    : super(
        name: 'stack.pop',
        parameters: const [
          Parameter.stack('a'),
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

    if (a is StackTerm) {
      if (a.value.isEmpty) {
        throw EmptyCollectionError(function: name, collectionType: 'stack');
      }

      return StackTerm(a.value.sublist(0, a.value.length - 1));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
