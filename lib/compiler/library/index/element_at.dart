import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ElementAt extends NativeFunctionPrototype {
  ElementAt()
      : super(
          name: 'element.at',
          parameters: [
            Parameter.any('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();
    final Node b = arguments.get('b').evaluate();

    if ((a is ListNode) && (b is NumberNode)) {
      return a.value[b.value.toInt()];
    } else if ((a is StringNode) && (b is NumberNode)) {
      return StringNode(a.value[b.value.toInt()]);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
