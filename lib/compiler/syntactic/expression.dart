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
  String toString() => body;
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

  static LiteralExpression<String> symbol(Token token) => LiteralExpression._(
        type: ExpressionType.literalSymbol,
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

enum ExpressionType {
  literalString,
  literalNumber,
  literalBoolean,
  literalSymbol,
  functionCall,
}
