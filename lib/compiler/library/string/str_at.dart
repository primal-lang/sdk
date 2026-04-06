import 'package:characters/characters.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class StrAt extends NativeFunctionTerm {
  const StrAt()
    : super(
        name: 'str.at',
        parameters: const [
          Parameter.string('a'),
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

    if ((a is StringTerm) && (b is NumberTerm)) {
      final int index = b.value.toInt();
      final Characters chars = a.value.characters;
      if (index < 0) {
        throw NegativeIndexError(function: name, index: index);
      }
      if (index >= chars.length) {
        throw IndexOutOfBoundsError(
          function: name,
          index: index,
          length: chars.length,
        );
      }
      return StringTerm(chars.elementAt(index));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
