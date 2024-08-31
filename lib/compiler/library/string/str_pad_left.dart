import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class StrPadLeft extends NativeFunctionPrototype {
  StrPadLeft()
      : super(
          name: 'str.padLeft',
          parameters: [
            Parameter.string('a'),
            Parameter.number('b'),
            Parameter.string('c'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').reduce();
    final Reducible b = arguments.get('b').reduce();
    final Reducible c = arguments.get('c').reduce();

    if ((a is StringReducibleValue) &&
        (b is NumberReducibleValue) &&
        (c is StringReducibleValue)) {
      return StringReducibleValue(a.value.padLeft(b.value.toInt(), c.value));
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
