import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/platform_web.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class ConsoleWriteLn extends NativeFunctionPrototype {
  ConsoleWriteLn()
      : super(
          name: 'console.writeLn',
          parameters: [
            Parameter.any('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').reduce();
    PlatformInterface().outWriteLn(a.toString());

    return a;
  }
}
