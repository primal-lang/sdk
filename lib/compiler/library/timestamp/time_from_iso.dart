import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class TimeFromIso extends NativeFunctionNode {
  const TimeFromIso()
    : super(
        name: 'time.fromIso',
        parameters: const [
          Parameter.string('a'),
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

    if (a is StringNode) {
      try {
        return TimestampNode(DateTime.parse(a.value));
      } on FormatException {
        throw ParseError(
          function: name,
          input: a.value,
          targetType: 'timestamp',
        );
      }
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
