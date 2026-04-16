import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/term.dart';

class PathJoin extends NativeFunctionTerm {
  const PathJoin()
    : super(
        name: 'path.join',
        parameters: const [
          Parameter.string('a'),
          Parameter.string('b'),
        ],
      );

  @override
  Term term(List<Term> arguments) => PathJoinWithArguments(
    name: name,
    parameters: parameters,
    arguments: arguments,
  );
}

class PathJoinWithArguments extends NativeFunctionTermWithArguments {
  const PathJoinWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Term reduce() {
    final Term a = arguments[0].reduce();
    final Term b = arguments[1].reduce();

    if ((a is StringTerm) && (b is StringTerm)) {
      final String result = PlatformInterface().path.join(a.value, b.value);

      return StringTerm(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
