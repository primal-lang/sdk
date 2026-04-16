import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/term.dart';

class PathNormalize extends NativeFunctionTerm {
  const PathNormalize()
    : super(
        name: 'path.normalize',
        parameters: const [Parameter.string('a')],
      );

  @override
  Term term(List<Term> arguments) => PathNormalizeWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class PathNormalizeWithArguments extends NativeFunctionTermWithArguments {
  const PathNormalizeWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();

    if (a is StringTerm) {
      final String result = PlatformInterface().path.normalize(a.value);

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
