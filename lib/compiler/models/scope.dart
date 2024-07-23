import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/reducible.dart';

class Scope {
  final Map<String, Reducible> data;

  const Scope(this.data);

  Reducible get(String name) {
    final Reducible? result = data[name];

    if (result == null) {
      throw UndefinedArgumentError(name);
    } else {
      return result;
    }
  }
}
