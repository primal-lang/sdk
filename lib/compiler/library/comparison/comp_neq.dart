import 'package:primal/compiler/library/comparison/comp_eq.dart' as eq;
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class CompNeq extends NativeFunctionNode {
  CompNeq()
      : super(
          name: 'comp.neq',
          parameters: [
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
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    final Node comparison = eq.NodeWithArguments(
      name: name,
      parameters: parameters,
      arguments: arguments,
    ).compare(a, b);

    return comparison is BooleanNode
        ? BooleanNode(!comparison.value)
        : comparison;
  }
}
