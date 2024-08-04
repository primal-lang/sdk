import 'dart:math';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class Min extends NativeFunctionPrototype {
  Min()
      : super(
          name: 'min',
          parameters: [
            Parameter.number('x'),
            Parameter.number('y'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').reduce();
    final Reducible y = arguments.get('y').reduce();

    if ((x is NumberReducibleValue) && (y is NumberReducibleValue)) {
      return NumberReducibleValue(min(x.value, y.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [x.type, y.type],
      );
    }
  }
}
