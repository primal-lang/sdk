import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/lexical/token.dart';

abstract class Expression {
  final ExpressionType type;
  final Location location;

  const Expression({
    required this.type,
    required this.location,
  });

  String get body;

  @override
  String toString() =>
      'Expression{type: ${type.name}, value: $body, location: $location}';
}

class EmptyExpression extends Expression {
  const EmptyExpression()
      : super(
          type: ExpressionType.empty,
          location: const Location(row: 1, column: 1),
        );

  @override
  String get body => '';
}

class LiteralExpression<T> extends Expression {
  final T value;

  const LiteralExpression._({
    required super.type,
    required super.location,
    required this.value,
  });

  static LiteralExpression<String> string(Token token) => LiteralExpression._(
        type: ExpressionType.literalString,
        value: token.asString,
        location: token.location,
      );

  static LiteralExpression<num> number(Token token) => LiteralExpression._(
        type: ExpressionType.literalNumber,
        value: token.asNumber,
        location: token.location,
      );

  static LiteralExpression<bool> boolean(Token token) => LiteralExpression._(
        type: ExpressionType.literalBoolean,
        value: token.asBoolean,
        location: token.location,
      );

  @override
  String get body => value.toString();
}

class SymbolExpression extends Expression {
  final String value;

  const SymbolExpression._({
    required super.location,
    required this.value,
  }) : super(type: ExpressionType.symbol);

  factory SymbolExpression.fromToken(Token token) => SymbolExpression._(
        value: token.asString,
        location: token.location,
      );

  @override
  String get body => value.toString();
}

class FunctionCallExpression extends Expression {
  final String name;
  final List<Expression> arguments;

  const FunctionCallExpression({
    required super.location,
    required this.name,
    required this.arguments,
  }) : super(type: ExpressionType.functionCall);

  @override
  String get body => '$name(${arguments.map((e) => e.toString()).join(', ')})';
}

// TODO(momo): remove and use casting?
enum ExpressionType {
  empty,
  literalString,
  literalNumber,
  literalBoolean,
  symbol,
  functionCall,
}
