import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class Tail extends NativeFunctionPrototype {
  Tail()
      : super(
          name: 'str.tail',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();

    if (a is StringReducibleValue) {
      return StringReducibleValue(a.value.isNotEmpty ? a.value.substring(1) : '');
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
