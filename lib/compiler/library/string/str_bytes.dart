/*import 'dart:convert';
import 'dart:typed_data';
import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class StrBytes extends NativeFunctionPrototype {
  StrBytes()
      : super(
          name: 'str.bytes',
          parameters: [
            Parameter.string('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();

    if (a is StringNode) {
      final Uint8List bytes = Uint8List.fromList(utf8.encode(a.value));

      return ListNode(bytes.map(NumberNode.new).toList());
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }
}
*/