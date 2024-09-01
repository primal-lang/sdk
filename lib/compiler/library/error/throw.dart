import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class Throw extends NativeFunctionPrototype {
  Throw()
      : super(
          name: 'error.throw',
          parameters: [
            Parameter.any('a'),
            Parameter.string('b'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').reduce();
    final Node b = arguments.get('b').reduce();

    throw CustomError(a, b.toString());
  }
}

class CustomError extends RuntimeError {
  final Node code;

  const CustomError(this.code, super.message);
}
