import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';

abstract class FunctionPrototype {
  final String name;
  final List<Parameter> parameters;

  const FunctionPrototype({
    required this.name,
    required this.parameters,
  });

  Reducible substitute(Scope<Reducible> arguments);

  List<String> get parameterTypes =>
      parameters.map((e) => e.type.toString()).toList();

  bool equalSignature(FunctionPrototype function) =>
      (function.name == name) &&
      (function.parameters.length == parameters.length);
}

class CustomFunctionPrototype extends FunctionPrototype {
  final Reducible reducible;

  const CustomFunctionPrototype({
    required super.name,
    required super.parameters,
    required this.reducible,
  });

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      reducible.substitute(arguments);
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
