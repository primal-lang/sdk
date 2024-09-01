import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ToBoolean extends NativeFunctionPrototype {
  ToBoolean()
      : super(
          name: 'to.boolean',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').reduce();

    if (a is StringNode) {
      return BooleanNode(a.value.trim().isNotEmpty);
    } else if (a is NumberNode) {
      return BooleanNode(a.value != 0);
    } else if (a is BooleanNode) {
      return BooleanNode(a.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
