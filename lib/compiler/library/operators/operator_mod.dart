import 'package:primal/compiler/library/arithmetic/num_mod.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorMod extends NativeFunctionPrototype {
  OperatorMod()
      : super(
          name: '%',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      NumMod().substitute(arguments);
}
