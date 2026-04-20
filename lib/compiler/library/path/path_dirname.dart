import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/term.dart';

class PathDirname extends NativeFunctionTerm {
  const PathDirname()
    : super(
        name: 'path.dirname',
        parameters: const [Parameter.string('a')],
      );

  @override
  Term term(List<Term> arguments) => PathDirnameWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class PathDirnameWithArguments extends NativeFunctionTermWithArguments {
  const PathDirnameWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();

    if (a is StringTerm) {
      final String result = PlatformInterface().path.dirname(a.value);

      return StringTerm(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
