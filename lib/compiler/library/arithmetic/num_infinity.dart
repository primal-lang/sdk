import 'package:primal/compiler/runtime/node.dart';

class NumInfinity extends NativeFunctionNode {
  const NumInfinity()
    : super(
        name: 'num.infinity',
        parameters: const [],
      );

  @override
  Node node(List<Node> arguments) => const NumberNode(double.infinity);
}
