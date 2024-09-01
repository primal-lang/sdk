import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListIndexOf extends NativeFunctionPrototype {
  ListIndexOf()
      : super(
          name: 'list.indexOf',
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

      for (int i = 0; i < a.value.length; i++) {
        final Node comparison = eq.compare(a.value[i].evaluate(), b);

        if (comparison is BooleanNode && comparison.value) {
          return NumberNode(i);
        }
      }

      return const NumberNode(-1);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
