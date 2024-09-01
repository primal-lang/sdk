import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListSwap extends NativeFunctionPrototype {
  ListSwap()
      : super(
          name: 'list.swap',
          parameters: [
            Parameter.list('a'),
            Parameter.number('b'),
            Parameter.number('c'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').reduce();
    final Node b = arguments.get('b').reduce();
    final Node c = arguments.get('c').reduce();

    if ((a is ListNode) && (b is NumberNode) && (c is NumberNode)) {
      final List<Node> result = [];
      final Node valueAtB = a.value[b.value.toInt()];
      final Node valueAtC = a.value[c.value.toInt()];

      for (int i = 0; i < a.value.length; i++) {
        final Node element = a.value[i];

        if (i == b.value.toInt()) {
          result.add(valueAtC);
        } else if (i == c.value.toInt()) {
          result.add(valueAtB);
        } else {
          result.add(element);
        }
      }

      return ListNode(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
