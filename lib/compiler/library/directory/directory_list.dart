import 'dart:io';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/platform/base/platform_cli.dart'
    if (dart.library.html) 'package:primal/compiler/platform/base/platform_web.dart';
import 'package:primal/compiler/runtime/node.dart';

class DirectoryList extends NativeFunctionNode {
  DirectoryList()
      : super(
          name: 'directory.list',
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
      final List<FileSystemEntity> children =
          PlatformInterface().directory.list(a.value);
      final List<Node> list = [];

      for (final child in children) {
        if (child is File) {
          list.add(FileNode(child));
        } else if (child is Directory) {
          list.add(DirectoryNode(child));
        }
      }

      return ListNode(list);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
