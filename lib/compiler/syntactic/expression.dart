import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';

abstract class Expression extends Located {
  const Expression({required super.location});
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
}

class NumberExpression extends LiteralExpression<num> {
  NumberExpression(Token token)
    : super(
        location: token.location,
        value: token.value,
      );
}

class StringExpression extends LiteralExpression<String> {
  StringExpression(Token token)
    : super(
        location: token.location,
        value: token.value,
      );

  @override
  String toString() => '"$value"';
}

class ListExpression extends LiteralExpression<List<Expression>> {
  const ListExpression({
    required super.location,
    required super.value,
  });
}

class MapEntryExpression extends Located {
  final Expression key;
  final Expression value;

  const MapEntryExpression({
    required super.location,
    required this.key,
    required this.value,
  });
}

class MapExpression extends LiteralExpression<List<MapEntryExpression>> {
  const MapExpression({
    required super.location,
    required super.value,
  });

  @override
  String toString() {
    final entries = value.map((e) => '${e.key}: ${e.value}').join(', ');
    return '{$entries}';
  }
}

class IdentifierExpression extends LiteralExpression<String> {
  IdentifierExpression(Token token)
    : super(
        location: token.location,
        value: token.value,
      );
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
  }) => CallExpression(
    callee: IdentifierExpression(operator),
    arguments: [condition, ifTrue, ifFalse],
  );

  factory CallExpression.fromUnaryOperation({
    required Token operator,
    required Expression expression,
  }) => CallExpression(
    callee: IdentifierExpression(operator),
    arguments: [expression],
  );

  factory CallExpression.fromBinaryOperation({
    required Token operator,
    required Expression left,
    required Expression right,
  }) => CallExpression(
    callee: IdentifierExpression(operator),
    arguments: [left, right],
  );

  @override
  String toString() => '$callee(${arguments.join(', ')})';
}
