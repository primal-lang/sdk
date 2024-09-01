import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorNeq extends NativeFunctionPrototype {
  OperatorNeq()
      : super(
          name: '!=',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').reduce();
    final Node b = arguments.get('b').reduce();
    final Node comparison = CompEq().compare(a, b);

    return comparison is BooleanNode
        ? BooleanNode(!comparison.value)
        : comparison;
  }
}
