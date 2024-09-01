import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';

abstract class Node {
  const Node();

  Type get type;

  Node evaluate() => this;
}

abstract class LiteralNode<T> implements Node {
  final T value;

  const LiteralNode(this.value);

  @override
  String toString() => value.toString();

  @override
  Node evaluate() => this;
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

class ListNode extends LiteralNode<List<Node>> {
  const ListNode(super.value);

  @override
  Type get type => const ListType();
}

class IdentifierNode extends Node {
  final String value;

  const IdentifierNode(this.value);

  @override
  Type get type => const AnyType();

  @override
  String toString() => value;
}

class BoundedVariableNode extends IdentifierNode {
  const BoundedVariableNode(super.value);
}

class FreeVariableNode extends IdentifierNode {
  const FreeVariableNode(super.value);
}

class CallNode extends Node {
  final Node callee;
  final List<Node> arguments;

  const CallNode({
    required this.callee,
    required this.arguments,
  });

  @override
  Type get type => const FunctionCallType();

  @override
  String toString() => '$callee(${arguments.join(', ')})';
}

class FunctionNode extends Node {
  final List<Parameter> parameters;
  final Node body;

  const FunctionNode({
    required this.parameters,
    required this.body,
  });

  @override
  Type get type => const FunctionType();

  @override
  String toString() => '{${parameters.join(', ')} = $body}';
}
