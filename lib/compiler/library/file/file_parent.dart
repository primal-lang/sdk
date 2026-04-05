import 'dart:io';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/node.dart';

class FileParent extends NativeFunctionNode {
  const FileParent()
    : super(
        name: 'file.parent',
        parameters: const [
          Parameter.file('a'),
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
  Node reduce() {
    final Node a = arguments[0].reduce();

    if (a is FileNode) {
      final Directory parent = PlatformInterface().file.parent(a.value);

      return DirectoryNode(parent);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
