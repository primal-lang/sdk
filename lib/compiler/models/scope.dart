import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/reducible.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class Scope {
  final Map<String, Reducible> data;

  const Scope(this.data);

  Reducible get(FunctionPrototype caller, String name) {
    final Reducible? result = data[name];

    if (result == null) {
      throw UndefinedArgumentError(
        function: caller.name,
        argument: name,
      );
    } else {
      return result;
    }
  }
}
