import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class StrSubstring extends NativeFunctionPrototype {
  StrSubstring()
      : super(
          name: 'str.substring',
          parameters: [
            Parameter.string('a'),
            Parameter.number('b'),
            Parameter.number('c'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();
    final Reducible b = arguments.get('b').reduce();
    final Reducible c = arguments.get('c').reduce();

    if ((a is StringReducibleValue) &&
        (b is NumberReducibleValue) &&
        (c is NumberReducibleValue)) {
      return StringReducibleValue(
          a.value.substring(b.value.toInt(), c.value.toInt()));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
