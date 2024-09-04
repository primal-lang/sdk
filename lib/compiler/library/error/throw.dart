import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class Throw extends NativeFunctionNode {
  Throw()
      : super(
          name: 'error.throw',
          parameters: [
            Parameter.any('a'),
            Parameter.string('b'),
          ],
        );

  @override
  Node node(List<Node> arguments) => NodeWithArguments(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class NodeWithArguments extends NativeFunctionNodeWithArguments {
  const NodeWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    throw CustomError(a, b.toString());
  }
}

class CustomError extends RuntimeError {
  final Node code;

  const CustomError(this.code, super.message);
}
