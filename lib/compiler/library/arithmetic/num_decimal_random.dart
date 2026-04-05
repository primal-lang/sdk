import 'dart:math';
import 'package:primal/compiler/runtime/node.dart';

class NumDecimalRandom extends NativeFunctionNode {
  const NumDecimalRandom()
    : super(
        name: 'num.decimalRandom',
        parameters: const [],
      );

  @override
  Node node(List<Node> arguments) => NumberNode(Random().nextDouble());
}
