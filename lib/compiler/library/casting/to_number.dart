import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ToNumber extends NativeFunctionPrototype {
  ToNumber()
      : super(
          name: 'to.number',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();

    if (a is StringNode) {
      return NumberNode(num.parse(a.value));
    } else if (a is NumberNode) {
      return a;
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
