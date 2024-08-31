import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListRemove extends NativeFunctionPrototype {
  ListRemove()
      : super(
          name: 'list.remove',
          parameters: [
            Parameter.list('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();
    final Reducible b = arguments.get('b').reduce();

    if (a is ListReducibleValue) {
      final CompEq eq = CompEq();
      final List<Reducible> result = [];

      for (final Reducible element in a.value) {
        final Reducible elementReduced = element.reduce();
        final Reducible comparison = eq.compare(elementReduced, b);

        if (comparison is BooleanReducibleValue && !comparison.value) {
          result.add(elementReduced);
        }
      }

      return ListReducibleValue(result);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
}
