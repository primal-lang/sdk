/*import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListRemove extends NativeFunctionPrototype {
  ListRemove()
      : super(
          name: 'list.remove',
          parameters: [
            Parameter.list('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();
    final Node b = arguments.get('b').evaluate();

    if (a is ListNode) {
      final CompEq eq = CompEq();
      final List<Node> result = [];

      for (final Node element in a.value) {
        final Node elementReduced = element.evaluate();
        final Node comparison = eq.compare(elementReduced, b);

        if (comparison is BooleanNode && !comparison.value) {
          result.add(elementReduced);
        }
      }

      return ListNode(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
*/