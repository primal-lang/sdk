import 'package:primal/compiler/runtime/node.dart';

class NumInfinity extends NativeFunctionNode {
  NumInfinity()
      : super(
          name: 'num.infinity',
          parameters: [],
        );

  @override
  Node node(List<Node> arguments) => const NumberNode(double.infinity);
}
