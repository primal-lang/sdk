import 'package:dry/compiler/syntactic/expression.dart';

class FunctionPrototype {
  final String name;
  final List<String> parameters;

  const FunctionPrototype({
    required this.name,
    required this.parameters,
  });

  bool equalSignature(FunctionPrototype function) =>
      function.name == name && function.parameters.length == parameters.length;
}

class CustomFunctionPrototype extends FunctionPrototype {
  final Expression expression;

  const CustomFunctionPrototype({
    required super.name,
    required super.parameters,
    required this.expression,
  });
}

class NativeFunctionPrototype extends FunctionPrototype {
  const NativeFunctionPrototype({
    required super.name,
    required super.parameters,
  });
}
