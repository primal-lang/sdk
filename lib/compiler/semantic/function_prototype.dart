import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/node.dart';

// TODO(momo): remove and use FunctionNode instead
abstract class FunctionPrototype {
  final String name;
  final List<Parameter> parameters;

  const FunctionPrototype({
    required this.name,
    required this.parameters,
  });

  FunctionNode toNode();

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

  @override
  FunctionNode toNode() => CustomFunctionNode(
        name: name,
        parameters: parameters,
        body: node,
      );
}

abstract class NativeFunctionPrototype extends FunctionPrototype {
  const NativeFunctionPrototype({
    required super.name,
    required super.parameters,
  });
}
