import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class NumClamp extends NativeFunctionPrototype {
  NumClamp()
      : super(
          name: 'num.clamp',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
            Parameter.number('c'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').reduce();
    final Node b = arguments.get('b').reduce();
    final Node c = arguments.get('c').reduce();

    if ((a is NumberNode) && (b is NumberNode) && (c is NumberNode)) {
      return NumberNode(a.value.clamp(b.value, c.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
