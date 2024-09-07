import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/runtime/node.dart';

abstract class Expression extends Localized {
  const Expression({required super.location});

  Node toNode();
}

abstract class LiteralExpression<T> extends Expression {
  final T value;

  const LiteralExpression({
    required super.location,
    required this.value,
  });

  @override
  String toString() => value.toString();
}

class BooleanExpression extends LiteralExpression<bool> {
  BooleanExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  Node toNode() => BooleanNode(value);
}

class NumberExpression extends LiteralExpression<num> {
  NumberExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  Node toNode() => NumberNode(value);
}

class StringExpression extends LiteralExpression<String> {
  StringExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  String toString() => '"$value"';

  @override
  Node toNode() => StringNode(value);
}

class ListExpression extends LiteralExpression<List<Expression>> {
  const ListExpression({
    required super.location,
    required super.value,
  });

  @override
  Node toNode() => ListNode(value.map((e) => e.toNode()).toList());
}

class MapExpression extends LiteralExpression<Map<Expression, Expression>> {
  const MapExpression({
    required super.location,
    required super.value,
  });

  @override
  Node toNode() {
    final Iterable<MapEntry<Node, Node>> entries =
        value.entries.map((e) => MapEntry(e.key.toNode(), e.value.toNode()));

    return MapNode(Map.fromEntries(entries));
  }
}

class IdentifierExpression extends LiteralExpression<String> {
  IdentifierExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  Node toNode() => FreeVariableNode(value);
}

class CallExpression extends Expression {
  final Expression callee;
  final List<Expression> arguments;

  CallExpression({
    required this.callee,
    required this.arguments,
  }) : super(location: callee.location);

  factory CallExpression.fromIf({
    required Token operator,
    required Expression condition,
    required Expression ifTrue,
    required Expression ifFalse,
  }) =>
      CallExpression(
        callee: IdentifierExpression(operator),
        arguments: [condition, ifTrue, ifFalse],
      );

  factory CallExpression.fromUnaryOperation({
    required Token operator,
    required Expression expression,
  }) =>
      CallExpression(
        callee: IdentifierExpression(operator),
        arguments: [expression],
      );

  factory CallExpression.fromBinaryOperation({
    required Token operator,
    required Expression left,
    required Expression right,
  }) =>
      CallExpression(
        callee: IdentifierExpression(operator),
        arguments: [left, right],
      );

  @override
  String toString() => '$callee(${arguments.join(', ')})';

  @override
  Node toNode() => CallNode(
        callee: callee.toNode(),
        arguments: arguments.map((e) => e.toNode()).toList(),
      );
}
