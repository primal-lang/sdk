import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/lexical/token.dart';

abstract class Expression {
  final Location location;

  const Expression({required this.location});
}

class EmptyExpression extends Expression {
  const EmptyExpression() : super(location: const Location(row: 1, column: 1));
}

class LiteralExpression<T> extends Expression {
  final T value;

  const LiteralExpression._({
    required super.location,
    required this.value,
  });

  static LiteralExpression<String> string(Token token) => LiteralExpression._(
        value: token.asString,
        location: token.location,
      );

  static LiteralExpression<num> number(Token token) => LiteralExpression._(
        value: token.asNumber,
        location: token.location,
      );

  static LiteralExpression<bool> boolean(Token token) => LiteralExpression._(
        value: token.asBoolean,
        location: token.location,
      );
}

class SymbolExpression extends Expression {
  final String value;

  const SymbolExpression._({
    required super.location,
    required this.value,
  });

  factory SymbolExpression.fromToken(Token token) => SymbolExpression._(
        value: token.asString,
        location: token.location,
      );
}

class FunctionCallExpression extends Expression {
  final String name;
  final List<Expression> arguments;

  const FunctionCallExpression({
    required super.location,
    required this.name,
    required this.arguments,
  });
}
