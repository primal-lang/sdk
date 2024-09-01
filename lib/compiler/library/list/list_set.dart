import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListSet extends NativeFunctionPrototype {
  ListSet()
      : super(
          name: 'list.set',
          parameters: [
            Parameter.list('a'),
            Parameter.number('b'),
            Parameter.any('c'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a');
    final Node b = arguments.get('b').reduce();
    final Node c = arguments.get('c');

    if ((a is ListNode) && (b is NumberNode)) {
      final List<Node> head = a.value.sublist(0, b.value.toInt());
      final List<Node> tail = a.value.sublist(b.value.toInt(), a.value.length);

      return ListNode([...head, c, ...tail]);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
