import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/node.dart';

class DirectoryDelete extends NativeFunctionNode {
  DirectoryDelete()
      : super(
          name: 'directory.delete',
          parameters: [
            Parameter.directory('a'),
          ],
        );

  @override
  Node node(List<Node> arguments) => NodeWithArguments(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class NodeWithArguments extends NativeFunctionNodeWithArguments {
  const NodeWithArguments({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0].evaluate();

    if (a is DirectoryNode) {
      final bool deleted = PlatformInterface().directory.delete(a.value);

      return BooleanNode(deleted);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
