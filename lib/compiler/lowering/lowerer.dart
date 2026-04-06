import 'package:primal/compiler/runtime/term.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';

/// Converts semantic IR to runtime terms for execution.
///
/// This pass strips source locations and resolves function references to
/// direct [FunctionTerm] references, eliminating runtime name lookup.
class Lowerer {
  final Map<String, FunctionTerm> functions;

  const Lowerer(this.functions);

  /// Converts a [SemanticFunction] to a [CustomFunctionTerm].
  CustomFunctionTerm lowerFunction(SemanticFunction function) {
    return CustomFunctionTerm(
      name: function.name,
      parameters: function.parameters,
      term: lowerTerm(function.body),
    );
  }

  /// Converts a [SemanticNode] to a runtime [Term].
  Term lowerTerm(SemanticNode semanticNode) => switch (semanticNode) {
    SemanticBooleanNode() => BooleanTerm(semanticNode.value),
    SemanticNumberNode() => NumberTerm(semanticNode.value),
    SemanticStringNode() => StringTerm(semanticNode.value),
    SemanticListNode() => _lowerList(semanticNode),
    SemanticMapNode() => _lowerMap(semanticNode),
    SemanticIdentifierNode() => FunctionReferenceTerm(
      semanticNode.name,
      functions,
    ),
    SemanticBoundVariableNode() => BoundVariableTerm(semanticNode.name),
    SemanticCallNode() => _lowerCall(semanticNode),
    _ => throw StateError(
      'Unknown semantic node type: ${semanticNode.runtimeType}',
    ),
  };

  Term _lowerList(SemanticListNode semanticNode) {
    return ListTerm(semanticNode.value.map(lowerTerm).toList());
  }

  Term _lowerMap(SemanticMapNode semanticNode) {
    final Map<Term, Term> entries = {};
    for (final SemanticMapEntryNode entry in semanticNode.value) {
      entries[lowerTerm(entry.key)] = lowerTerm(entry.value);
    }
    return MapTerm(entries);
  }

  Term _lowerCall(SemanticCallNode semanticNode) {
    return CallTerm(
      callee: lowerTerm(semanticNode.callee),
      arguments: semanticNode.arguments.map(lowerTerm).toList(),
    );
  }
}
