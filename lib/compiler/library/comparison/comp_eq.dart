import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class CompEq extends NativeFunctionPrototype {
  CompEq()
      : super(
          name: 'comp.eq',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();
    final Reducible b = arguments.get('b').reduce();

    return compare(a, b);
  }

  Reducible compare(Reducible a, Reducible b) {
    if ((a is NumberReducibleValue) && (b is NumberReducibleValue)) {
      return BooleanReducibleValue(a.value == b.value);
    } else if ((a is StringReducibleValue) && (b is StringReducibleValue)) {
      return BooleanReducibleValue(a.value == b.value);
    } else if ((a is BooleanReducibleValue) && (b is BooleanReducibleValue)) {
      return BooleanReducibleValue(a.value == b.value);
    } else if ((a is ListReducibleValue) && (b is ListReducibleValue)) {
      if (a.value.length != b.value.length) {
        return const BooleanReducibleValue(false);
      } else {
        for (int i = 0; i < a.value.length; i++) {
          final Reducible comparison = compare(
            a.value[i].reduce(),
            b.value[i].reduce(),
          );

          if (comparison is BooleanReducibleValue && !comparison.value) {
            return const BooleanReducibleValue(false);
          }
        }

        return const BooleanReducibleValue(true);
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
