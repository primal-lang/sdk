import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/models/reducible.dart';

class Scope {
  final Map<String, Reducible> data;

  const Scope([this.data = const {}]);

  factory Scope.from({
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

    return Scope(result);
  }

  Reducible get(String name) {
    final Reducible? result = data[name];

    if (result == null) {
      throw UndefinedArgumentError(name);
    } else {
      return result;
    }
  }
}
