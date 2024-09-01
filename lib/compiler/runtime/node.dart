import 'package:primal/compiler/models/location.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

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
  final Location location;

  const IdentifierNode({
    required this.value,
    required this.location,
  });

  IdentifierNode get asBounded => BoundedVariableNode(
        value: value,
        location: location,
      );

  IdentifierNode get asFree => FreeVariableNode(
        value: value,
        location: location,
      );

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
  const BoundedVariableNode({
    required super.value,
    required super.location,
  });
}

class FreeVariableNode extends IdentifierNode {
  const FreeVariableNode({
    required super.value,
    required super.location,
  });
}

class CallNode extends Node {
  final String name;
  final List<Node> arguments;
  final Location location;

  const CallNode({
    required this.name,
    required this.arguments,
    required this.location,
  });

  CallNode withArguments(List<Node> arguments) => CallNode(
        name: name,
        arguments: arguments,
        location: location,
      );

  @override
  Node substitute(Scope<Node> arguments) => CallNode(
        name: name,
        arguments: this.arguments.map((e) => e.substitute(arguments)).toList(),
        location: location,
      );

  @override
  Node reduce() {
    final FunctionPrototype function = Runtime.SCOPE.get(name);
    final Scope<Node> newScope = Scope.from(
      functionName: name,
      parameters: function.parameters,
      arguments: arguments,
      location: location,
    );

    return function.substitute(newScope).reduce();
  }

  @override
  Type get type => const FunctionType();

  @override
  String toString() => '$name(${arguments.join(', ')})';
}
