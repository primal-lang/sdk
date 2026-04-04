import 'package:primal/compiler/models/parameter.dart';

/// A phase-agnostic function signature.
///
/// Used during semantic analysis to validate calls without
/// depending on runtime node types.
class FunctionSignature {
  final String name;
  final List<Parameter> parameters;

  const FunctionSignature({
    required this.name,
    required this.parameters,
  });

  int get arity => parameters.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionSignature &&
          name == other.name &&
          _parametersEqual(parameters, other.parameters);

  @override
  int get hashCode =>
      Object.hash(name, Object.hashAll(parameters.map((p) => p.name)));

  static bool _parametersEqual(List<Parameter> a, List<Parameter> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i].name != b[i].name) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() => '$name(${parameters.map((p) => p.name).join(', ')})';
}
