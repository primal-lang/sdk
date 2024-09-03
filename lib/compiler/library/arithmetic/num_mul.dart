import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class NumMul extends NativeFunctionPrototype {
  NumMul()
      : super(
          name: 'num.mul',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  FunctionNode toNode() => NumMulNode2(
        name: name,
        parameters: parameters,
      );
}

class NumMulNode2 extends NativeFunctionNode {
  const NumMulNode2({
    required super.name,
    required super.parameters,
  });

  @override
  Node body(List<Node> arguments) => NumMulNode3(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class NumMulNode3 extends FunctionNode {
  final List<Node> arguments;

  const NumMulNode3({
    required super.name,
    required super.parameters,
    required this.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    if ((a is NumberNode) && (b is NumberNode)) {
      return NumberNode(a.value * b.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
