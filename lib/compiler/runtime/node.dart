import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/bindings.dart';
import 'package:primal/compiler/runtime/runtime.dart';

abstract class Node {
  const Node();

  Type get type;

  Node substitute(Bindings bindings) => this;

  Node evaluate() => this;

  dynamic native();
}

abstract class LiteralNode<T> implements Node {
  final T value;

  const LiteralNode(this.value);

  @override
  String toString() => value.toString();

  @override
  Node substitute(Bindings bindings) => this;

  @override
  Node evaluate() => this;

  @override
  dynamic native() => value;

  static LiteralNode from(dynamic value) {
    if (value is bool) {
      return BooleanNode(value);
    } else if (value is num) {
      return NumberNode(value);
    } else if (value is String) {
      return StringNode(value);
    } else if (value is List<Node>) {
      return ListNode(value);
    } else if (value is Map<Node, Node>) {
      return MapNode(value);
    } else {
      throw InvalidLiteralValueError(value);
    }
  }
}

class BooleanNode extends LiteralNode<bool> {
  const BooleanNode(super.value);

  @override
  Type get type => const BooleanType();
}

class NumberNode extends LiteralNode<num> {
  const NumberNode(super.value);

  @override
  Type get type => const NumberType();
}

class StringNode extends LiteralNode<String> {
  const StringNode(super.value);

  @override
  Type get type => const StringType();
}

class TimestampNode extends LiteralNode<DateTime> {
  const TimestampNode(super.value);

  @override
  Type get type => const TimestampType();
}

class ListNode extends LiteralNode<List<Node>> {
  const ListNode(super.value);

  @override
  Type get type => const ListType();

  @override
  Node substitute(Bindings bindings) =>
      ListNode(value.map((e) => e.substitute(bindings)).toList());

  @override
  List native() => value.map((e) => e.native()).toList();
}

class VectorNode extends LiteralNode<List<Node>> {
  const VectorNode(super.value);

  @override
  Type get type => const VectorType();

  @override
  Node substitute(Bindings bindings) =>
      VectorNode(value.map((e) => e.substitute(bindings)).toList());

  @override
  List native() => value.map((e) => e.native()).toList();
}

class MapNode extends LiteralNode<Map<Node, Node>> {
  const MapNode(super.value);

  @override
  Type get type => const MapType();

  @override
  Node substitute(Bindings bindings) {
    final Iterable<MapEntry<Node, Node>> entries = value.entries.map((e) =>
        MapEntry(e.key.substitute(bindings), e.value.substitute(bindings)));

    return MapNode(Map.fromEntries(entries));
  }

  Map<dynamic, Node> asMapWithKeys() {
    final Map<dynamic, Node> map = {};

    for (final MapEntry<Node, Node> entry in value.entries) {
      map[entry.key.native()] = entry.value;
    }

    return map;
  }

  @override
  Map<dynamic, dynamic> native() {
    final Map<dynamic, dynamic> map = {};

    for (final MapEntry<Node, Node> entry in value.entries) {
      final dynamic key = entry.key.native();
      final dynamic value = entry.value.native();
      map[key] = value;
    }

    return map;
  }
}

class FreeVariableNode extends Node {
  final String value;

  const FreeVariableNode(this.value);

  // TODO(momo): create function pointer in semantic analyzer to avoid
  // using the scope here
  @override
  FunctionNode evaluate() {
    final Node node = Runtime.SCOPE.get(value);

    if (node is FunctionNode) {
      return node;
    } else {
      throw InvalidFunctionError(value);
    }
  }

  @override
  Type get type => const AnyType();

  @override
  String toString() => value;

  @override
  dynamic native() => evaluate().native();
}

class BoundedVariableNode extends FreeVariableNode {
  const BoundedVariableNode(super.value);

  @override
  Node substitute(Bindings bindings) => bindings.get(value);
}

class CallNode extends Node {
  final Node callee;
  final List<Node> arguments;

  const CallNode({
    required this.callee,
    required this.arguments,
  });

  @override
  Node substitute(Bindings bindings) => CallNode(
        callee: callee.substitute(bindings),
        arguments: arguments.map((e) => e.substitute(bindings)).toList(),
      );

  @override
  Node evaluate() {
    final FunctionNode function = getFunctionNode(callee);

    return function.apply(arguments);
  }

  FunctionNode getFunctionNode(Node callee) {
    if (callee is CallNode) {
      return getFunctionNode(callee.evaluate());
    } else if (callee is FreeVariableNode) {
      return callee.evaluate();
    } else if (callee is FunctionNode) {
      return callee;
    } else {
      throw InvalidFunctionError(callee.toString());
    }
  }

  @override
  Type get type => const FunctionCallType();

  @override
  String toString() => '$callee(${arguments.join(', ')})';

  @override
  dynamic native() => evaluate().native();
}

class FunctionNode extends Node {
  final String name;
  final List<Parameter> parameters;

  const FunctionNode({
    required this.name,
    required this.parameters,
  });

  List<Type> get parameterTypes => parameters.map((e) => e.type).toList();

  bool equalSignature(FunctionNode function) => function.name == name;

  Node apply(List<Node> arguments) {
    if (parameters.length != arguments.length) {
      throw InvalidArgumentCountError(
        function: name,
        expected: parameters.length,
        actual: arguments.length,
      );
    }

    final Bindings bindings = Bindings.from(
      parameters: parameters,
      arguments: arguments,
    );

    return substitute(bindings).evaluate();
  }

  @override
  Type get type => const FunctionType();

  @override
  String toString() =>
      '$name(${parameters.map((e) => '${e.name}: ${e.type}').join(', ')})';

  @override
  dynamic native() => toString();
}

class CustomFunctionNode extends FunctionNode {
  final Node node;

  const CustomFunctionNode({
    required super.name,
    required super.parameters,
    required this.node,
  });

  @override
  Node substitute(Bindings bindings) => node.substitute(bindings);

  @override
  Type get type => const FunctionType();
}

abstract class NativeFunctionNode extends FunctionNode {
  const NativeFunctionNode({
    required super.name,
    required super.parameters,
  });

  @override
  Node substitute(Bindings bindings) {
    final List<Node> arguments =
        parameters.map((e) => bindings.get(e.name)).toList();

    return node(arguments);
  }

  Node node(List<Node> arguments);

  @override
  Type get type => const FunctionType();
}

class NativeFunctionNodeWithArguments extends FunctionNode {
  final List<Node> arguments;

  const NativeFunctionNodeWithArguments({
    required super.name,
    required super.parameters,
    required this.arguments,
  });
}
