import 'package:primal/compiler/runtime/node.dart';

class RuntimeInput {
  final Map<String, FunctionNode> functions;

  const RuntimeInput(this.functions);

  bool containsFunction(String name) => functions.containsKey(name);

  FunctionNode? getFunction(String name) => functions[name];
}
