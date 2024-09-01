import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class StrSubstring extends NativeFunctionPrototype {
  StrSubstring()
      : super(
          name: 'str.substring',
          parameters: [
            Parameter.string('a'),
            Parameter.number('b'),
            Parameter.number('c'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();
    final Node b = arguments.get('b').evaluate();
    final Node c = arguments.get('c').evaluate();

    if ((a is StringNode) && (b is NumberNode) && (c is NumberNode)) {
      return StringNode(a.value.substring(b.value.toInt(), c.value.toInt()));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
