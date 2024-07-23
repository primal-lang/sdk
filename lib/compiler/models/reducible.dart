import 'package:dry/compiler/models/location.dart';
import 'package:dry/compiler/models/scope.dart';

abstract class Reducible {
  const Reducible();

  String get type;

  Reducible evaluate(Scope scope);
}

class SymbolReducible extends Reducible {
  final String value;
  final Location location;

  const SymbolReducible({
    required this.value,
    required this.location,
  });

  @override
  Reducible evaluate(Scope scope) {
    throw UnimplementedError(); // TODO(momo): implement
  }

  @override
  String get type => value;
}

class FunctionCallReducible extends Reducible {
  final String name;
  final List<Reducible> arguments;
  final Location location;

  const FunctionCallReducible({
    required this.name,
    required this.arguments,
    required this.location,
  });

  @override
  Reducible evaluate(Scope scope) {
    final Reducible reducible = scope.get(name);

    return reducible.evaluate(scope);
  }

  @override
  String get type => '$name(${arguments.join(', ')})';
}
