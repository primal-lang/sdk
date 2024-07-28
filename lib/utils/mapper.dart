import 'package:dry/compiler/semantic/function_prototype.dart';

class Mapper {
  static Map<String, FunctionPrototype> toMap(
      List<FunctionPrototype> functions) {
    final Map<String, FunctionPrototype> result = {};

    for (final FunctionPrototype function in functions) {
      result['${function.name}/${function.parameters.length}'] = function;
    }

    return result;
  }
}
