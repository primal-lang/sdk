import 'package:primal/compiler/syntactic/expression.dart';

/// Used during parsing to incrementally build a function definition.
class FunctionDefinitionBuilder {
  final String name;
  final List<String> parameters;

  const FunctionDefinitionBuilder({
    required this.name,
    this.parameters = const [],
  });

  FunctionDefinitionBuilder withParameter(String parameter) =>
      FunctionDefinitionBuilder(
        name: name,
        parameters: [...parameters, parameter],
      );

  FunctionDefinition build(Expression expression) => FunctionDefinition(
    name: name,
    parameters: parameters,
    expression: expression,
  );
}

/// A complete function definition with a guaranteed expression.
class FunctionDefinition {
  final String name;
  final List<String> parameters;
  final Expression expression;

  const FunctionDefinition({
    required this.name,
    required this.expression,
    this.parameters = const [],
  });
}
