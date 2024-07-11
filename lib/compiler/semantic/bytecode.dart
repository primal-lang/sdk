import 'package:dry/compiler/semantic/function_prototype.dart';
import 'package:dry/compiler/syntactic/expression.dart';

class ByteCode {
  final Map<String, FunctionPrototype> functions;

  const ByteCode({required this.functions});

  bool get hasMain => true;

  void executeMain() {
    // TODO(momo): implement
  }

  void evaluate(Expression expression) {
    // TODO(momo): implement
  }
}
