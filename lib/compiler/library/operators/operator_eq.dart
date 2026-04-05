import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class OperatorEq extends NativeFunctionNode {
  const OperatorEq()
    : super(
        name: '==',
        parameters: const [
          Parameter.any('a'),
          Parameter.any('b'),
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
  Node reduce() {
    final Node a = arguments[0].reduce();
    final Node b = arguments[1].reduce();

    return CompEq.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
