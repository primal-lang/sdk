import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/lexical/token.dart';
import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/runtime/reducible.dart';

abstract class Expression extends Localized {
  const Expression({required super.location});

  Reducible toReducible();
}

class EmptyExpression extends Expression {
  const EmptyExpression() : super(location: const Location(row: 1, column: 1));

  @override
  Reducible toReducible() => throw const EmptyExpressionEvaluationError();
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

class StringExpression extends LiteralExpression<String> {
  StringExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  String toString() => '"$value"';

  @override
  Reducible toReducible() => StringReducibleValue(value);
}

class NumberExpression extends LiteralExpression<num> {
  NumberExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  Reducible toReducible() => NumberReducibleValue(value);
}

class BooleanExpression extends LiteralExpression<bool> {
  BooleanExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  Reducible toReducible() => BooleanReducibleValue(value);
}

class IdentifierExpression extends Expression {
  final String value;

  IdentifierExpression(Token token)
      : value = token.value,
        super(location: token.location);

  @override
  String toString() => value.toString();

  @override
  Reducible toReducible() => IdentifierReducible(
        value: value,
        location: location,
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

  @override
  String toString() => '$name(${arguments.join(', ')})';

  @override
  Reducible toReducible() => ExpressionReducible(
        name: name,
        arguments: arguments.map((e) => e.toReducible()).toList(),
        location: location,
      );
}
