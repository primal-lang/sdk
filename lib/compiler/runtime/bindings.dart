import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class Bindings {
  final Map<String, Node> data;

  const Bindings(this.data);

  Node get(String name) {
    if (data.containsKey(name)) {
      return data[name]!;
    } else {
      // TODO(momo): handle
      throw Exception('Variable not found: $name');
    }
  }

  factory Bindings.from({
    required List<Parameter> parameters,
    required List<Node> arguments,
  }) {
    final Map<String, Node> bindings = {};

    for (int i = 0; i < parameters.length; i++) {
      final Parameter parameter = parameters[i];
      bindings[parameter.name] = arguments[i];
    }

    return Bindings(bindings);
  }
}
