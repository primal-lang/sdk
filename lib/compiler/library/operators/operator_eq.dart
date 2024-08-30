import 'package:primal/compiler/library/comparison/comp_eq.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorEq extends NativeFunctionPrototype {
  OperatorEq()
      : super(
          name: '==',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      CompEq().substitute(arguments);
}
