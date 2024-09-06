import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class Bindings {
  final Map<String, Node> data;

  const Bindings(this.data);

  Node get(String name) {
    if (data.containsKey(name)) {
      return data[name]!;
    } else {
      throw NotFoundInScopeError(name);
    }
  }

  factory Bindings.from({
    required List<Parameter> parameters,
    required List<Node> arguments,
  }) {
    final Map<String, Node> bindings = {};

    for (int i = 0; i < parameters.length; i++) {
      bindings[parameters[i].name] = arguments[i];
    }

    return Bindings(bindings);
  }
}
