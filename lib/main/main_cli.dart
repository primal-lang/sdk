import 'package:primal/compiler/compiler.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/semantic/intermediate_code.dart';
import 'package:primal/compiler/syntactic/expression.dart';
import 'package:primal/compiler/warnings/generic_warning.dart';
import 'package:primal/utils/console.dart';
import 'package:primal/utils/file_reader.dart';

void main(List<String> args) {
  final Console console = Console();

  try {
    const Compiler compiler = Compiler();
    final IntermediateCode intermediateCode = args.isNotEmpty
        ? compiler.compile(FileReader.read(args[0]))
        : IntermediateCode.empty();

    for (final GenericWarning warning in intermediateCode.warnings) {
      console.warning(warning);
    }

    final Runtime runtime = Runtime(intermediateCode);

    if (runtime.hasMain) {
      final String result =
          runtime.executeMain((args.length > 1) ? args.sublist(1) : []);
      console.print(result);
    } else {
      console.prompt((input) {
        final Expression expression = compiler.expression(input);
        console.print(runtime.evaluate(expression));
      });
    }
  } catch (e) {
    console.error(e);
  }
}
