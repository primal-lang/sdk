import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class Scope<T> {
  final Map<String, T> data;

  const Scope([this.data = const {}]);

  static Scope<Node> from({
    required String functionName,
    required List<Parameter> parameters,
    required List<Node> arguments,
  }) {
    final Map<String, Node> result = {};

    if (parameters.length != arguments.length) {
      throw InvalidArgumentCountError(
        function: functionName,
        expected: parameters.length,
        actual: arguments.length,
      );
    } else {
      for (int i = 0; i < parameters.length; i++) {
        result[parameters[i].name] = arguments[i];
      }
    }

    return Scope(result);
  }

  T get(String name) {
    final T? result = data[name];

    if (result == null) {
      throw NotFoundInScopeError(name);
    } else {
      return result;
    }
  }
}
