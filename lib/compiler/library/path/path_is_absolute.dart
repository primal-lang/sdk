import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/term.dart';

class PathIsAbsolute extends NativeFunctionTerm {
  const PathIsAbsolute()
    : super(
        name: 'path.isAbsolute',
        parameters: const [Parameter.string('a')],
      );

  @override
  Term term(List<Term> arguments) => PathIsAbsoluteWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class PathIsAbsoluteWithArguments extends NativeFunctionTermWithArguments {
  const PathIsAbsoluteWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();

    if (a is StringTerm) {
      final bool result = PlatformInterface().path.isAbsolute(a.value);

      return BooleanTerm(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
