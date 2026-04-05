import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class IsDirectory extends NativeFunctionNode {
  const IsDirectory()
    : super(
        name: 'is.directory',
        parameters: const [
          Parameter.any('a'),
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

    return BooleanNode(a is DirectoryNode);
  }
}
