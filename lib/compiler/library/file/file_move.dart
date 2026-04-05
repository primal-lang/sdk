import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/term.dart';

class FileMove extends NativeFunctionTerm {
  const FileMove()
    : super(
        name: 'file.move',
        parameters: const [
          Parameter.file('a'),
          Parameter.file('b'),
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

    if ((a is FileTerm) && (b is FileTerm)) {
      final bool moved = PlatformInterface().file.move(a.value, b.value);

      return BooleanTerm(moved);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
