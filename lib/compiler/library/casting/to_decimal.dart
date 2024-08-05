import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ToDecimal extends NativeFunctionPrototype {
  ToDecimal()
      : super(
          name: 'toDecimal',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();

    if (a is StringReducibleValue) {
      return NumberReducibleValue(double.parse(a.value));
    } else if (a is NumberReducibleValue) {
      return NumberReducibleValue(a.value.toDouble());
    } else if (a is BooleanReducibleValue) {
      return NumberReducibleValue(a.value ? 1 : 0);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
