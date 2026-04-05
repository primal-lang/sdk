import 'package:primal/compiler/runtime/term.dart';

class Mapper {
  static Map<String, FunctionTerm> toMap(List<FunctionTerm> functions) {
    final Map<String, FunctionTerm> result = {};

    for (final FunctionTerm function in functions) {
      result[function.name] = function;
    }

    return result;
  }
}
