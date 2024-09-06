import 'dart:math';
import 'package:primal/compiler/runtime/node.dart';

class NumDecimalRandom extends NativeFunctionNode {
  NumDecimalRandom()
      : super(
          name: 'num.decimalRandom',
          parameters: [],
        );

  @override
  Node node(List<Node> arguments) => NumberNode(Random().nextDouble());
}
