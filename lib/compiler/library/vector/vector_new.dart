import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class VectorNew extends NativeFunctionTerm {
  const VectorNew()
    : super(
        name: 'vector.new',
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
      for (final Term element in a.value) {
        final dynamic value = element.native();

        if (value is! num) {
          throw InvalidArgumentTypesError(
            function: name,
            expected: parameterTypes,
            actual: [a.type],
          );
        }
      }

      return VectorTerm(a.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
