import 'package:primal/compiler/runtime/node.dart';

class TimeNow extends NativeFunctionNode {
  const TimeNow()
    : super(
        name: 'time.now',
        parameters: const [],
      );

  @override
  Node node(List<Node> arguments) => TimestampNode(DateTime.now());
}
