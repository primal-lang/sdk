/*import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListInsertEnd extends NativeFunctionPrototype {
  ListInsertEnd()
      : super(
          name: 'list.insertEnd',
          parameters: [
            Parameter.list('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a');
    final Node b = arguments.get('b');

    if (a is ListNode) {
      return ListNode([...a.value, b]);
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