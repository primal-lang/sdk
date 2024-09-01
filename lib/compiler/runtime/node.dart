import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

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

class FreeVariableNode extends Node {
  final String value;

  const FreeVariableNode(this.value);

  @override
  Type get type => const AnyType();

  @override
  String toString() => value;
}

class BoundedVariableNode extends FreeVariableNode {
  const BoundedVariableNode(super.value);
}

class CallNode extends Node {
  final Node callee;
  final List<Node> arguments;

  const CallNode({
    required this.callee,
    required this.arguments,
  });

  @override
  Node evaluate() {
    final Node callee = this.callee.evaluate();

    if (callee is FunctionNode) {
      return callee.substitute(arguments).evaluate();
    } else if (callee is FreeVariableNode) {
      final FunctionPrototype prototype = Runtime.SCOPE
          .get(callee.value); // TODO(momo): do not use global scope
      final FunctionNode function = prototype.toNode();

      return function.substitute(arguments).evaluate();
    } else if (callee is BoundedVariableNode) {
      throw Exception(
          'Handle bound variable node callee: $callee'); // TODO(momo): handle
    } else {
      throw Exception(
          'Cannot apply function to: $callee'); // TODO(momo): handle
    }
  }

  @override
  Type get type => const FunctionCallType();

  @override
  String toString() => '$callee(${arguments.join(', ')})';
}

class FunctionNode extends Node {
  final String name;
  final List<Parameter> parameters;
  final Node body;

  const FunctionNode({
    required this.name,
    required this.parameters,
    required this.body,
  });

  Node substitute(List<Node> arguments) {
    if (parameters.length != arguments.length) {
      throw InvalidArgumentCountError(
        function: name,
        expected: parameters.length,
        actual: arguments.length,
      );
    }

    return body; // TODO(momo): substitute arguments in body
  }

  @override
  Type get type => const FunctionType();

  @override
  String toString() => '{${parameters.join(', ')} = $body}';
}
