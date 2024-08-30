import 'package:primal/compiler/library/booleans/bool_and.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorAnd extends NativeFunctionPrototype {
  OperatorAnd()
      : super(
          name: '&',
          parameters: [
            Parameter.boolean('a'),
            Parameter.boolean('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      BoolAnd().substitute(arguments);
}
