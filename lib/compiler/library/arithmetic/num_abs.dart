import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class NumAbs extends NativeFunctionNode {
  NumAbs()
      : super(
          name: 'num.abs',
          parameters: [
            Parameter.number('a'),
          ],
        );

  @override
  Node body(List<Node> arguments) => NumAbsNode3(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class NumAbsNode3 extends FunctionNode {
  final List<Node> arguments;

  const NumAbsNode3({
    required super.name,
    required super.parameters,
    required this.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0];

    if (a is NumberNode) {
      return NumberNode(a.value.abs());
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
