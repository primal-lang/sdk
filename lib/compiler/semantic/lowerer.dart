import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/semantic_function.dart';
import 'package:primal/compiler/semantic/semantic_node.dart';
import 'package:primal/compiler/syntactic/expression.dart';

/// Converts semantic IR to runtime nodes for execution.
///
/// This pass strips source locations and produces the minimal runtime
/// representation needed for evaluation.
class Lowerer {
  const Lowerer();

  /// Converts a syntactic [Expression] to a runtime [Node].
  ///
  /// This is used for ad-hoc expression evaluation at runtime, such as
  /// the REPL or dynamic expression construction.
  Node lowerExpression(Expression expression) => switch (expression) {
    BooleanExpression() => BooleanNode(expression.value),
    NumberExpression() => NumberNode(expression.value),
    StringExpression() => StringNode(expression.value),
    ListExpression() => _lowerListExpression(expression),
    MapExpression() => _lowerMapExpression(expression),
    IdentifierExpression() => IdentifierNode(expression.value),
    CallExpression() => _lowerCallExpression(expression),
    _ => throw StateError(
      'Unknown expression type: ${expression.runtimeType}',
    ),
  };

  Node _lowerListExpression(ListExpression expression) {
    return ListNode(expression.value.map(lowerExpression).toList());
  }

  Node _lowerMapExpression(MapExpression expression) {
    final Map<Node, Node> entries = {};
    for (final entry in expression.value) {
      entries[lowerExpression(entry.key)] = lowerExpression(entry.value);
    }
    return MapNode(entries);
  }

  Node _lowerCallExpression(CallExpression expression) {
    return CallNode(
      callee: lowerExpression(expression.callee),
      arguments: expression.arguments.map(lowerExpression).toList(),
    );
  }

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
    SemanticIdentifierNode() => IdentifierNode(node.name),
    SemanticBoundVariableNode() => BoundVariableNode(node.name),
    SemanticCallNode() => _lowerCall(node),
    _ => throw StateError('Unknown semantic node type: ${node.runtimeType}'),
  };

  Node _lowerList(SemanticListNode node) {
    return ListNode(node.value.map(lowerNode).toList());
  }

  Node _lowerMap(SemanticMapNode node) {
    final Map<Node, Node> entries = {};
    for (final entry in node.value) {
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
