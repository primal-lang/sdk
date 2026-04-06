import 'package:primal/compiler/runtime/term.dart';

class RuntimeInput {
  final Map<String, FunctionTerm> functions;

  const RuntimeInput(this.functions);

  bool containsFunction(String name) => functions.containsKey(name);

  FunctionTerm? getFunction(String name) => functions[name];
}
