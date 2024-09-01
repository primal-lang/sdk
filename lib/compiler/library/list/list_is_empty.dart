import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListIsEmpty extends NativeFunctionPrototype {
  ListIsEmpty()
      : super(
          name: 'list.isEmpty',
          parameters: [
            Parameter.list('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();

    if (a is ListNode) {
      return BooleanNode(a.value.isEmpty);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
