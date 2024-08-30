import 'package:primal/compiler/library/comparison/comp_ge.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class OperatorGe extends NativeFunctionPrototype {
  OperatorGe()
      : super(
          name: '>=',
          parameters: [
            Parameter.number('a'),
            Parameter.number('b'),
          ],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      CompGe().substitute(arguments);
}
