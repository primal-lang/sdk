import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';

/// A user-defined function after semantic analysis.
///
/// Unlike [CustomFunctionNode] which uses runtime nodes, this class
/// preserves source locations and resolved references in its body.
class SemanticFunction {
  final String name;
  final List<Parameter> parameters;
  final SemanticNode body;
  final Location location;

  const SemanticFunction({
    required this.name,
    required this.parameters,
    required this.body,
    required this.location,
  });

  @override
  String toString() => '$name(${parameters.map((e) => e.name).join(', ')})';
}
