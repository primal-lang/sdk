import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';

abstract class FunctionPrototype {
  final String name;
  final List<Parameter> parameters;

  const FunctionPrototype({
    required this.name,
    required this.parameters,
  });

  Reducible substitute(Scope<Reducible> arguments);

  List<Type> get parameterTypes => parameters.map((e) => e.type).toList();

  bool equalSignature(FunctionPrototype function) => function.name == name;
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
