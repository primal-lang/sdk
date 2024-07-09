import 'package:dry/models/expression.dart';
import 'package:dry/models/function_definition.dart';

class ByteCode {
  final Map<String, FunctionDefinition> functions;

  const ByteCode({required this.functions});

  bool get hasMain => true;

  void executeMain() {
    // TODO(momo): implement
  }

  void evaluate(Expression expression) {
    // TODO(momo): implement
  }
}
