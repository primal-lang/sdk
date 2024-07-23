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

  bool get hasMain => functions.containsKey('main');

  // TODO(momo): implement
  String executeMain() => evaluate(const EmptyExpression());

  // TODO(momo): implement
  String evaluate(Expression expression) {
    return expression.toString();
  }
}
