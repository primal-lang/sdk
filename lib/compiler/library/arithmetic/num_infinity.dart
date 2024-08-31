import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class NumInfinity extends NativeFunctionPrototype {
  NumInfinity()
      : super(
          name: 'num.infinity',
          parameters: [],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      const NumberReducibleValue(double.infinity);
}
