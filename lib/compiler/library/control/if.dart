import 'package:dry/compiler/errors/runtime_error.dart';
import 'package:dry/compiler/models/parameter.dart';
import 'package:dry/compiler/runtime/reducible.dart';
import 'package:dry/compiler/runtime/scope.dart';
import 'package:dry/compiler/semantic/function_prototype.dart';

class If extends NativeFunctionPrototype {
  If()
      : super(
          name: 'if',
          parameters: [
            Parameter.boolean('a'),
            Parameter.any('b'),
            Parameter.any('c'),
          ],
        );

  @override
  Reducible bind(Scope<Reducible> arguments) {
    final Reducible a = arguments.get('a').evaluate();
    final Reducible b = arguments.get('b');
    final Reducible c = arguments.get('c');

    if (a is BooleanReducibleValue) {
      if (a.value) {
        return b;
      } else {
        return c;
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameters.map((e) => e.type.toString()).toList(),
        actual: [a.type, b.type, c.type],
      );
    }
  }
}
