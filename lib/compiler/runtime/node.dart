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

  @override
  Node substitute(Bindings bindings) =>
      ListNode(value.map((e) => e.substitute(bindings)).toList());
}

class FreeVariableNode extends Node {
  final String value;

  const FreeVariableNode(this.value);

  // TODO(momo): create function pointer in semantic analyzer to avoid
  // using the scope here
  // TODO(momo): do not use global scope
  FunctionNode functionNode() {
    final Node node = Runtime.SCOPE.get(value);

    if (node is FunctionNode) {
      return node;
    } else {
      throw Exception(
          'Variable "$value" is not a function'); // TODO(momo): handle
    }
  }

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
    final FunctionNode function = getFunctionNode(callee);

    return function.apply(arguments);
  }

  FunctionNode getFunctionNode(Node callee) {
    if (callee is CallNode) {
      return getFunctionNode(callee.evaluate());
    } else if (callee is FunctionNode) {
      return callee;
    } else if (callee is FreeVariableNode) {
      return callee.functionNode();
    } else {
      throw Exception(
          'Cannot apply arguments to: $callee'); // TODO(momo): handle
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

  @override
  String toString() => '{${parameters.join(', ')} = $node}';
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
