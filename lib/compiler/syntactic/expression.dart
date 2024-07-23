import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/lexical/token.dart';
import 'package:dry/compiler/models/location.dart';
import 'package:dry/compiler/models/scope.dart';
import 'package:dry/compiler/models/value.dart';

abstract class Expression extends Localized {
  const Expression({required super.location});

  Value evaluate(List<Value> arguments, Scope scope);
}

class EmptyExpression extends Expression {
  const EmptyExpression() : super(location: const Location(row: 1, column: 1));

  @override
  Value evaluate(List<Value> arguments, Scope scope) =>
      throw const EmptyExpressionEvaluationError();
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
  Value evaluate(List<Value> arguments, Scope scope) => StringValue(value);
}

class NumberExpression extends LiteralExpression<num> {
  NumberExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  Value evaluate(List<Value> arguments, Scope scope) => NumberValue(value);
}

class BooleanExpression extends LiteralExpression<bool> {
  BooleanExpression(Token token)
      : super(
          location: token.location,
          value: token.value,
        );

  @override
  Value evaluate(List<Value> arguments, Scope scope) => BooleanValue(value);
}

class SymbolExpression extends Expression {
  final String value;

  SymbolExpression(Token token)
      : value = token.value,
        super(location: token.location);

  @override
  String toString() => value.toString();

  @override
  Value evaluate(List<Value> arguments, Scope scope) =>
      throw Error(); // TODO(momo): implement
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
  Value evaluate(List<Value> arguments, Scope scope) =>
      throw Error(); // TODO(momo): implement
}
