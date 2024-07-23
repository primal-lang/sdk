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

  // TODO(momo): implement
  String executeMain() => evaluate(const EmptyExpression());

  // TODO(momo): implement
  String evaluate(Expression expression) {
    return expression.toString();
  }

  factory IntermediateCode.empty() => const IntermediateCode(
        functions: {},
        warnings: [],
      );
}
