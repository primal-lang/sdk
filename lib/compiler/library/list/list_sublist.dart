/*import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListSublist extends NativeFunctionPrototype {
  ListSublist()
      : super(
          name: 'list.sublist',
          parameters: [
            Parameter.list('a'),
            Parameter.number('b'),
            Parameter.number('c'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();
    final Node b = arguments.get('b').evaluate();
    final Node c = arguments.get('c').evaluate();

    if ((a is ListNode) && (b is NumberNode) && (c is NumberNode)) {
      return ListNode(
        a.value.sublist(b.value.toInt(), c.value.toInt()),
      );
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
*/