import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';

abstract class FunctionPrototype {
  final String name;
  final List<Parameter> parameters;

  const FunctionPrototype({
    required this.name,
    required this.parameters,
  });

  FunctionNode toNode();

  Node substitute(Scope<Node> arguments);

  List<Type> get parameterTypes => parameters.map((e) => e.type).toList();

  bool equalSignature(FunctionPrototype function) => function.name == name;
}

class CustomFunctionPrototype extends FunctionPrototype {
  final Node node;

  const CustomFunctionPrototype({
    required super.name,
    required super.parameters,
    required this.node,
  });

  CustomFunctionPrototype withNode(Node node) => CustomFunctionPrototype(
        name: name,
        parameters: parameters,
        node: node,
      );

  @override
  Node substitute(Scope<Node> arguments) => node;

  @override
  FunctionNode toNode() => FunctionNode(
        name: name,
        parameters: parameters,
        body: node,
      );
}

class AnonymousFunctionPrototype extends CustomFunctionPrototype {
  const AnonymousFunctionPrototype({
    required super.node,
  }) : super(name: '', parameters: const []);
}

abstract class NativeFunctionPrototype extends FunctionPrototype {
  const NativeFunctionPrototype({
    required super.name,
    required super.parameters,
  });

  @override
  FunctionNode toNode() => throw UnimplementedError();
}
