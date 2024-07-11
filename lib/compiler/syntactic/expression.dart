class Expression {
  final ExpressionType type;

  const Expression({
    required this.type,
  });
}

class LiteralExpression<T> extends Expression {
  final T value;

  const LiteralExpression({
    required super.type,
    required this.value,
  });

  static LiteralExpression<String> string(String value) => LiteralExpression(
        type: ExpressionType.literalString,
        value: value,
      );

  static LiteralExpression<num> number(num value) => LiteralExpression(
        type: ExpressionType.literalNumber,
        value: value,
      );

  static LiteralExpression<bool> boolean(bool value) => LiteralExpression(
        type: ExpressionType.literalBoolean,
        value: value,
      );

  static LiteralExpression<String> symbol(String value) => LiteralExpression(
        type: ExpressionType.literalSymbol,
        value: value,
      );
}

class FunctionCallExpression extends Expression {
  final String name;
  final List<Expression> arguments;

  const FunctionCallExpression({
    required this.name,
    required this.arguments,
  }) : super(type: ExpressionType.functionCall);
}

enum ExpressionType {
  literalString,
  literalNumber,
  literalBoolean,
  literalSymbol,
  functionCall,
}
