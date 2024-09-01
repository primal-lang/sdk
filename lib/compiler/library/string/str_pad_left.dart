import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class StrPadLeft extends NativeFunctionPrototype {
  StrPadLeft()
      : super(
          name: 'str.padLeft',
          parameters: [
            Parameter.string('a'),
            Parameter.number('b'),
            Parameter.string('c'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();
    final Node b = arguments.get('b').evaluate();
    final Node c = arguments.get('c').evaluate();

    if ((a is StringNode) && (b is NumberNode) && (c is StringNode)) {
      return StringNode(a.value.padLeft(b.value.toInt(), c.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
