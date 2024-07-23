import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/models/reducible.dart';
import 'package:dry/compiler/models/scope.dart';
import 'package:dry/compiler/models/type.dart';
import 'package:dry/compiler/models/value.dart';
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
  Reducible evaluate(List<Reducible> arguments, Scope scope) {
    if (arguments.length != parameters.length) {
      throw InvalidArgumentLengthError(
        function: name,
        expected: parameters.length,
        actual: arguments.length,
      );
    } else {
      final Reducible x = arguments[0];
      final Reducible y = arguments[1];

      if ((x is NumberValue) && (y is NumberValue)) {
        return BooleanValue(x.value > y.value);
      } else {
        throw InvalidArgumentTypesError(
          function: name,
          expected:
              parameters.map((e) => e.type.runtimeType.toString()).toList(),
          actual: arguments.map((e) => e.type).toList(),
        );
      }
    }
  }
}
