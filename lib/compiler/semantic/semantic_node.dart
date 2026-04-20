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
/// and future optimizations without depending on runtime term types.
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

/// A reference to a bound variable (parameter or let binding) within a function body.
///
/// Created during semantic analysis when an identifier matches a parameter name
/// or a let binding name.
class SemanticBoundVariableNode extends SemanticNode {
  final String name;
  final bool isLetBinding;
  final bool isLambdaParameter;

  const SemanticBoundVariableNode({
    required super.location,
    required this.name,
    this.isLetBinding = false,
    this.isLambdaParameter = false,
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

/// A single binding within a let expression.
class SemanticLetBindingNode {
  final String name;
  final SemanticNode value;
  final Location location;

  const SemanticLetBindingNode({
    required this.name,
    required this.value,
    required this.location,
  });

  @override
  String toString() => '$name = $value';
}

/// A let expression with local bindings.
class SemanticLetNode extends SemanticNode {
  final List<SemanticLetBindingNode> bindings;
  final SemanticNode body;

  const SemanticLetNode({
    required super.location,
    required this.bindings,
    required this.body,
  });

  @override
  String toString() {
    final String bindingsString = bindings.join(', ');
    return 'let $bindingsString in $body';
  }
}

/// A lambda expression with parameters and body.
class SemanticLambdaNode extends SemanticNode {
  final List<String> parameters;
  final SemanticNode body;

  const SemanticLambdaNode({
    required super.location,
    required this.parameters,
    required this.body,
  });

  @override
  String toString() => '(${parameters.join(', ')}) -> $body';
}
