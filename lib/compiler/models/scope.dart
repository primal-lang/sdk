import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/models/reducible.dart';

class Scope {
  final Map<String, Reducible> global;
  final Map<String, Reducible> local;

  const Scope(this.global, [this.local = const {}]);

  Scope apply({
    required String functionName,
    required List<Parameter> parameters,
    required List<Reducible> arguments,
  }) {
    final Map<String, Reducible> result = {};

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

    return Scope(global, result);
  }

  Reducible get(String name) {
    final Reducible? resultLocal = local[name];

    if (resultLocal == null) {
      final Reducible? resultGlobal = global[name];

      if (resultGlobal == null) {
        throw UndefinedArgumentError(name);
      } else {
        return resultGlobal;
      }
    } else {
      return resultLocal;
    }
  }
}
