import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorAdd extends NativeFunctionPrototype {
  OperatorAdd()
      : super(
          name: '+',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();
    final Node b = arguments.get('b').evaluate();

    if ((a is NumberNode) && (b is NumberNode)) {
      return NumberNode(a.value + b.value);
    } else if ((a is StringNode) && (b is StringNode)) {
      return StringNode(a.value + b.value);
    } else if ((a is ListNode) && (b is ListNode)) {
      return ListNode([...a.value, ...b.value]);
    } else if (a is ListNode) {
      return ListNode([...a.value, b]);
    } else if (b is ListNode) {
      return ListNode([a, ...b.value]);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
