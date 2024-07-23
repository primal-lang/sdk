import 'package:dry/compiler/models/reducible.dart';
import 'package:dry/compiler/models/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';
import 'package:dry/compiler/syntactic/expression.dart';
import 'package:dry/compiler/warnings/generic_warning.dart';

class IntermediateCode {
  final Map<String, FunctionPrototype> functions;
  final List<GenericWarning> warnings;

  const IntermediateCode({
    required this.functions,
    required this.warnings,
  });

  FunctionPrototype? get main {
    final FunctionPrototype? main = functions['main'];

    return ((main != null) && main.parameters.isEmpty) ? main : null;
  }

  bool get hasMain => main != null;

  String executeMain() {
    final Reducible result = main!.evaluate(Scope(functions));

    return result.toString();
  }

  String evaluate(Expression expression) {
    final FunctionPrototype function =
        AnonymousFunctionPrototype(reducible: expression.toReducible());
    final Reducible result = function.evaluate(Scope(functions));

    return result.toString();
  }

  factory IntermediateCode.empty() => const IntermediateCode(
        functions: {},
        warnings: [],
      );
}
