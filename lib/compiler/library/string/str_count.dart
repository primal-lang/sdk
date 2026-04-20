import 'package:characters/characters.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class StrCount extends NativeFunctionTerm {
  const StrCount()
    : super(
        name: 'str.count',
        parameters: const [
          Parameter.string('a'),
          Parameter.string('b'),
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

    if ((a is StringTerm) && (b is StringTerm)) {
      if (b.value.isEmpty) {
        return NumberTerm(a.value.characters.length + 1);
      }
      final int count = RegExp(
        RegExp.escape(b.value),
      ).allMatches(a.value).length;
      return NumberTerm(count);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
