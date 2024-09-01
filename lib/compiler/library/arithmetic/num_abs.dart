import 'package:primal/compiler/errors/runtime_error.dart';
import 'package:primal/compiler/models/parameter.dart';
import 'package:primal/compiler/models/type.dart';
import 'package:primal/compiler/runtime/node.dart';
import 'package:primal/compiler/runtime/scope.dart';
import 'package:primal/compiler/semantic/function_prototype.dart';

class NumAbs extends NativeFunctionPrototype {
  NumAbs()
      : super(
          name: 'num.abs',
          parameters: [
            Parameter.number('a'),
          ],
        );

  @override
  Node substitute(Scope<Node> arguments) {
    final Node a = arguments.get('a').evaluate();

    if (a is NumberNode) {
      return NumberNode(a.value.abs());
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: parameterTypes,
        actual: [a.type],
      );
    }
  }

  @override
  Node createNode({
    required String name,
    required List<Parameter> parameters,
    required List<Node> arguments,
  }) =>
      NumAbsNode2(
        name: name,
        parameters: parameters,
        arguments: arguments,
      );
}

class NumAbsNode2 extends GenericNativeNode {
  const NumAbsNode2({
    required super.name,
    required super.parameters,
    required super.arguments,
  });

  @override
  Node evaluate() {
    final Node a = arguments[0];

    if (a is NumberNode) {
      return NumberNode(a.value.abs());
    } else {
      throw InvalidArgumentTypesError(
        function: name,
        expected: [], // TODO(momo): parameterTypes,
        actual: [a.type],
      );
    }
  }
}

class GenericNativeNode extends Node {
  final String name;
  final List<Parameter> parameters;
  final List<Node> arguments;

  const GenericNativeNode({
    required this.name,
    required this.parameters,
    required this.arguments,
  });

  @override
  Type get type => const FunctionType();
}
