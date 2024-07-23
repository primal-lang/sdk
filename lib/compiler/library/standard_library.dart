import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/models/reducible.dart';
import 'package:dry/compiler/models/scope.dart';
import 'package:dry/compiler/models/type.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class Gt extends NativeFunctionPrototype {
  const Gt()
      : super(
          name: 'gt',
          parameters: const [
            Parameter(name: 'x', type: NumberType()),
            Parameter(name: 'y', type: NumberType()),
          ],
        );

  @override
  Reducible evaluate(Scope scope) {
    final Reducible x = scope.get('x').evaluate(scope);
    final Reducible y = scope.get('y').evaluate(scope);

    if ((x is NumberReducibleValue) && (y is NumberReducibleValue)) {
      return BooleanReducibleValue(x.value > y.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameters.map((e) => e.type.runtimeType.toString()).toList(),
        actual: [x.type, y.type],
      );
    }
  }
}
