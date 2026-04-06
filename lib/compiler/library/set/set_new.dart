import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class SetNew extends NativeFunctionTerm {
  const SetNew()
    : super(
        name: 'set.new',
        parameters: const [
          Parameter.list('a'),
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

    if (a is ListTerm) {
      final Set<Term> termElements = {};
      final Set<dynamic> nativeElements = {};

      for (final Term element in a.value) {
        final dynamic native = element.native();

        if (!nativeElements.contains(native)) {
          termElements.add(element);
          nativeElements.add(native);
        }
      }

      return SetTerm(termElements);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
