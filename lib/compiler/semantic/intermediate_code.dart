import 'package:dry/compiler/models/scope.dart';
import 'package:dry/compiler/models/value.dart';
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
    final Value value = main!.evaluate([], const Scope());

    return value.toString();
  }

  String evaluate(Expression expression) {
    final FunctionPrototype function =
        AnonymousFunctionPrototype(expression: expression);
    final Value value = function.evaluate([], const Scope());

    return value.toString();
  }

  factory IntermediateCode.empty() => const IntermediateCode(
        functions: {},
        warnings: [],
      );
}
