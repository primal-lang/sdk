import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class StrTake extends NativeFunctionPrototype {
  StrTake()
      : super(
          name: 'str.take',
          parameters: [
            Parameter.string('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();
    final Node b = arguments.get('b').evaluate();

    if ((a is StringNode) && (b is NumberNode)) {
      return StringNode(a.value.substring(0, b.value.toInt()));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
