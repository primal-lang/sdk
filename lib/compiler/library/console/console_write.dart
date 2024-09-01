import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/platform_web.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ConsoleWrite extends NativeFunctionPrototype {
  ConsoleWrite()
      : super(
          name: 'console.write',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();
    PlatformInterface().outWrite(a.toString());

    return a;
  }
}
