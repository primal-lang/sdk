import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/runtime/reducible.dart';

abstract class Expression extends Localized {
  const Expression({required super.location});

  Reducible toReducible();
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

class BooleanLiteralExpression extends LiteralExpression<bool> {
  BooleanLiteralExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  Reducible toReducible() => BooleanReducibleValue(value);
}

class NumberLiteralExpression extends LiteralExpression<num> {
  NumberLiteralExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  Reducible toReducible() => NumberReducibleValue(value);
}

class StringLiteralExpression extends LiteralExpression<String> {
  StringLiteralExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  String toString() => '"$value"';

  @override
  Reducible toReducible() => StringReducibleValue(value);
}

class ListLiteralExpression extends LiteralExpression<List<Expression>> {
  final List<Expression> arguments;

  ListLiteralExpression({
    required Location location,
    required this.arguments,
  }) : super(
          location: location,
          value: arguments,
        );

  @override
  String toString() => value.toString();

  @override
  Reducible toReducible() =>
      ListReducibleValue(value.map((e) => e.toReducible()).toList());
}

class IdentifierExpression extends Expression {
  final String value;

  IdentifierExpression(Token token)
      : value = token.value,
        super(location: token.location);

  @override
  String toString() => value;

  @override
  Reducible toReducible() => IdentifierReducible(
        value: value,
        location: location,
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

  String get name => callee.toString();

  @override
  String toString() => '$name(${arguments.join(', ')})';

  @override
  Reducible toReducible() => ExpressionReducible(
        name: name,
        arguments: arguments.map((e) => e.toReducible()).toList(),
        location: location,
      );
}
