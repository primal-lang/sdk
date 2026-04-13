import 'package:characters/characters.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class StrCapitalize extends NativeFunctionTerm {
  const StrCapitalize()
    : super(
        name: 'str.capitalize',
        parameters: const [
          Parameter.string('a'),
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

    if (a is StringTerm) {
      if (a.value.isEmpty) {
        return const StringTerm('');
      }
      final Characters characters = a.value.characters;
      return StringTerm(
        characters.first.toUpperCase() + characters.skip(1).string,
      );
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
