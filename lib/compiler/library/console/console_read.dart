import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/term.dart';

class ConsoleRead extends NativeFunctionTerm {
  const ConsoleRead()
    : super(
        name: 'console.read',
        parameters: const [],
      );

  @override
  Term term(List<Term> arguments) =>
      StringTerm(PlatformInterface().console.readLine());
}
