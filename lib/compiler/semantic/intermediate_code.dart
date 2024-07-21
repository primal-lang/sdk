import 'package:dry/compiler/semantic/function_prototype.dart';
import 'package:dry/compiler/syntactic/expression.dart';

class IntermediateCode {
  final Map<String, FunctionPrototype> functions;

  const IntermediateCode({required this.functions});

  bool get hasMain => functions.containsKey('main');

  // TODO(momo): implement
  String executeMain() => evaluate(const EmptyExpression());

  // TODO(momo): implement
  String evaluate(Expression expression) {
    return expression.toString();
  }
}
