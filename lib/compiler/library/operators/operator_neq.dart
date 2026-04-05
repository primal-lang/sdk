import 'package:primal/compiler/library/comparison/comp_neq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class OperatorNeq extends NativeFunctionNode {
  const OperatorNeq()
    : super(
        name: '!=',
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

    return CompNeq.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
