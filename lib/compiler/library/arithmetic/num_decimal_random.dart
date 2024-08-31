import 'dart:math';
import 'package:primal/compiler/runtime/reducible.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class NumDecimalRandom extends NativeFunctionPrototype {
  NumDecimalRandom()
      : super(
          name: 'num.decimalRandom',
          parameters: [],
        );

  @override
  Reducible substitute(Scope<Reducible> arguments) =>
      NumberReducibleValue(Random().nextDouble());
}
