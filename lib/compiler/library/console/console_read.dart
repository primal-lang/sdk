import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/term.dart';

class ConsoleRead extends NativeFunctionTerm {
  const ConsoleRead()
    : super(
        name: 'console_read',
        parameters: const [],
      );

  // A program reading past the end of the input gets the empty string, the same
  // as it gets for a blank line. The distinction the platform draws between the
  // two is there for the REPL, which has to stop reading; a Primal program is
  // free to keep calling this and keep getting nothing.
  @override
  Term term(List<Term> arguments) =>
      StringTerm(PlatformInterface().console.readLine() ?? '');
}
