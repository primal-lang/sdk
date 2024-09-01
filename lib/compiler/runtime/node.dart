import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/scope.dart';

abstract class Node {
  const Node();

  Type get type;

  Node substitute(Scope<Node> arguments);

  Node reduce();
}

abstract class LiteralNode<T> implements Node {
  final T value;

  const LiteralNode(this.value);

  @override
  String toString() => value.toString();

  @override
  Node substitute(Scope<Node> arguments) => this;

  @override
  Node reduce() => this;
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

  @override
  Node substitute(Scope<Node> arguments) =>
      ListNode(value.map((e) => e.substitute(arguments)).toList());
}

class IdentifierNode extends Node {
  final String value;

  const IdentifierNode(this.value);

  IdentifierNode get asBounded => BoundedVariableNode(value);

  IdentifierNode get asFree => FreeVariableNode(value);

  @override
  Node substitute(Scope<Node> arguments) => arguments.get(value);

  @override
  Node reduce() => this;

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

  CallNode withCallee(Node callee) => CallNode(
        callee: callee,
        arguments: arguments,
      );

  CallNode withArguments(List<Node> arguments) => CallNode(
        callee: callee,
        arguments: arguments,
      );

  @override
  Node substitute(Scope<Node> arguments) => CallNode(
        callee: callee,
        arguments: this.arguments.map((e) => e.substitute(arguments)).toList(),
      );

  @override
  Node reduce() {
    /*final FunctionPrototype function = Runtime.SCOPE.get(name);
    final Scope<Node> newScope = Scope.from(
      functionName: name,
      parameters: function.parameters,
      arguments: arguments,
      location: location,
    );

    return function.substitute(newScope).reduce();*/

    return this;
  }

  @override
  Type get type => const FunctionType();

  @override
  String toString() => '$callee(${arguments.join(', ')})';
}
