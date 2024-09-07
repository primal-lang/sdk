import 'package:primal/compiler/platform/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/platform_web.dart';
import 'package:primal/compiler/runtime/node.dart';

class ConsoleReadLine extends NativeFunctionNode {
  ConsoleReadLine()
      : super(
          name: 'console.readLine',
          parameters: [],
        );

  @override
  Node node(List<Node> arguments) => StringNode(PlatformInterface().readLine());
}