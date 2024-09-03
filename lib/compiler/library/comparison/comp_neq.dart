import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class CompNeq extends NativeFunctionPrototype {
  CompNeq()
      : super(
          name: 'comp.neq',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
          ],
        );

  @override
  FunctionNode toNode() => CompNeqNode2(
        name: name,
        parameters: parameters,
      );
}

class CompNeqNode2 extends NativeFunctionNode {
  const CompNeqNode2({
    required super.name,
    required super.parameters,
  });

  @override
  Node body(List<Node> arguments) => CompNeqNode3(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class CompNeqNode3 extends FunctionNode {
  final List<Node> arguments;

  const CompNeqNode3({
    required super.name,
    required super.parameters,
    required this.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();
    final Node b = arguments[1].evaluate();

    final Node comparison = CompEqNode3(
      name: name,
      parameters: parameters,
      arguments: arguments,
    ).compare(a, b);

    return comparison is BooleanNode
        ? BooleanNode(!comparison.value)
        : comparison;
  }
}
