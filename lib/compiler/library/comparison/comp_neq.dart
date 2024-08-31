import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class CompNeq extends NativeFunctionPrototype {
  CompNeq()
      : super(
          name: 'comp.neq',
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
      return BooleanReducibleValue(a.value != b.value);
    } else if ((a is StringReducibleValue) && (b is StringReducibleValue)) {
      return BooleanReducibleValue(a.value != b.value);
    } else if ((a is BooleanReducibleValue) && (b is BooleanReducibleValue)) {
      return BooleanReducibleValue(a.value != b.value);
    } else if ((a is ListReducibleValue) && (b is ListReducibleValue)) {
      final Reducible comparison = CompEq().compare(a, b);

      return comparison is BooleanReducibleValue
          ? BooleanReducibleValue(!comparison.value)
          : comparison;
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
