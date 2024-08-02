import 'package:purified/compiler/errors/runtime_error.dart';
import 'package:purified/compiler/models/parameter.dart';
import 'package:purified/compiler/runtime/reducible.dart';
import 'package:purified/compiler/runtime/scope.dart';
import 'package:purified/compiler/semantic/function_prototype.dart';

class Eq extends NativeFunctionPrototype {
  Eq()
      : super(
          name: 'eq',
          parameters: [
            Parameter.any('x'),
            Parameter.any('y'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible x = arguments.get('x').reduce();
    final Reducible y = arguments.get('y').reduce();

    if ((x is NumberReducibleValue) && (y is NumberReducibleValue)) {
      return BooleanReducibleValue(x.value == y.value);
    } else if ((x is StringReducibleValue) && (y is StringReducibleValue)) {
      return BooleanReducibleValue(x.value == y.value);
    } else if ((x is BooleanReducibleValue) && (y is BooleanReducibleValue)) {
      return BooleanReducibleValue(x.value == y.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [x.type, y.type],
      );
    }
  }
}
