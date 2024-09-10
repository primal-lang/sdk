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
      return compareLists(
        function: function,
        listA: a.value,
        listB: b.value,
      );
    } else if ((a is VectorNode) && (b is VectorNode)) {
      return compareLists(
        function: function,
        listA: a.value,
        listB: b.value,
      );
    } else if ((a is StackNode) && (b is StackNode)) {
      return compareLists(
        function: function,
        listA: a.value,
        listB: b.value,
      );
    } else if ((a is QueueNode) && (b is QueueNode)) {
      return compareLists(
        function: function,
        listA: a.value,
        listB: b.value,
      );
    } else if ((a is SetNode) && (b is SetNode)) {
      return compareSets(
        function: function,
        setA: a.native(),
        setB: b.native(),
      );
    } else if ((a is MapNode) && (b is MapNode)) {
      return compareMaps(
        function: function,
        a: a,
        b: b,
      );
    } else {
      throw InvalidArgumentTypesError(
        function: function.name,
        expected: function.parameterTypes,
        actual: [a.type, b.type],
      );
    }
  }

  static BooleanNode compareLists({
    required FunctionNode function,
    required List listA,
    required List listB,
  }) {
    if (listA.length != listB.length) {
      return const BooleanNode(false);
    } else {
      for (int i = 0; i < listA.length; i++) {
        final BooleanNode comparison = execute(
          function: function,
          a: listA[i].evaluate(),
          b: listB[i].evaluate(),
        );

        if (!comparison.value) {
          return const BooleanNode(false);
        }
      }

      return const BooleanNode(true);
    }
  }

  static BooleanNode compareSets({
    required FunctionNode function,
    required Set setA,
    required Set setB,
  }) {
    if (setA.length != setB.length) {
      return const BooleanNode(false);
    } else {
      for (final dynamic element in setA) {
        if (!setB.contains(element)) {
          return const BooleanNode(false);
        }
      }

      return const BooleanNode(true);
    }
  }

  static BooleanNode compareMaps({
    required FunctionNode function,
    required MapNode a,
    required MapNode b,
  }) {
    if (a.value.length != b.value.length) {
      return const BooleanNode(false);
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
