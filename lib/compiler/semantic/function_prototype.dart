import 'package:dry/compiler/models/scope.dart';
import 'package:dry/compiler/syntactic/expression.dart';

abstract class FunctionPrototype {
  final String name;
  final List<String> parameters;

  const FunctionPrototype({
    required this.name,
    required this.parameters,
  });

  String evaluate(Scope scope);

  bool equalSignature(FunctionPrototype function) =>
      function.name == name && function.parameters.length == parameters.length;
}

class AnonymousFunctionPrototype extends CustomFunctionPrototype {
  const AnonymousFunctionPrototype({
    required super.expression,
  }) : super(name: '', parameters: const []);

  @override
  String evaluate(Scope scope) => '';
}

class CustomFunctionPrototype extends FunctionPrototype {
  final Expression expression;

  const CustomFunctionPrototype({
    required super.name,
    required super.parameters,
    required this.expression,
  });

  @override
  String evaluate(Scope scope) => '';
}

class NativeFunctionPrototype extends FunctionPrototype {
  const NativeFunctionPrototype({
    required super.name,
    required super.parameters,
  });

  @override
  String evaluate(Scope scope) => '';
}
