import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class CompEq extends NativeFunctionPrototype {
  CompEq()
      : super(
          name: 'comp.eq',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').reduce();
    final Node b = arguments.get('b').reduce();

    return compare(a, b);
  }

  Node compare(Node a, Node b) {
    if ((a is NumberNode) && (b is NumberNode)) {
      return BooleanNode(a.value == b.value);
    } else if ((a is StringNode) && (b is StringNode)) {
      return BooleanNode(a.value == b.value);
    } else if ((a is BooleanNode) && (b is BooleanNode)) {
      return BooleanNode(a.value == b.value);
    } else if ((a is ListNode) && (b is ListNode)) {
      if (a.value.length != b.value.length) {
        return const BooleanNode(false);
      } else {
        for (int i = 0; i < a.value.length; i++) {
          final Node comparison = compare(
            a.value[i].reduce(),
            b.value[i].reduce(),
          );

          if (comparison is BooleanNode && !comparison.value) {
            return const BooleanNode(false);
          }
        }

        return const BooleanNode(true);
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
