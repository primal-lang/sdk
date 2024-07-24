import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/models/reducible.dart';
import 'package:dry/compiler/models/scope.dart';

abstract class FunctionPrototype {
  final String name;
  final List<Parameter> parameters;

  const FunctionPrototype({
    required this.name,
    required this.parameters,
  });

  Reducible bind(Scope<Reducible> arguments);

  bool equalSignature(FunctionPrototype function) =>
      function.name == name && function.parameters.length == parameters.length;
}

class CustomFunctionPrototype extends FunctionPrototype {
  final Reducible reducible;

  const CustomFunctionPrototype({
    required super.name,
    required super.parameters,
    required this.reducible,
  });

  @override
  Reducible bind(Scope<Reducible> arguments) => reducible.bind(arguments);
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
