import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/location.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';

class Scope<T> {
  final Map<String, T> data;

  const Scope([this.data = const {}]);

  static Scope<Reducible> from({
    required String functionName,
    required List<Parameter> parameters,
    required List<Reducible> arguments,
    required Location location,
  }) {
    final Map<String, Reducible> result = {};

    if (parameters.length != arguments.length) {
      throw InvalidArgumentCountError(
        function: functionName,
        expected: parameters.length,
        actual: arguments.length,
        location: location,
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
      throw NotFoundInScope(name.split('/')[0]);
    } else {
      return result;
    }
  }
}
