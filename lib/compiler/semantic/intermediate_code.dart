import 'package:dry/compiler/semantic/function_prototype.dart';
import 'package:dry/compiler/syntactic/expression.dart';

class IntermediateCode {
  final Map<String, FunctionPrototype> functions;

  const IntermediateCode({required this.functions});

  bool get hasMain => functions.containsKey('main');

  String executeMain() {
    // TODO(momo): implement
    return '';
  }

  void evaluate(Expression expression) {
    // TODO(momo): implement
  }
}
