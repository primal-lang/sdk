import 'package:primal/compiler/runtime/node.dart';

class Mapper {
  static Map<String, FunctionNode> toMap(
      List<FunctionNode> functions) {
    final Map<String, FunctionNode> result = {};

    for (final FunctionNode function in functions) {
      result[function.name] = function;
    }

    return result;
  }
}
