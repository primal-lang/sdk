import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';

/// Converts semantic IR to runtime nodes for execution.
///
/// This pass strips source locations and resolves function references to
/// direct [FunctionNode] references, eliminating runtime name lookup.
class Lowerer {
  final Map<String, FunctionNode> functions;

  const Lowerer(this.functions);

  /// Converts a [SemanticFunction] to a [CustomFunctionNode].
  CustomFunctionNode lowerFunction(SemanticFunction function) {
    return CustomFunctionNode(
      name: function.name,
      parameters: function.parameters,
      node: lowerNode(function.body),
    );
  }

  /// Converts a [SemanticNode] to a runtime [Node].
  Node lowerNode(SemanticNode node) => switch (node) {
    SemanticBooleanNode() => BooleanNode(node.value),
    SemanticNumberNode() => NumberNode(node.value),
    SemanticStringNode() => StringNode(node.value),
    SemanticListNode() => _lowerList(node),
    SemanticMapNode() => _lowerMap(node),
    SemanticIdentifierNode() => FunctionRefNode(node.name, functions),
    SemanticBoundVariableNode() => BoundVariableNode(node.name),
    SemanticCallNode() => _lowerCall(node),
    _ => throw StateError('Unknown semantic node type: ${node.runtimeType}'),
  };

  Node _lowerList(SemanticListNode node) {
    return ListNode(node.value.map(lowerNode).toList());
  }

  Node _lowerMap(SemanticMapNode node) {
    final Map<Node, Node> entries = {};
    for (final SemanticMapEntryNode entry in node.value) {
      entries[lowerNode(entry.key)] = lowerNode(entry.value);
    }
    return MapNode(entries);
  }

  Node _lowerCall(SemanticCallNode node) {
    return CallNode(
      callee: lowerNode(node.callee),
      arguments: node.arguments.map(lowerNode).toList(),
    );
  }
}
