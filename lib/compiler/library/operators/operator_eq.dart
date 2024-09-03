import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorEq extends NativeFunctionPrototype {
  OperatorEq()
      : super(
          name: '==',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
          ],
        );

  @override
  FunctionNode toNode() => OperatorEqNode2(
        name: name,
        parameters: parameters,
      );
}

class OperatorEqNode2 extends NativeFunctionNode {
  const OperatorEqNode2({
    required super.name,
    required super.parameters,
  });

  @override
  Node body(List<Node> arguments) => OperatorEqNode3(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class OperatorEqNode3 extends FunctionNode {
  final List<Node> arguments;

  const OperatorEqNode3({
    required super.name,
    required super.parameters,
    required this.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    return CompEqNode3(
      name: name,
      parameters: parameters,
      arguments: arguments,
    ).compare(a, b);
  }
}
