import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/bindings.dart';
import 'package:primal/compiler/runtime/runtime.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

abstract class Node {
  const Node();

  Type get type;

  Node substitute(Bindings bindings) => this;

  Node evaluate() => this;
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
    final FunctionNode function = getFunctionNode();

    if (function.parameters.length != arguments.length) {
      throw InvalidArgumentCountError(
        function: function.name,
        expected: function.parameters.length,
        actual: arguments.length,
      );
    }

    final Bindings bindings = Bindings.from(
      parameters: function.parameters,
      arguments: arguments,
    );

    return function.substitute(bindings).evaluate();
  }

  FunctionNode getFunctionNode() {
    final Node callee = this.callee;

    if (callee is FunctionNode) {
      return callee;
    } else if (callee is FreeVariableNode) {
      // TODO(momo): create function pointer in semantic analyzer to avoid
      // using the scope here
      final FunctionPrototype prototype = Runtime.SCOPE
          .get(callee.value); // TODO(momo): do not use global scope
      // TODO(momo): make scope return a function node directly
      final FunctionNode function = prototype.toNode();

      return function;
    } else if (callee is BoundedVariableNode) {
      // TODO(momo): there can be a bound variable node here?
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

  @override
  Node substitute(Bindings bindings) => body.substitute(bindings);

  @override
  Type get type => const FunctionType();

  @override
  String toString() => '{${parameters.join(', ')} = $body}';
}

class BaseFunctionNode extends Node {
  final String name;
  final List<Parameter> parameters;

  const BaseFunctionNode({
    required this.name,
    required this.parameters,
  });

  @override
  Type get type => const FunctionType();
}

class CustomFunctionNode extends BaseFunctionNode {
  final Node body;

  const CustomFunctionNode({
    required super.name,
    required super.parameters,
    required this.body,
  });

  @override
  Node substitute(Bindings bindings) => body.substitute(bindings);

  @override
  Type get type => const FunctionType();

  @override
  String toString() => '{${parameters.join(', ')} = $body}';
}

class NativeFunctionNode extends BaseFunctionNode {
  final Function(List<Node>) body;

  const NativeFunctionNode({
    required super.name,
    required super.parameters,
    required this.body,
  });

  @override
  Node substitute(Bindings bindings) {
    final List<Node> arguments =
        parameters.map((e) => bindings.get(e.name)).toList();

    return body(arguments);
  }

  @override
  Type get type => const FunctionType();
}
