import 'package:purified/compiler/compiler.dart';
import 'package:purified/compiler/runtime/runtime.dart';
import 'package:purified/compiler/semantic/intermediate_code.dart';
import 'package:purified/compiler/syntactic/expression.dart';
import 'package:purified/compiler/warnings/generic_warning.dart';
import 'package:purified/utils/console.dart';
import 'package:purified/utils/file_reader.dart';

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
      final String result = runtime.executeMain();
      console.print(result);
    } else {
      console.prompt((input) {
        final Expression expression = compiler.expression(input);
        console.print(runtime.reduce(expression));
      });
    }
  } catch (e) {
    console.error(e);
  }
}
