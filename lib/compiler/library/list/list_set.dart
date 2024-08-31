import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ListSet extends NativeFunctionPrototype {
  ListSet()
      : super(
          name: 'list.set',
          parameters: [
            Parameter.list('a'),
            Parameter.number('b'),
            Parameter.any('c'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a');
    final Reducible b = arguments.get('b').reduce();
    final Reducible c = arguments.get('c');

    if ((a is ListReducibleValue) && (b is NumberReducibleValue)) {
      final List<Reducible> head = a.value.sublist(0, b.value.toInt());
      final List<Reducible> tail =
          a.value.sublist(b.value.toInt(), a.value.length);

      return ListReducibleValue([...head, c, ...tail]);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
