import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListRemoveAt extends NativeFunctionPrototype {
  ListRemoveAt()
      : super(
          name: 'list.removeAt',
          parameters: [
            Parameter.list('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();
    final Node b = arguments.get('b').evaluate();

    if ((a is ListNode) && (b is NumberNode)) {
      return ListNode(a.value.sublist(0, b.value.toInt()) +
          a.value.sublist(b.value.toInt() + 1));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
