import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/models/scope.dart';
import 'package:dry/compiler/models/value.dart';
import 'package:dry/compiler/syntactic/expression.dart';

abstract class FunctionPrototype {
  final String name;
  final List<Parameter> parameters;

  const FunctionPrototype({
    required this.name,
    required this.parameters,
  });

  Value evaluate(List<Value> arguments, Scope scope);

  bool equalSignature(FunctionPrototype function) =>
      function.name == name && function.parameters.length == parameters.length;
}

class AnonymousFunctionPrototype extends CustomFunctionPrototype {
  const AnonymousFunctionPrototype({
    required super.expression,
  }) : super(name: '', parameters: const []);

  @override
  Value evaluate(List<Value> arguments, Scope scope) =>
      const NumberValue(0); // TODO(momo): implement
}

class CustomFunctionPrototype extends FunctionPrototype {
  final Expression expression;

  const CustomFunctionPrototype({
    required super.name,
    required super.parameters,
    required this.expression,
  });

  @override
  Value evaluate(List<Value> arguments, Scope scope) =>
      const NumberValue(0); // TODO(momo): implement
}

abstract class NativeFunctionPrototype extends FunctionPrototype {
  const NativeFunctionPrototype({
    required super.name,
    required super.parameters,
  });
}
