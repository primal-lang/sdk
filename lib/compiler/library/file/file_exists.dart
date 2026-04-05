import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/term.dart';

class FileExists extends NativeFunctionTerm {
  const FileExists()
    : super(
        name: 'file.exists',
        parameters: const [
          Parameter.file('a'),
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

    if (a is FileTerm) {
      final bool exists = PlatformInterface().file.exists(a.value);

      return BooleanTerm(exists);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
