import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/term.dart';

class PathExtension extends NativeFunctionTerm {
  const PathExtension()
    : super(
        name: 'path.extension',
        parameters: const [Parameter.string('a')],
      );

  @override
  Term term(List<Term> arguments) => PathExtensionWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class PathExtensionWithArguments extends NativeFunctionTermWithArguments {
  const PathExtensionWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();

    if (a is StringTerm) {
      final String result = PlatformInterface().path.extension(a.value);

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
