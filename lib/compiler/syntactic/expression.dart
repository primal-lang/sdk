import 'package:dry/compiler/input/location.dart';
import 'package:dry/compiler/lexical/token.dart';

abstract class Expression extends Localized {
  const Expression({required super.location});
}

class EmptyExpression extends Expression {
  const EmptyExpression() : super(location: const Location(row: 1, column: 1));
}

class LiteralExpression<T> extends Expression {
  final T value;

  const LiteralExpression({
    required super.location,
    required this.value,
  });
}

class StringExpression extends LiteralExpression<String> {
  StringExpression(Token token)
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

class BooleanExpression extends LiteralExpression<bool> {
  BooleanExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );
}

class SymbolExpression extends Expression {
  final String value;

  SymbolExpression(Token token)
      : value = token.value,
        super(location: token.location);
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
