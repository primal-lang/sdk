import 'dart:math';
import 'package:purified/compiler/errors/runtime_error.dart';
import 'package:purified/compiler/models/parameter.dart';
import 'package:purified/compiler/runtime/reducible.dart';
import 'package:purified/compiler/runtime/scope.dart';
import 'package:purified/compiler/semantic/function_prototype.dart';

class Cos extends NativeFunctionPrototype {
  Cos()
      : super(
          name: 'cos',
          parameters: [
            Parameter.number('x'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').reduce();

    if (x is NumberReducibleValue) {
      return NumberReducibleValue(cos(x.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [x.type],
      );
    }
  }
}
