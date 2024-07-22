import 'package:dry/compiler/syntactic/expression.dart';

class FunctionPrototype {
  final String name;
  final List<String> parameters;
  final Expression expression;
  final bool isNative;

  const FunctionPrototype({
    required this.name,
    required this.parameters,
    required this.expression,
    required this.isNative,
  });

  bool equalSignature(FunctionPrototype function) =>
      function.name == name && function.parameters.length == parameters.length;
}
