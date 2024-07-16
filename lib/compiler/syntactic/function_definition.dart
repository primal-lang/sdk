import 'package:dry/compiler/syntactic/expression.dart';

class FunctionDefinition {
  final String name;
  final List<String> parameters;
  final Expression expression;

  const FunctionDefinition._({
    required this.name,
    required this.parameters,
    required this.expression,
  });

  FunctionDefinition withExpression(Expression expression) => FunctionDefinition._(
        name: name,
        parameters: parameters,
        expression: expression,
      );

  factory FunctionDefinition.fromName(String name) => FunctionDefinition._(
        name: name,
        parameters: [],
        expression: Expression.empty(),
      );
}
