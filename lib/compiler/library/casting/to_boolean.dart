import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class ToBoolean extends NativeFunctionPrototype {
  ToBoolean()
      : super(
          name: 'toBoolean',
          parameters: [
            Parameter.any('x'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').evaluate();

    if (x is StringReducibleValue) {
      return BooleanReducibleValue(x.value.trim().isNotEmpty);
    } else if (x is NumberReducibleValue) {
      return BooleanReducibleValue(x.value != 0);
    } else if (x is BooleanReducibleValue) {
      return BooleanReducibleValue(x.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [x.type],
      );
    }
  }
}
