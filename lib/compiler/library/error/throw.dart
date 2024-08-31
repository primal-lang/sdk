import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
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
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();
    final Reducible b = arguments.get('b').reduce();

    throw CustomError(a, b.toString());
  }
}

class CustomError extends RuntimeError {
  final Reducible code;

  const CustomError(this.code, super.message);
}
