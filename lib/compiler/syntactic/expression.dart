class Expression {
  final ExpressionType type;

  const Expression({
    required this.type,
  });

  String get body => '';

  @override
  String toString() => '{type: $type, body: $body}';
}

class LiteralExpression<T> extends Expression {
  final T value;

  const LiteralExpression._({
    required super.type,
    required this.value,
  });

  static LiteralExpression<String> string(String value) => LiteralExpression._(
        type: ExpressionType.literalString,
        value: value,
      );

  static LiteralExpression<num> number(num value) => LiteralExpression._(
        type: ExpressionType.literalNumber,
        value: value,
      );

  static LiteralExpression<bool> boolean(bool value) => LiteralExpression._(
        type: ExpressionType.literalBoolean,
        value: value,
      );

  static LiteralExpression<String> symbol(String value) => LiteralExpression._(
        type: ExpressionType.literalSymbol,
        value: value,
      );

  @override
  String get body => value.toString();
}

class FunctionCallExpression extends Expression {
  final String name;
  final List<Expression> arguments;

  const FunctionCallExpression({
    required this.name,
    required this.arguments,
  }) : super(type: ExpressionType.functionCall);

  @override
  String get body => arguments.join(',');
}

enum ExpressionType {
  literalString,
  literalNumber,
  literalBoolean,
  literalSymbol,
  functionCall,
}
