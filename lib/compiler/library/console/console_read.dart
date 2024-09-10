import 'package:primal/compiler/platform/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/platform_web.dart';
import 'package:primal/compiler/runtime/node.dart';

class ConsoleRead extends NativeFunctionNode {
  ConsoleRead()
      : super(
          name: 'console.read',
          parameters: [],
        );

  @override
  Node node(List<Node> arguments) =>
      StringNode(PlatformInterface().consoleReadLine());
}
