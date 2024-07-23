import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/models/reducible.dart';
import 'package:dry/compiler/models/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

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
  Reducible evaluate(Scope scope) {
    final Reducible x = scope.get('x').evaluate(scope.asGlobal);
    final Reducible y = scope.get('y').evaluate(scope.asGlobal);

    if ((x is NumberReducibleValue) && (y is NumberReducibleValue)) {
      return BooleanReducibleValue(x.value == y.value);
    } else if ((x is StringReducibleValue) && (y is StringReducibleValue)) {
      return BooleanReducibleValue(x.value == y.value);
    } else if ((x is BooleanReducibleValue) && (y is BooleanReducibleValue)) {
      return BooleanReducibleValue(x.value == y.value);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameters.map((e) => e.type.toString()).toList(),
        actual: [x.type, y.type],
      );
    }
  }
}
