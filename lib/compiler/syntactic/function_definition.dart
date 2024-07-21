import 'package:dry/compiler/syntactic/expression.dart';

class FunctionDefinition {
  final String name;
  final List<String> parameters;
  final Expression expression;

  const FunctionDefinition({
    required this.name,
    required this.parameters,
    required this.expression,
  });

  factory FunctionDefinition.withName(String name) => FunctionDefinition(
        name: name,
        parameters: [],
        expression: const EmptyExpression(),
      );

  FunctionDefinition withParameter(String parameter) => FunctionDefinition(
        name: name,
        parameters: [...parameters, parameter],
        expression: expression,
      );

  FunctionDefinition withExpression(Expression expression) =>
      FunctionDefinition(
        name: name,
        parameters: parameters,
        expression: expression,
      );
}
