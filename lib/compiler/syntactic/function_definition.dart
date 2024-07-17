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
}
