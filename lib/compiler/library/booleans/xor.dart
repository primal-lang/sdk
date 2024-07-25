import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class Xor extends NativeFunctionPrototype {
  Xor()
      : super(
          name: 'xor',
          parameters: [
            Parameter.boolean('x'),
            Parameter.boolean('y'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').evaluate();
    final Reducible y = arguments.get('y').evaluate();

    if ((x is BooleanReducibleValue) && (y is BooleanReducibleValue)) {
      return BooleanReducibleValue(x.value ^ y.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [x.type, y.type],
      );
    }
  }
}
