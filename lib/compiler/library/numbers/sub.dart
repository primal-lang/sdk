import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/models/reducible.dart';
import 'package:dry/compiler/models/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class Sub extends NativeFunctionPrototype {
  Sub()
      : super(
          name: 'sub',
          parameters: [
            Parameter.number('x'),
            Parameter.number('y'),
          ],
        );

  @override
  Reducible evaluate(Scope arguments, Scope scope) {
    final Reducible x = arguments.get('x').evaluate(const Scope(), scope);
    final Reducible y = arguments.get('y').evaluate(const Scope(), scope);

    if ((x is NumberReducibleValue) && (y is NumberReducibleValue)) {
      return NumberReducibleValue(x.value - y.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameters.map((e) => e.type.toString()).toList(),
        actual: [x.type, y.type],
      );
    }
  }
}
