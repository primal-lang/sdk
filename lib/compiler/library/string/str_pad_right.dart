import 'package:characters/characters.dart';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/term.dart';

class StrPadRight extends NativeFunctionTerm {
  const StrPadRight()
    : super(
        name: 'str.padRight',
        parameters: const [
          Parameter.string('a'),
          Parameter.number('b'),
          Parameter.string('c'),
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

    if ((a is StringTerm) && (b is NumberTerm) && (c is StringTerm)) {
      final int targetWidth = b.value.toInt();
      final int currentLength = a.value.characters.length;
      if (currentLength >= targetWidth) {
        return StringTerm(a.value);
      }
      final int padCount = targetWidth - currentLength;
      return StringTerm(a.value + c.value * padCount);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
