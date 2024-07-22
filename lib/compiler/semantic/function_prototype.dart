import 'package:dry/compiler/syntactic/expression.dart';

class FunctionPrototype {
  final String name;
  final List<String> parameters;
  final Expression expression;

  const FunctionPrototype({
    required this.name,
    required this.parameters,
    required this.expression,
  });

  bool equalSignature(FunctionPrototype function) =>
      function.name == name && function.parameters.length == parameters.length;
}
