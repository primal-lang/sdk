import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';
import 'package:primal/utils/console.dart';
import 'package:primal/utils/file_reader.dart';

void main(List<String> args) => runCli(args);

void runCli(
  List<String> args, {
  Console? console,
  Compiler compiler = const Compiler(),
  String Function(String filePath)? readFile,
}) {
  final Console currentConsole = console ?? Console();
  final String Function(String filePath) sourceReader =
      readFile ?? FileReader.read;

  try {
    final IntermediateCode intermediateCode = args.isNotEmpty
        ? compiler.compile(sourceReader(args[0]))
        : IntermediateCode.empty();

    for (final GenericWarning warning in intermediateCode.warnings) {
      currentConsole.warning(warning);
    }

    final Runtime runtime = Runtime(intermediateCode);

    if (runtime.hasMain) {
      final String result = runtime.executeMain(
        (args.length > 1) ? args.sublist(1) : [],
      );
      currentConsole.print(result);
    } else {
      currentConsole.prompt((input) {
        final Expression expression = compiler.expression(input);
        currentConsole.print(runtime.evaluate(expression));
      });
    }
  } catch (e) {
    currentConsole.error(e);
  }
}
