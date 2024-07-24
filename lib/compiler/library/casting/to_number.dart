import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class ToNumber extends NativeFunctionPrototype {
  ToNumber()
      : super(
          name: 'toNumber',
          parameters: [
            Parameter.any('x'),
          ],
        );

  @override
  Reducible bind(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').evaluate();

    if (x is StringReducibleValue) {
      return NumberReducibleValue(num.parse(x.value));
    } else if (x is NumberReducibleValue) {
      return x;
    } else if (x is BooleanReducibleValue) {
      return NumberReducibleValue(x.value ? 1 : 0);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [x.type],
      );
    }
  }
}
