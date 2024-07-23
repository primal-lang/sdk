import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/models/reducible.dart';
import 'package:dry/compiler/models/scope.dart';

abstract class FunctionPrototype implements Reducible {
  final String name;
  final List<Parameter> parameters;

  const FunctionPrototype({
    required this.name,
    required this.parameters,
  });

  @override
  Reducible evaluate(Scope scope);

  bool equalSignature(FunctionPrototype function) =>
      function.name == name && function.parameters.length == parameters.length;

  @override
  String get type => '$name(${parameters.join(', ')})';
}

class CustomFunctionPrototype extends FunctionPrototype {
  final Reducible reducible;

  const CustomFunctionPrototype({
    required super.name,
    required super.parameters,
    required this.reducible,
  });

  @override
  Reducible evaluate(Scope scope) => reducible.evaluate(scope);
}

class AnonymousFunctionPrototype extends CustomFunctionPrototype {
  const AnonymousFunctionPrototype({
    required super.reducible,
  }) : super(name: '', parameters: const []);
}

abstract class NativeFunctionPrototype extends FunctionPrototype {
  const NativeFunctionPrototype({
    required super.name,
    required super.parameters,
  });
}
