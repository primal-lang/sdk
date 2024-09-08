import 'package:primal/compiler/runtime/node.dart';

class TimeNow extends NativeFunctionNode {
  TimeNow()
      : super(
          name: 'time.now',
          parameters: [],
        );

  @override
  Node node(List<Node> arguments) => TimestampNode(DateTime.now());
}
