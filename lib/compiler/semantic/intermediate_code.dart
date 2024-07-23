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

  String executeMain() => main!.evaluate(const Scope());

  String evaluate(Expression expression) {
    final FunctionPrototype function =
        AnonymousFunctionPrototype(expression: expression);

    return function.evaluate(const Scope());
  }

  factory IntermediateCode.empty() => const IntermediateCode(
        functions: {},
        warnings: [],
      );
}
