import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class CompNeq extends NativeFunctionNode {
  const CompNeq()
    : super(
        name: 'comp.neq',
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

  static Node execute({
    required FunctionNode function,
    required Node a,
    required Node b,
  }) {
    final BooleanNode comparison = CompEq.execute(
      function: function,
      a: a,
      b: b,
    );

    return BooleanNode(!comparison.value);
  }
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
