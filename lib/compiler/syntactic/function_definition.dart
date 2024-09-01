import 'package:primal/compiler/syntactic/expression.dart';

class FunctionDefinition {
  final String name;
  final List<String> parameters;
  final Expression expression;

  const FunctionDefinition({
    required this.name,
    this.parameters = const [],
    this.expression = const EmptyExpression(),
  });

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
