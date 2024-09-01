import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListContains extends NativeFunctionPrototype {
  ListContains()
      : super(
          name: 'list.contains',
          parameters: [
            Parameter.list('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').reduce();
    final Node b = arguments.get('b').reduce();

    if (a is ListNode) {
      final CompEq eq = CompEq();

      for (final Node element in a.value) {
        final Node comparison = eq.compare(element.reduce(), b);

        if (comparison is BooleanNode && comparison.value) {
          return const BooleanNode(true);
        }
      }

      return const BooleanNode(false);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
