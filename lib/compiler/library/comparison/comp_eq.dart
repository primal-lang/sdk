import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/runtime/node.dart';

class CompEq extends NativeFunctionNode {
  CompEq()
      : super(
          name: 'comp.eq',
          parameters: [
            Parameter.any('a'),
            Parameter.any('b'),
          ],
        );

  @override
  Node node(List<Node> arguments) => NodeWithArguments(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );

  static BooleanNode execute({
    required FunctionNode function,
    required Node a,
    required Node b,
  }) {
    if ((a is BooleanNode) && (b is BooleanNode)) {
      return BooleanNode(a.value == b.value);
    } else if ((a is NumberNode) && (b is NumberNode)) {
      return BooleanNode(a.value == b.value);
    } else if ((a is StringNode) && (b is StringNode)) {
      return BooleanNode(a.value == b.value);
    } else if ((a is TimestampNode) && (b is TimestampNode)) {
      return BooleanNode(a.value.compareTo(b.value) == 0);
    } else if ((a is ListNode) && (b is ListNode)) {
      if (a.value.length != b.value.length) {
        throw IterablesWithDifferentLengthError(
          iterable1: a.native(),
          iterable2: b.native(),
        );
      } else {
        for (int i = 0; i < a.value.length; i++) {
          final BooleanNode comparison = execute(
            function: function,
            a: a.value[i].evaluate(),
            b: b.value[i].evaluate(),
          );

          if (!comparison.value) {
            return const BooleanNode(false);
          }
        }

        return const BooleanNode(true);
      }
    } else if ((a is MapNode) && (b is MapNode)) {
      if (a.value.length != b.value.length) {
        throw IterablesWithDifferentLengthError(
          iterable1: a.native(),
          iterable2: b.native(),
        );
      } else {
        final Map<dynamic, Node> mapA = a.asMapWithKeys();
        final Map<dynamic, Node> mapB = b.asMapWithKeys();

        final Set<dynamic> keys = {
          ...mapA.keys,
          ...mapB.keys,
        };

        for (final dynamic key in keys) {
          if (!mapA.containsKey(key) || !mapB.containsKey(key)) {
            return const BooleanNode(false);
          }

          final BooleanNode comparison = execute(
            function: function,
            a: mapA[key]!.evaluate(),
            b: mapB[key]!.evaluate(),
          );

          if (!comparison.value) {
            return const BooleanNode(false);
          }
        }

        return const BooleanNode(true);
      }
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }
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
    final Node b = arguments[1].evaluate();

    return CompEq.execute(
      function: this,
      a: a,
      b: b,
    );
  }
}
