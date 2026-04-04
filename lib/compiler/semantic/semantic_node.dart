import 'package:primal/compiler/models/function_signature.dart';
import 'package:primal/compiler/models/location.dart';

/// Base class for all semantic IR nodes.
///
/// Semantic nodes represent the bound AST after semantic analysis,
/// preserving source locations and resolved references for richer
/// diagnostics and future optimization passes.
abstract class SemanticNode {
  final Location location;

  const SemanticNode({required this.location});
}

/// Base class for semantic literal nodes.
abstract class SemanticLiteralNode<T> extends SemanticNode {
  final T value;

  const SemanticLiteralNode({
    required super.location,
    required this.value,
  });

  @override
  String toString() => value.toString();
}

class SemanticBooleanNode extends SemanticLiteralNode<bool> {
  const SemanticBooleanNode({
    required super.location,
    required super.value,
  });
}

class SemanticNumberNode extends SemanticLiteralNode<num> {
  const SemanticNumberNode({
    required super.location,
    required super.value,
  });
}

class SemanticStringNode extends SemanticLiteralNode<String> {
  const SemanticStringNode({
    required super.location,
    required super.value,
  });

  @override
  String toString() => '"$value"';
}

class SemanticListNode extends SemanticLiteralNode<List<SemanticNode>> {
  const SemanticListNode({
    required super.location,
    required super.value,
  });

  @override
  String toString() => '[${value.join(', ')}]';
}

class SemanticMapEntryNode {
  final SemanticNode key;
  final SemanticNode value;

  const SemanticMapEntryNode({
    required this.key,
    required this.value,
  });

  @override
  String toString() => '$key: $value';
}

class SemanticMapNode extends SemanticLiteralNode<List<SemanticMapEntryNode>> {
  const SemanticMapNode({
    required super.location,
    required super.value,
  });

  @override
  String toString() => '{${value.join(', ')}}';
}

/// A reference to a function, resolved during semantic analysis.
///
/// The [resolvedSignature] field holds the function signature when the
/// identifier refers to a known function. This enables static arity checking
/// and future optimizations without depending on runtime node types.
class SemanticIdentifierNode extends SemanticNode {
  final String name;
  final FunctionSignature? resolvedSignature;

  const SemanticIdentifierNode({
    required super.location,
    required this.name,
    this.resolvedSignature,
  });

  @override
  String toString() => name;
}

/// A reference to a bound parameter within a function body.
///
/// Created during semantic analysis when an identifier matches a parameter name.
class SemanticBoundVariableNode extends SemanticNode {
  final String name;

  const SemanticBoundVariableNode({
    required super.location,
    required this.name,
  });

  @override
  String toString() => name;
}

/// A function call expression.
class SemanticCallNode extends SemanticNode {
  final SemanticNode callee;
  final List<SemanticNode> arguments;

  const SemanticCallNode({
    required super.location,
    required this.callee,
    required this.arguments,
  });

  @override
  String toString() => '$callee(${arguments.join(', ')})';
}
