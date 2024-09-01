import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class StrReplace extends NativeFunctionPrototype {
  StrReplace()
      : super(
          name: 'str.replace',
          parameters: [
            Parameter.string('a'),
            Parameter.string('b'),
            Parameter.string('c'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();
    final Node b = arguments.get('b').evaluate();
    final Node c = arguments.get('c').evaluate();

    if ((a is StringNode) && (b is StringNode) && (c is StringNode)) {
      return StringNode(a.value.replaceAll(b.value, c.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
