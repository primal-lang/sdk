import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class SetNew extends NativeFunctionNode {
  SetNew()
      : super(
          name: 'set.new',
          parameters: [
            Parameter.list('a'),
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

    if (a is ListNode) {
      final Set<Node> nodeElements = {};
      final Set<dynamic> nativeElements = {};

      for (final Node element in a.value) {
        final dynamic native = element.native();

        if (!nativeElements.contains(native)) {
          nodeElements.add(element);
          nativeElements.add(native);
        }
      }

      return SetNode(nodeElements);
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
